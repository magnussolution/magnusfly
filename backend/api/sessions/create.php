<?php

declare(strict_types=1);

require dirname(__DIR__) . '/bootstrap.php';

magnusfly_run(function (): void {
    $pdo = magnusfly_db();
    $code = magnusfly_session_code($pdo);
    $driverToken = magnusfly_token();

    $statement = $pdo->prepare(
        'INSERT INTO tow_sessions (code, driver_token, status) VALUES (?, ?, ?)'
    );
    $statement->execute([$code, $driverToken, 'waiting']);

    magnusfly_response([
        'ok' => true,
        'session' => [
            'id' => (int) $pdo->lastInsertId(),
            'code' => $code,
            'driverToken' => $driverToken,
            'status' => 'waiting',
        ],
    ], 201);
});
