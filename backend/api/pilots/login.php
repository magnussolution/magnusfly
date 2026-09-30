<?php

declare(strict_types=1);

require dirname(__DIR__) . '/bootstrap.php';

magnusfly_run(function (): void {
    $input = magnusfly_json_input();
    $username = magnusfly_normalize_username(
        magnusfly_require_string($input, 'username')
    );
    $password = magnusfly_require_string($input, 'password');

    $pdo = magnusfly_db();
    $statement = $pdo->prepare(
        'SELECT username, name, email, country, password_hash
         FROM pilot_profiles
         WHERE username = ?
         LIMIT 1'
    );
    $statement->execute([$username]);
    $pilot = $statement->fetch();

    if (!$pilot) {
        magnusfly_error('pilot_not_found', 'Pilot username was not found.', 404);
    }

    if (!password_verify($password, $pilot['password_hash'])) {
        magnusfly_error('invalid_login', 'Username or password is invalid.', 401);
    }

    magnusfly_response([
        'ok' => true,
        'pilot' => [
            'username' => $pilot['username'],
            'name' => $pilot['name'],
            'email' => $pilot['email'],
            'country' => $pilot['country'],
        ],
    ]);
});
