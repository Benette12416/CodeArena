<?php
declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    exit("This setup script must be run from the command line.\n");
}
function prompt_secret(string $prompt): string {
    fwrite(STDOUT, $prompt);
    if (PHP_OS_FAMILY === 'Windows' && function_exists('shell_exec')) {
        $command = 'powershell -NoProfile -Command "$s=Read-Host -AsSecureString; $b=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($s); try {[Runtime.InteropServices.Marshal]::PtrToStringBSTR($b)} finally {[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b)}"';
        $value = shell_exec($command);
        if (is_string($value) && trim($value) !== '') return rtrim($value, "\r\n");
        fwrite(STDERR, "Hidden input unavailable; type the password visibly instead: ");
    } elseif (PHP_OS_FAMILY !== 'Windows' && function_exists('shell_exec')) {
        shell_exec('stty -echo 2>/dev/null');
        $value = fgets(STDIN);
        shell_exec('stty echo 2>/dev/null');
        fwrite(STDOUT, PHP_EOL);
        return rtrim((string)$value, "\r\n");
    }
    return rtrim((string)fgets(STDIN), "\r\n");
}

$configPath = __DIR__ . '/../config/config.php';
if (!is_file($configPath)) {
    fwrite(STDERR, "Missing config/config.php. Copy config/config.example.php to config/config.php first.\n");
    exit(1);
}
$config = require $configPath;
try {
    $dsn = sprintf('mysql:host=%s;port=%s;dbname=%s;charset=%s', $config['db']['host'], $config['db']['port'], $config['db']['name'], $config['db']['charset']);
    $pdo = new PDO($dsn, $config['db']['user'], $config['db']['pass'], [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]);
    $roles = $pdo->query("SHOW COLUMNS FROM users LIKE 'role'")->fetch();
    if (!$roles || !str_contains((string)$roles['Type'], 'super_admin')) {
        fwrite(STDERR, "The database has not been upgraded for the super_admin role. Import database/migrations/001_super_admin_role.sql in phpMyAdmin, then retry.\n");
        exit(1);
    }
    if ((int)$pdo->query("SELECT COUNT(*) FROM users WHERE role='super_admin'")->fetchColumn() > 0) {
        fwrite(STDERR, "A Super Admin account already exists. For safety, this script only creates the first Super Admin.\n");
        exit(1);
    }
    fwrite(STDOUT, 'Administrator full name: ');
    $name = trim((string)fgets(STDIN));
    fwrite(STDOUT, 'Administrator email: ');
    $email = strtolower(trim((string)fgets(STDIN)));
    $password = prompt_secret('Password (minimum 12 characters): ');
    if (mb_strlen($name) < 2 || mb_strlen($name) > 100 || !filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($password) < 12) {
        fwrite(STDERR, "Invalid details. Use a valid name and email and a password of at least 12 characters.\n");
        exit(1);
    }
    $stmt = $pdo->prepare("INSERT INTO users(name,email,password_hash,role) VALUES(?,?,?,'super_admin')");
    $stmt->execute([$name, $email, password_hash($password, PASSWORD_DEFAULT)]);
    fwrite(STDOUT, "Super Admin created successfully. Open /super-admin/login.php to sign in.\n");
} catch (Throwable $e) {
    fwrite(STDERR, "Setup failed. Check the database settings and confirm that the migration has been imported.\n");
    exit(1);
}
