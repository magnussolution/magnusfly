<?php
declare(strict_types=1);
require dirname(__DIR__) . '/bootstrap.php';

magnusfly_run(function (): void {
    $input = magnusfly_json_input();
    $token = magnusfly_require_string($input, 'pilotToken');
    $pdo = magnusfly_db();
    if (($input['stopped'] ?? false) === true) {
        $statement = $pdo->prepare(
            'UPDATE tow_sessions SET pilot_stopped_at = COALESCE(pilot_stopped_at, CURRENT_TIMESTAMP) WHERE pilot_token = ? AND status = ?'
        );
        $statement->execute([$token, 'ended']);
    }
    $statement = $pdo->prepare('SELECT status FROM tow_sessions WHERE pilot_token = ?');
    $statement->execute([$token]);
    $session = $statement->fetch();
    if (!$session) {
        magnusfly_error('session_not_found', 'Session was not found.', 404);
    }
    magnusfly_response(['ok' => true, 'status' => $session['status']]);
});
