<?php
declare(strict_types=1);

/*
 * Copy this file to config.php and edit values.
 * Never commit config.php or publish your Judge0 API key.
 */
return [
    'app_name' => 'CodeArena',
    'timezone' => 'Asia/Manila',
    'base_url' => '/CodeArena/public',
    'session_name' => 'codearena_session',
    'db' => [
        'host' => '127.0.0.1',
        'port' => '3306',
        'name' => 'codearena',
        'user' => 'root',
        'pass' => '',
        'charset' => 'utf8mb4',
    ],
    'judge0' => [
        // Use the exact endpoint supplied by your Judge0 provider.
        // Example self-hosted base URL: http://localhost:2358
        'base_url' => 'https://judge0-ce.p.rapidapi.com',
        'api_key' => 'PUT_YOUR_API_KEY_HERE',
        'auth_header' => 'X-RapidAPI-Key',
        'extra_headers' => [
            // For RapidAPI, you may also need X-RapidAPI-Host.
            // 'X-RapidAPI-Host: judge0-ce.p.rapidapi.com',
        ],
        'languages' => [
            'c' => 50,
            'cpp' => 54,
            'java' => 62,
            'python' => 71,
            'php' => 68,
            'ruby' => 72,
        ],
    ],
];
