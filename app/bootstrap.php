<?php
declare(strict_types=1);

$configPath = __DIR__ . '/../config/config.php';
if (!file_exists($configPath)) {
    http_response_code(500);
    exit('Missing config/config.php. Copy config/config.example.php to config/config.php and configure it.');
}
$config = require $configPath;
date_default_timezone_set($config['timezone'] ?? 'Asia/Manila');
if (!headers_sent()) {
    header('X-Content-Type-Options: nosniff');
    header('Referrer-Policy: strict-origin-when-cross-origin');
    header('X-Frame-Options: SAMEORIGIN');
    header('Permissions-Policy: camera=(), microphone=(), geolocation=()');
}

ini_set('session.use_strict_mode', '1');
session_name($config['session_name'] ?? 'codearena_session');
$isHttps = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== '' && strtolower((string)$_SERVER['HTTPS']) !== 'off';
session_set_cookie_params([
    'lifetime' => 0,
    'path' => '/',
    'secure' => $isHttps,
    'httponly' => true,
    'samesite' => 'Lax',
]);
session_start();

$dsn = sprintf(
    'mysql:host=%s;port=%s;dbname=%s;charset=%s',
    $config['db']['host'], $config['db']['port'], $config['db']['name'], $config['db']['charset']
);
try {
    $pdo = new PDO($dsn, $config['db']['user'], $config['db']['pass'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    exit('Database connection failed. Check config/config.php and make sure MySQL is running.');
}
// Keep MySQL's NOW()/CURRENT_TIMESTAMP aligned with PHP so classroom due dates
// and timestamps use the app's configured timezone (Asia/Manila by default).
try {
    $mysqlOffset = (new DateTimeImmutable('now'))->format('P');
    $pdo->exec('SET time_zone = ' . $pdo->quote($mysqlOffset));
} catch (PDOException $ignored) {
    // The app still starts on servers that restrict session time-zone settings.
}

require_once __DIR__ . '/helpers.php';
