<?php

declare(strict_types=1);

require dirname(__DIR__) . '/bootstrap.php';

magnusfly_run(function (): void {
    $input = magnusfly_json_input();
    $username = magnusfly_normalize_username(
        magnusfly_require_string($input, 'username')
    );
    $name = magnusfly_require_string($input, 'name');
    $email = magnusfly_validate_email(
        magnusfly_require_string($input, 'email')
    );
    $country = magnusfly_require_string($input, 'country');

    $pdo = magnusfly_db();
    $statement = $pdo->prepare(
        'INSERT INTO pilot_profiles (username, name, email, country)
         VALUES (?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE
            name = VALUES(name),
            email = VALUES(email),
            country = VALUES(country)'
    );
    $statement->execute([$username, $name, $email, $country]);

    magnusfly_response([
        'ok' => true,
        'pilot' => [
            'username' => $username,
            'name' => $name,
            'email' => $email,
            'country' => $country,
        ],
    ]);
});
