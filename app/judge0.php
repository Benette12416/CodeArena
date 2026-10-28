<?php
declare(strict_types=1);

/** Build server-side Judge0 headers. Credentials never reach browser JavaScript. */
function judge0_request_headers(array $judgeConfig): array {
    $headers = ['Content-Type: application/json', 'Accept: application/json'];
    $apiKey = trim((string)($judgeConfig['api_key'] ?? ''));
    if (!in_array($apiKey, ['', 'PUT_YOUR_API_KEY_HERE', 'YOUR_API_KEY'], true)) {
        $authHeader = trim((string)($judgeConfig['auth_header'] ?? 'X-RapidAPI-Key'));
        if ($authHeader !== '') $headers[] = $authHeader . ': ' . $apiKey;
    }
    foreach (($judgeConfig['extra_headers'] ?? []) as $header) {
        $header = trim((string)$header);
        if ($header !== '' && !str_starts_with($header, '//')) $headers[] = $header;
    }
    return $headers;
}

function judge0_base(array $judgeConfig): string {
    if (!function_exists('curl_init')) throw new RuntimeException('PHP cURL is not enabled. Enable the cURL extension in XAMPP and restart Apache.');
    $base = rtrim(trim((string)($judgeConfig['base_url'] ?? '')), '/');
    if ($base === '') throw new RuntimeException('Judge0 is not configured. Set judge0.base_url in config/config.php.');
    if (!preg_match('~^https?://~i', $base)) throw new RuntimeException('Judge0 base_url must begin with http:// or https://.');
    return $base;
}

/** @return array{http:int,body:string|false,error:string} */
function judge0_result_status_id(array $result): int {
    if (isset($result['status']) && is_array($result['status'])) return (int)($result['status']['id'] ?? 0);
    if (isset($result['status_id'])) return (int)$result['status_id'];
    if (isset($result['status']) && is_numeric($result['status'])) return (int)$result['status'];
    return 0;
}

function judge0_normalize_result(array $result): array {
    $statusId = judge0_result_status_id($result);
    if (!isset($result['status']) || !is_array($result['status'])) {
        $descriptions = [
            0=>'Unknown', 1=>'In Queue', 2=>'Processing', 3=>'Accepted', 4=>'Wrong Answer',
            5=>'Time Limit Exceeded', 6=>'Compilation Error', 7=>'Runtime Error (SIGSEGV)',
            8=>'Runtime Error (SIGXFSZ)', 9=>'Runtime Error (SIGFPE)', 10=>'Runtime Error (SIGABRT)',
            11=>'Runtime Error (NZEC)', 12=>'Runtime Error (Other)', 13=>'Internal Error', 14=>'Exec Format Error',
        ];
        $result['status'] = ['id'=>$statusId, 'description'=>$descriptions[$statusId] ?? 'Unknown'];
    }
    return $result;
}

function judge0_http_json(string $url, string $method, array $headers, ?array $payload = null, int $timeout = 12): array {
    $curl = curl_init($url);
    $options = [CURLOPT_HTTPHEADER=>$headers, CURLOPT_RETURNTRANSFER=>true, CURLOPT_CONNECTTIMEOUT=>8, CURLOPT_TIMEOUT=>$timeout];
    if (strtoupper($method) === 'POST') {
        $options[CURLOPT_POST] = true;
        $options[CURLOPT_POSTFIELDS] = json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
    }
    curl_setopt_array($curl, $options);
    $body = curl_exec($curl);
    $error = curl_error($curl);
    $http = (int)curl_getinfo($curl, CURLINFO_HTTP_CODE);
    curl_close($curl);
    return ['http'=>$http, 'body'=>$body, 'error'=>$error];
}

/** Create a token for one submission; used when a provider does not support batch routes. */
function judge0_create_single_token(string $base, array $headers, array $payload): string {
    $response = judge0_http_json($base . '/submissions?base64_encoded=false&wait=false', 'POST', $headers, $payload);
    if ($response['body'] === false) throw new RuntimeException('Could not reach Judge0 while queueing code: ' . ($response['error'] ?: 'connection failed') . '.');
    $json = json_decode((string)$response['body'], true);
    if ($response['http'] < 200 || $response['http'] >= 300 || !is_array($json) || empty($json['token'])) {
        if (in_array($response['http'], [401,403], true)) throw new RuntimeException('Judge0 rejected the request. Check the API key and authentication headers.');
        if ($response['http'] === 429) throw new RuntimeException('Judge0 request quota or rate limit was reached. Please retry later.');
        throw new RuntimeException('Judge0 could not queue a submission (HTTP ' . $response['http'] . '). Check the endpoint and provider configuration.');
    }
    return (string)$json['token'];
}

function judge0_execute(array $judgeConfig, string $language, string $sourceCode, string $stdin): array {
    $results = judge0_execute_batch($judgeConfig, [['language'=>$language,'source_code'=>$sourceCode,'stdin'=>$stdin]]);
    return $results[0];
}

/**
 * Queue test cases together when the provider supports Judge0's batch endpoint,
 * otherwise fall back to individual asynchronous submissions. Poll tokens in parallel.
 */
function judge0_execute_batch(array $judgeConfig, array $jobs): array {
    if (!$jobs) return [];
    if (count($jobs) > 20) throw new RuntimeException('A grading batch may contain at most 20 test cases.');
    $base = judge0_base($judgeConfig);
    $headers = judge0_request_headers($judgeConfig);
    $payloadJobs = [];
    foreach ($jobs as $job) {
        $language = (string)($job['language'] ?? '');
        $languageId = $judgeConfig['languages'][$language] ?? null;
        if (!$languageId) throw new RuntimeException('No Judge0 language ID is configured for ' . $language . '.');
        $payloadJobs[] = [
            'language_id'=>(int)$languageId,
            'source_code'=>(string)($job['source_code'] ?? ''),
            'stdin'=>(string)($job['stdin'] ?? ''),
            'cpu_time_limit'=>(float)($judgeConfig['cpu_time_limit'] ?? 3),
            'wall_time_limit'=>(float)($judgeConfig['wall_time_limit'] ?? 5),
            'memory_limit'=>(int)($judgeConfig['memory_limit'] ?? 128000),
        ];
    }

    // Judge0's batch route expects an object with a `submissions` list.
    $tokens = [];
    $batch = judge0_http_json($base . '/submissions/batch?base64_encoded=false', 'POST', $headers, ['submissions'=>$payloadJobs], 16);
    $batchRows = $batch['body'] === false ? null : json_decode((string)$batch['body'], true);
    if ($batch['body'] !== false && $batch['http'] >= 200 && $batch['http'] < 300 && is_array($batchRows)) {
        // Most CE deployments return a bare list. Accept object-wrapped forks as well.
        if (isset($batchRows['submissions']) && is_array($batchRows['submissions'])) $batchRows = $batchRows['submissions'];
        if (array_is_list($batchRows) && count($batchRows) === count($payloadJobs)) {
            foreach ($batchRows as $row) {
                $token = is_array($row) ? (string)($row['token'] ?? '') : '';
                if ($token === '') { $tokens = []; break; }
                $tokens[] = $token;
            }
        }
    }

    // Some hosted proxies and older forks disable the batch route.
    if (!$tokens && in_array((int)$batch['http'], [404,405,501], true)) {
        foreach ($payloadJobs as $payload) $tokens[] = judge0_create_single_token($base, $headers, $payload);
    }
    if (!$tokens) {
        if ($batch['body'] === false) throw new RuntimeException('Could not reach Judge0 while queueing code: ' . ($batch['error'] ?: 'connection failed') . '.');
        if (in_array((int)$batch['http'], [401,403], true)) throw new RuntimeException('Judge0 rejected the request. Check the API key and authentication headers.');
        if ((int)$batch['http'] === 429) throw new RuntimeException('Judge0 request quota or rate limit was reached. Please retry later.');
        throw new RuntimeException('Judge0 could not queue the grading batch (HTTP ' . (int)$batch['http'] . '). Check the endpoint and provider configuration.');
    }

    $timeout = max(5, min(55, (int)($judgeConfig['poll_timeout_seconds'] ?? 30)));
    $started = microtime(true);
    $results = array_fill(0, count($tokens), null);
    $pending = array_fill_keys(array_keys($tokens), true);
    $batchPollSupported = true;
    while ($pending && microtime(true) - $started < $timeout) {
        $fatal = null;
        if ($batchPollSupported) {
            $pendingTokens = array_map(static fn(int $index): string => $tokens[$index], array_keys($pending));
            $pollUrl = $base . '/submissions/batch?tokens=' . rawurlencode(implode(',', $pendingTokens)
                ) . '&base64_encoded=false&fields=token,stdout,stderr,compile_output,message,exit_code,exit_signal,status_id,time,memory';
            $poll = judge0_http_json($pollUrl, 'GET', $headers, null, 10);
            if ($poll['body'] === false) {
                // Temporary DNS/network failures are retried until the overall timeout.
            } elseif (in_array((int)$poll['http'], [404,400,405,501], true)) {
                // Some hosted proxies implement create-batch but not get-batch.
                $batchPollSupported = false;
            } elseif (in_array((int)$poll['http'], [401,403], true)) {
                $fatal = new RuntimeException('Judge0 rejected result polling. Check the API key and authentication headers.');
            } elseif ((int)$poll['http'] === 429) {
                // Keep polling at a gentle pace when the provider rate-limits a request.
            } elseif ((int)$poll['http'] >= 200 && (int)$poll['http'] < 300) {
                $decoded = json_decode((string)$poll['body'], true);
                $rows = is_array($decoded) && isset($decoded['submissions']) && is_array($decoded['submissions'])
                    ? $decoded['submissions'] : $decoded;
                if (!is_array($rows) || !array_is_list($rows)) {
                    $batchPollSupported = false;
                } else {
                    $pendingIndexByToken = [];
                    foreach (array_keys($pending) as $index) $pendingIndexByToken[$tokens[$index]] = $index;
                    $matched = 0;
                    foreach ($rows as $row) {
                        if (!is_array($row)) continue;
                        $token = (string)($row['token'] ?? '');
                        if ($token === '' || !array_key_exists($token, $pendingIndexByToken)) continue;
                        $matched++;
                        $index = $pendingIndexByToken[$token];
                        $normalized = judge0_normalize_result($row);
                        $statusId = (int)($normalized['status']['id'] ?? 0);
                        if ($statusId > 2) {
                            $results[$index] = $normalized;
                            unset($pending[$index]);
                        } elseif ($statusId === 0 && !empty($normalized['message'])) {
                            $fatal = new RuntimeException('Judge0 could not retrieve a queued result. Check provider access and quotas.');
                        }
                    }
                    // Empty/mismatched wrappers can occur on nonstandard forks; use individual polling instead.
                    if ($matched === 0 && $pending) $batchPollSupported = false;
                }
            } elseif ((int)$poll['http'] >= 500) {
                // Transient server error: retry until the overall poll timeout.
            } else {
                $batchPollSupported = false;
            }
        }

        if (!$batchPollSupported && $pending) {
            // Compatibility fallback for hosted services that do not expose GET /submissions/batch.
            $multi = curl_multi_init();
            $handles = [];
            foreach (array_keys($pending) as $index) {
                $url = $base . '/submissions/' . rawurlencode($tokens[$index]) . '?base64_encoded=false&fields=token,stdout,stderr,compile_output,message,exit_code,exit_signal,status,time,memory';
                $curl = curl_init($url);
                curl_setopt_array($curl, [CURLOPT_HTTPGET=>true, CURLOPT_HTTPHEADER=>$headers, CURLOPT_RETURNTRANSFER=>true, CURLOPT_CONNECTTIMEOUT=>5, CURLOPT_TIMEOUT=>8]);
                curl_multi_add_handle($multi, $curl);
                $handles[$index] = $curl;
            }
            do {
                $multiStatus = curl_multi_exec($multi, $active);
                if ($active) {
                    $selected = curl_multi_select($multi, 0.35);
                    if ($selected === -1) usleep(100000);
                }
            } while ($active && $multiStatus === CURLM_OK);
            foreach ($handles as $index=>$curl) {
                $body = curl_multi_getcontent($curl);
                $http = (int)curl_getinfo($curl, CURLINFO_HTTP_CODE);
                $error = curl_error($curl);
                if ($body !== false && $http >= 200 && $http < 300) {
                    $data = json_decode((string)$body, true);
                    if (is_array($data)) {
                        $normalized = judge0_normalize_result($data);
                        $statusId = (int)($normalized['status']['id'] ?? 0);
                        if ($statusId > 2) { $results[$index] = $normalized; unset($pending[$index]); }
                        elseif ($statusId === 0 && isset($data['message'])) $fatal = new RuntimeException('Judge0 could not retrieve a queued result. Check provider access and quotas.');
                    }
                } elseif (in_array($http, [401,403], true)) {
                    $fatal = new RuntimeException('Judge0 rejected result polling. Check the API key and authentication headers.');
                } elseif ($http === 429) {
                    // Transient provider limit: retry until timeout.
                } elseif ($error !== '' && $http === 0) {
                    // Transient network failure: retry until timeout.
                }
                curl_multi_remove_handle($multi, $curl);
                curl_close($curl);
            }
            curl_multi_close($multi);
        }
        if ($fatal) throw $fatal;
        if ($pending) usleep(450000);
    }
    if ($pending) throw new RuntimeException('Judge0 is still processing one or more test cases. No grade was saved. Please retry in a moment.');
    return $results;
}
