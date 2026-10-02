<?php

declare(strict_types=1);

require dirname(__DIR__) . '/bootstrap.php';

magnusfly_run(function (): void {
    $driverToken = isset($_GET['driverToken']) && is_string($_GET['driverToken'])
        ? trim($_GET['driverToken'])
        : '';
    if ($driverToken === '') {
        magnusfly_error('missing_field', 'Missing required query parameter: driverToken.', 400);
    }

    $pdo = magnusfly_db();
    $statement = $pdo->prepare(
        'SELECT id, code, status, pilot_token, pilot_stopped_at, UNIX_TIMESTAMP(last_seen_at) AS last_seen_unix
         FROM tow_sessions
         WHERE driver_token = ?
         LIMIT 1'
    );
    $statement->execute([$driverToken]);
    $session = $statement->fetch();
    if (!$session) {
        magnusfly_error('session_not_found', 'Session was not found.', 404);
    }

    $telemetryStatement = $pdo->prepare(
        'SELECT id, location_json, vario_mps, agl_m, pressure_hpa, relative_altitude_m, client_timestamp_ms,
                UNIX_TIMESTAMP(received_at) AS received_unix
         FROM pilot_telemetry
         WHERE session_id = ?
         ORDER BY id DESC
         LIMIT 1'
    );
    $telemetryStatement->execute([$session['id']]);
    $telemetry = $telemetryStatement->fetch();

    magnusfly_response([
        'ok' => true,
        'session' => [
            'id' => (int) $session['id'],
            'code' => $session['code'],
            'status' => $session['status'],
            'pilotStopped' => $session['status'] === 'ended' && ($session['pilot_token'] === null || $session['pilot_stopped_at'] !== null),
            'lastSeenAgeMs' => $session['last_seen_unix'] === null
                ? null
                : max(0, (time() - (int) $session['last_seen_unix']) * 1000),
        ],
        'telemetry' => $telemetry ? [
            'id' => (int) $telemetry['id'],
            'location' => $telemetry['location_json'] === null ? null : json_decode($telemetry['location_json'], true),
            'varioMps' => (float) $telemetry['vario_mps'],
            'aglM' => (float) $telemetry['agl_m'],
            'pressureHpa' => $telemetry['pressure_hpa'] === null ? null : (float) $telemetry['pressure_hpa'],
            'relativeAltitudeM' => $telemetry['relative_altitude_m'] === null ? null : (float) $telemetry['relative_altitude_m'],
            'timestampMillis' => $telemetry['client_timestamp_ms'] === null ? null : (int) $telemetry['client_timestamp_ms'],
            'receivedAgeMs' => max(0, (time() - (int) $telemetry['received_unix']) * 1000),
        ] : null,
    ]);
});
