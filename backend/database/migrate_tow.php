<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require dirname(__DIR__) . '/api/bootstrap.php';
$pdo = magnusfly_db();
foreach ([['tow_sessions', 'pilot_stopped_at', 'TIMESTAMP NULL DEFAULT NULL'],
          ['pilot_telemetry', 'location_json', 'TEXT NULL']] as $column) {
    $check = $pdo->prepare('SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?');
    $check->execute([$column[0], $column[1]]);
    if ((int) $check->fetchColumn() === 0) {
        $pdo->exec('ALTER TABLE ' . $column[0] . ' ADD COLUMN ' . $column[1] . ' ' . $column[2]);
    }
}
echo "Tow schema ready.\n";
