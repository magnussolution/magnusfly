<?php

declare(strict_types=1);

require dirname(__DIR__) . '/bootstrap.php';

magnusfly_run(function (): void {
    $input = magnusfly_json_input();
    $code = strtoupper(magnusfly_require_string($input, 'code'));
    $pilotToken = magnusfly_token();

    $pdo = magnusfly_db();
    $statement = $pdo->prepare(
        'SELECT id, status FROM tow_sessions WHERE code = ? LIMIT 1'
    );
    $statement->execute([$code]);
    $session = $statement->fetch();
    if (!$session) {
        magnusfly_error('session_not_found', 'Session code was not found.', 404);
    }

    if ($session['status'] !== 'waiting') {
        magnusfly_error('session_not_waiting', 'Session is not waiting for a Pilot.', 409);
    }

    $update = $pdo->prepare(
        'UPDATE tow_sessions SET pilot_token = ?, status = ?, accepted_at = CURRENT_TIMESTAMP WHERE id = ?'
    );
    $update->execute([$pilotToken, 'active', $session['id']]);

    magnusfly_response([
        'ok' => true,
        'session' => [
            'id' => (int) $session['id'],
            'code' => $code,
            'pilotToken' => $pilotToken,
            'status' => 'active',
        ],
    ]);
});
