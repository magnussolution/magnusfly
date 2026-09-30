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
```

## Database

Apply the schema on the server database `magnusfly`:

```bash
mysql magnusfly < database/schema.sql
```
