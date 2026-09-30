# MagnusFly

MagnusFly is a simple remote variometer app for paraglider towing.

The pilot phone reads sensors, calculates VARIO and AGL, and transmits data in real time. The driver phone receives the pilot data and shows connection delays or loss immediately.

## Security

This repository is public. Do not commit secrets, credentials, private keys, certificates, database passwords, Apple credentials, or Google credentials.

Runtime backend configuration must exist only on the server:

```text
/var/www/html/magnusfly/.env
```

The committed `.env.example` file contains placeholders only.

## Backend

Production server path:

```text
/var/www/html/magnusfly/
```

Initial production endpoints:

```text
https://magnusbilling.org/magnusfly/api/
wss://magnusbilling.org/magnusfly/ws
```

Use HTTPS/WSS in production.

## Development

Main branch:

```text
main
```

Flutter package name:

```text
com.magnussolution.magnusfly
```
