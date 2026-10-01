<?php

declare(strict_types=1);

require dirname(__DIR__) . '/bootstrap.php';

magnusfly_run(function (): void {
    $input = magnusfly_json_input();
    $username = magnusfly_normalize_username(
        magnusfly_require_string($input, 'username')
    );
    $email = magnusfly_validate_email(magnusfly_require_string($input, 'email'));
    $password = magnusfly_require_string($input, 'password');
    $pdo = magnusfly_db();

    $pdo->beginTransaction();
    try {
        $statement = $pdo->prepare(
            'SELECT id, email, password_hash FROM pilot_profiles
             WHERE username = ? LIMIT 1 FOR UPDATE'
        );
        $statement->execute([$username]);
        $pilot = $statement->fetch();
        if (!$pilot || !hash_equals(strtolower($pilot['email']), strtolower($email))
            || !password_verify($password, $pilot['password_hash'])) {
            $pdo->rollBack();
            magnusfly_error('invalid_credentials', 'Account details are invalid.', 401);
        }

        $statement = $pdo->prepare('DELETE FROM tow_sessions WHERE pilot_username = ?');
        $statement->execute([$username]);
        $statement = $pdo->prepare('DELETE FROM pilot_profiles WHERE id = ?');
        $statement->execute([$pilot['id']]);
        $pdo->commit();
    } catch (Throwable $exception) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $exception;
    }

    magnusfly_response(['ok' => true, 'deleted' => true]);
});
