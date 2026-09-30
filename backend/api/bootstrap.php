<?php

declare(strict_types=1);

function magnusfly_env_path(): string
{
    return dirname(__DIR__) . '/.env';
}

function magnusfly_load_env(): array
{
    $path = magnusfly_env_path();
    if (!is_file($path)) {
        throw new RuntimeException('Server configuration is missing.');
    }

    $env = [];
    $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        $line = trim($line);
        if ($line === '' || strpos($line, '#') === 0) {
            continue;
        }

        $parts = explode('=', $line, 2);
        if (count($parts) !== 2) {
            continue;
        }

        $env[trim($parts[0])] = trim($parts[1]);
    }

    return $env;
}

function magnusfly_db(): PDO
{
    static $pdo = null;
    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $env = magnusfly_load_env();
    $host = $env['DB_HOST'] ?? 'localhost';
    $port = $env['DB_PORT'] ?? '3306';
    $database = $env['DB_DATABASE'] ?? 'magnusfly';
    $username = $env['DB_USERNAME'] ?? 'magnusfly';
    $password = $env['DB_PASSWORD'] ?? '';

    $dsn = sprintf(
        'mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
        $host,
        $port,
        $database
    );

    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);

    return $pdo;
}

function magnusfly_json_input(): array
{
    $raw = file_get_contents('php://input');
    if ($raw === false || trim($raw) === '') {
        return [];
    }

    $data = json_decode($raw, true);
    if (!is_array($data)) {
        magnusfly_error('invalid_json', 'Request body must be valid JSON.', 400);
    }

    return $data;
}

function magnusfly_response(array $payload, int $status = 200): void
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store');
    echo json_encode($payload, JSON_UNESCAPED_SLASHES);
    exit;
}

function magnusfly_error(string $code, string $message, int $status): void
{
    magnusfly_response([
        'ok' => false,
        'error' => [
            'code' => $code,
            'message' => $message,
        ],
    ], $status);
}

function magnusfly_require_string(array $data, string $key): string
{
    if (!isset($data[$key]) || !is_string($data[$key]) || trim($data[$key]) === '') {
        magnusfly_error('missing_field', sprintf('Missing required field: %s.', $key), 400);
    }

    return trim($data[$key]);
}

function magnusfly_require_number(array $data, string $key): float
{
    if (!isset($data[$key]) || !is_numeric($data[$key])) {
        magnusfly_error('missing_field', sprintf('Missing numeric field: %s.', $key), 400);
    }

    return (float) $data[$key];
}

function magnusfly_token(): string
{
    return bin2hex(random_bytes(32));
}

function magnusfly_session_code(PDO $pdo): string
{
    $alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    for ($attempt = 0; $attempt < 20; $attempt++) {
        $code = '';
        for ($i = 0; $i < 6; $i++) {
            $code .= $alphabet[random_int(0, strlen($alphabet) - 1)];
        }

        $statement = $pdo->prepare('SELECT id FROM tow_sessions WHERE code = ? LIMIT 1');
        $statement->execute([$code]);
        if (!$statement->fetch()) {
            return $code;
        }
    }

    throw new RuntimeException('Could not allocate a session code.');
}

function magnusfly_run(callable $handler): void
{
    try {
        $handler();
    } catch (Throwable $exception) {
        error_log($exception->getMessage());
        magnusfly_error('server_error', 'Unexpected server error.', 500);
    }
}
