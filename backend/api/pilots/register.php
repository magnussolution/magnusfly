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
    $password = magnusfly_require_password($input);
    $passwordHash = password_hash($password, PASSWORD_DEFAULT);

    $pdo = magnusfly_db();
    $statement = $pdo->prepare(
        'INSERT INTO pilot_profiles (username, name, email, country, password_hash)
         VALUES (?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE
            name = VALUES(name),
            email = VALUES(email),
            country = VALUES(country),
            password_hash = VALUES(password_hash)'
    );
    $statement->execute([$username, $name, $email, $country, $passwordHash]);

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
