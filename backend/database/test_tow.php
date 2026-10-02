<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require dirname(__DIR__) . '/api/bootstrap.php';
function check($condition, string $message): void {
    if (!$condition) { throw new RuntimeException($message); }
}
function call_api(string $path, array $body): array {
    $context = stream_context_create(['http' => ['method' => 'POST', 'timeout' => 10,
        'header' => "Content-Type: application/json\r\n", 'content' => json_encode($body), 'ignore_errors' => true]]);
    $result = file_get_contents('https://magnussolution.com/magnusfly/api/' . $path, false, $context);
    $json = json_decode($result, true);
    check(is_array($json), 'Expected API JSON');
    return $json;
}
$pdo = magnusfly_db();
$username = 'towtest_' . bin2hex(random_bytes(5));
try {
    $insert = $pdo->prepare('INSERT INTO pilot_profiles (username,name,email,country,password_hash) VALUES (?,?,?,?,?)');
    $insert->execute([$username, 'Tow integration test', $username . '@example.com', 'TEST', password_hash(bin2hex(random_bytes(16)), PASSWORD_DEFAULT)]);
    $created = call_api('sessions/create.php', ['pilotUsername' => $username]);
    $driver = $created['session']['driverToken'];
    $accepted = call_api('sessions/accept.php', ['pilotUsername' => $username]);
    $pilot = $accepted['session']['pilotToken'];
    check($accepted['session']['status'] === 'active', 'Acceptance must activate immediately');
    $sample = ['pilotToken' => $pilot, 'varioMps' => 1.2, 'aglM' => 100,
        'location' => ['latitude' => -30, 'longitude' => -60, 'accuracy' => 4, 'ageMs' => 100]];
    check(call_api('telemetry/pilot.php', $sample)['status'] === 'active', 'Telemetry rejected');
    $latest = json_decode(file_get_contents('https://magnussolution.com/magnusfly/api/telemetry/latest.php?driverToken=' . rawurlencode($driver)), true);
    check($latest['telemetry']['location']['latitude'] === -30, 'GPS roundtrip');
    check(call_api('sessions/pilot-status.php', ['pilotToken' => $pilot])['status'] === 'active', 'Status check must not stop tow');
    $finished = call_api('sessions/finish.php', ['driverToken' => $driver]);
    check($finished['pilotStopped'] === false, 'Cannot confirm before pilot stops');
    check(call_api('telemetry/pilot.php', $sample)['status'] === 'ended', 'Late telemetry must be rejected');
    $count = $pdo->prepare('SELECT COUNT(*) FROM pilot_telemetry WHERE session_id = ?');
    $count->execute([$created['session']['id']]);
    check((int) $count->fetchColumn() === 1, 'Late telemetry was stored');
    call_api('sessions/pilot-status.php', ['pilotToken' => $pilot, 'stopped' => true]);
    check(call_api('sessions/finish.php', ['driverToken' => $driver])['pilotStopped'] === true, 'Stop confirmation missing');
    check(call_api('sessions/finish.php', ['driverToken' => 'invalid'])['ok'] === false, 'Invalid capability accepted');
    $waiting = call_api('sessions/create.php', ['pilotUsername' => $username]);
    check(call_api('sessions/finish.php', ['driverToken' => $waiting['session']['driverToken']])['pilotStopped'] === true, 'Waiting cancellation should not require pilot ack');
    check(call_api('sessions/accept.php', ['pilotUsername' => $username])['ok'] === false, 'Ended invitation accepted');
    echo "PASS: immediate acceptance, GPS, manual finish, late packets, confirmation, idempotency, invalid tokens.\n";
} finally {
    $delete = $pdo->prepare('DELETE FROM tow_sessions WHERE pilot_username = ?');
    $delete->execute([$username]);
    $delete = $pdo->prepare('DELETE FROM pilot_profiles WHERE username = ?');
    $delete->execute([$username]);
}
