<?php

declare(strict_types=1);

require __DIR__ . '/bootstrap.php';

magnusfly_run(function (): void {
    $pdo = magnusfly_db();
    $pdo->query('SELECT 1');

    magnusfly_response([
        'ok' => true,
        'service' => 'magnusfly',
    ]);
});
