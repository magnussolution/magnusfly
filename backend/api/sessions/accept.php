<?php

declare(strict_types=1);

require dirname(__DIR__) . '/bootstrap.php';

magnusfly_run(function (): void {
    $input = magnusfly_json_input();
    $pilotUsername = magnusfly_normalize_username(
        magnusfly_require_string($input, 'pilotUsername')
    );
    $pilotToken = magnusfly_token();

    $pdo = magnusfly_db();
    $statement = $pdo->prepare(
        'SELECT id, code, status
         FROM tow_sessions
         WHERE pilot_username = ? AND status = ?
         ORDER BY id DESC
         LIMIT 1'
    );
    $statement->execute([$pilotUsername, 'waiting']);
    $session = $statement->fetch();
    if (!$session) {
        magnusfly_error(
            'session_not_found',
            'No waiting Driver session was found for this Pilot.',
            404
        );
    }

    $update = $pdo->prepare(
        'UPDATE tow_sessions SET pilot_token = ?, status = ?, accepted_at = CURRENT_TIMESTAMP WHERE id = ?'
    );
    $update->execute([$pilotToken, 'active', $session['id']]);

    magnusfly_response([
        'ok' => true,
        'session' => [
            'id' => (int) $session['id'],
            'code' => $session['code'],
            'pilotUsername' => $pilotUsername,
            'pilotToken' => $pilotToken,
            'status' => 'active',
        ],
    ]);
});
