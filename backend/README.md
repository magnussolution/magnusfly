# MagnusFly backend

Public path on the server:

```text
/var/www/html/magnusfly
/var/www/html/magnussolution/magnusfly -> /var/www/html/magnusfly
```

The committed `.env.example` contains placeholders only. The real `.env` must exist only on the server:

```text
/var/www/html/magnusfly/.env
```

## Endpoints

```text
GET  /magnusfly/api/health.php
POST /magnusfly/api/sessions/create.php
POST /magnusfly/api/sessions/accept.php
POST /magnusfly/api/pilots/register.php
POST /magnusfly/api/pilots/login.php
POST /magnusfly/api/telemetry/pilot.php
GET  /magnusfly/api/telemetry/latest.php?driverToken=...
POST /magnusfly/api/sessions/finish.php
POST /magnusfly/api/sessions/pilot-status.php
```

## Database

Apply the schema on the server database `magnusfly`:

```bash
mysql magnusfly < database/schema.sql
```

For existing installations, run `php database/migrate_tow.php` before deploying
the 0.2.0 API. It adds GPS telemetry and the pilot shutdown acknowledgement,
without changing existing sessions. The migration is idempotent.

`php database/test_tow.php` exercises the live API with a temporary test account
and deletes that account and its sessions in a finally block. Run only against
the MagnusFly deployment. No credentials are printed or copied locally.

The driver finish endpoint is idempotent and marks a session ended. Pilot status
and telemetry responses expose this command. The pilot stops native sensors and
location, then acknowledges with `stopped: true`. Until that acknowledgement the
driver shows a pending state. Connection loss and stationary GPS never end a tow.
