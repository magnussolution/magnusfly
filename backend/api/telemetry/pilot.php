<?php

declare(strict_types=1);

require dirname(__DIR__) . '/bootstrap.php';

magnusfly_run(function (): void {
    $input = magnusfly_json_input();
    $pilotToken = magnusfly_require_string($input, 'pilotToken');
    $varioMps = magnusfly_require_number($input, 'varioMps');
    $aglM = magnusfly_require_number($input, 'aglM');
    $pressureHpa = isset($input['pressureHpa']) && is_numeric($input['pressureHpa'])
        ? (float) $input['pressureHpa']
        : null;
    $relativeAltitudeM = isset($input['relativeAltitudeM']) && is_numeric($input['relativeAltitudeM'])
        ? (float) $input['relativeAltitudeM']
        : null;
    $clientTimestampMs = isset($input['timestampMillis']) && is_numeric($input['timestampMillis'])
        ? (int) $input['timestampMillis']
        : null;

    $pdo = magnusfly_db();
    $statement = $pdo->prepare(
        'SELECT id FROM tow_sessions WHERE pilot_token = ? AND status = ? LIMIT 1'
    );
    $statement->execute([$pilotToken, 'active']);
    $session = $statement->fetch();
    if (!$session) {
        magnusfly_error('session_not_active', 'Pilot session is not active.', 404);
    }

    $insert = $pdo->prepare(
        'INSERT INTO pilot_telemetry
            (session_id, vario_mps, agl_m, pressure_hpa, relative_altitude_m, client_timestamp_ms)
         VALUES (?, ?, ?, ?, ?, ?)'
    );
    $insert->execute([
        $session['id'],
        $varioMps,
        $aglM,
        $pressureHpa,
        $relativeAltitudeM,
        $clientTimestampMs,
    ]);

    $update = $pdo->prepare(
        'UPDATE tow_sessions SET last_seen_at = CURRENT_TIMESTAMP WHERE id = ?'
    );
    $update->execute([$session['id']]);

    magnusfly_response(['ok' => true], 201);
});
