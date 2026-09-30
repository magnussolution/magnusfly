<?php

declare(strict_types=1);

require dirname(__DIR__) . '/bootstrap.php';

magnusfly_run(function (): void {
    $input = magnusfly_json_input();
    $pilotUsername = magnusfly_normalize_username(
        magnusfly_require_string($input, 'pilotUsername')
    );

    $pdo = magnusfly_db();
    $pilotStatement = $pdo->prepare(
        'SELECT id FROM pilot_profiles WHERE username = ? LIMIT 1'
    );
    $pilotStatement->execute([$pilotUsername]);
    if (!$pilotStatement->fetch()) {
        magnusfly_error('pilot_not_found', 'Pilot username was not found.', 404);
    }

    $code = magnusfly_session_code($pdo);
    $driverToken = magnusfly_token();

    $statement = $pdo->prepare(
        'INSERT INTO tow_sessions (code, pilot_username, driver_token, status)
         VALUES (?, ?, ?, ?)'
    );
    $statement->execute([$code, $pilotUsername, $driverToken, 'waiting']);

    magnusfly_response([
        'ok' => true,
        'session' => [
            'id' => (int) $pdo->lastInsertId(),
            'code' => $code,
            'pilotUsername' => $pilotUsername,
            'driverToken' => $driverToken,
            'status' => 'waiting',
        ],
    ], 201);
});
