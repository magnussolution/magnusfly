<?php
declare(strict_types=1);
require dirname(__DIR__) . '/bootstrap.php';

magnusfly_run(function (): void {
    $input = magnusfly_json_input();
    $token = magnusfly_require_string($input, 'driverToken');
    $pdo = magnusfly_db();
    $statement = $pdo->prepare(
        'UPDATE tow_sessions SET ended_at = COALESCE(ended_at, CURRENT_TIMESTAMP), status = ? WHERE driver_token = ?'
    );
    $statement->execute(['ended', $token]);
    $statement = $pdo->prepare('SELECT pilot_token, pilot_stopped_at FROM tow_sessions WHERE driver_token = ?');
    $statement->execute([$token]);
    $session = $statement->fetch();
    if (!$session) {
        magnusfly_error('session_not_found', 'Session was not found.', 404);
    }
    magnusfly_response(['ok' => true, 'status' => 'ended',
        'pilotStopped' => $session['pilot_token'] === null || $session['pilot_stopped_at'] !== null]);
});
