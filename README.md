# MagnusFly

MagnusFly is a simple remote variometer app for paraglider towing.

The pilot phone reads sensors, calculates VARIO and AGL, and transmits data in real time. The driver phone receives the pilot data and shows connection delays or loss immediately.

## Operational Model

The same user can be either Pilot or Driver depending on the flight.

The role is defined by the connection flow:

- The user who starts the connection is the Driver.
- The user who accepts the transmission request is the Pilot.
- The Pilot only accepts transmission and sends sensor data. The Pilot does not initiate or configure the towing session.

During flight, the Pilot will often keep another flight app open, such as XCTrack or Flyskyhy. MagnusFly must support the Pilot transmission flow with minimal interaction and must be designed to keep transmitting while the Pilot uses another app.

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
