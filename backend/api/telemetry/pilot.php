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
    $location = $input['location'] ?? null;
    if ($location !== null) {
        if (!is_array($location)) {
            magnusfly_error('invalid_location', 'Invalid location.', 400);
        }
        foreach (['latitude', 'longitude', 'accuracy', 'ageMs'] as $key) {
            if (!isset($location[$key]) || !is_numeric($location[$key]) || !is_finite((float) $location[$key])) {
                magnusfly_error('invalid_location', 'Invalid location.', 400);
            }
        }
        if (abs((float) $location['latitude']) > 90 || abs((float) $location['longitude']) > 180
            || $location['accuracy'] < 0 || $location['ageMs'] < 0) {
            magnusfly_error('invalid_location', 'Invalid location.', 400);
        }
        $location = array_intersect_key($location, array_flip(['latitude', 'longitude', 'accuracy', 'ageMs']));
    }
    $pdo->beginTransaction();
    $statement = $pdo->prepare(
        'SELECT id, status FROM tow_sessions WHERE pilot_token = ? LIMIT 1 FOR UPDATE'
    );
    $statement->execute([$pilotToken]);
    $session = $statement->fetch();
    if (!$session) {
        $pdo->rollBack();
        magnusfly_error('session_not_active', 'Pilot session is not active.', 404);
    }
    if ($session['status'] === 'ended') {
        $pdo->commit();
        magnusfly_response(['ok' => true, 'status' => 'ended']);
    }

    $insert = $pdo->prepare(
        'INSERT INTO pilot_telemetry
            (session_id, vario_mps, agl_m, pressure_hpa, relative_altitude_m, client_timestamp_ms, location_json)
         VALUES (?, ?, ?, ?, ?, ?, ?)'
    );
    $insert->execute([
        $session['id'],
        $varioMps,
        $aglM,
        $pressureHpa,
        $relativeAltitudeM,
        $clientTimestampMs,
        $location === null ? null : json_encode($location),
    ]);

    $update = $pdo->prepare(
        'UPDATE tow_sessions SET last_seen_at = CURRENT_TIMESTAMP WHERE id = ?'
    );
    $update->execute([$session['id']]);
    $pdo->commit();

    magnusfly_response(['ok' => true, 'status' => 'active'], 201);
});
