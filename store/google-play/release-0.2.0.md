# MagnusFly 0.2.0 (4)

## Implemented

- Pilot transmission starts upon acceptance, independently of vehicle motion.
- Driver GPS and pilot GPS estimate horizontal distance, line length and angle
  using a flat-terrain assumption and barometric height above the start point.
- Angle bands: below 30 orange; 30 through 50 green; above 50 red.
- Angle smoothing and trend arrow; stale/inaccurate fixes hide geometry.
- Samples expire after 3 seconds; GPS accuracy must be within 20 m, position
  ages within 3 seconds and position times within 2 seconds. These are initial
  engineering thresholds, not a validated towing safety envelope.
- Independent connection-loss sound, mute and reconnection indication.
- Driver manual finish with durable retry and pilot sensor shutdown confirmation.
- Local driver history, scoped to the signed-in username: AGL, VARIO, angle,
  line length, horizontal distance and connection gaps, with time-series charts.
- Server pilot telemetry retains GPS; local history does not store raw GPS.

## Distribution

Both phones must use 0.2.0 for GPS and confirmed remote shutdown. Older pilot
builds cannot acknowledge the finish command. Do not publish this as a safety
certification. Validate real GPS accuracy, background operation, audio and
offline/reconnect/manual finish on two physical devices before flight use.

The API migration is deployed independently and remains compatible with older
active telemetry clients. This release adds foreground location use: update
Google Play Data Safety and foreground service declarations and supply a new
Android demonstration of that feature before submitting this version.

## Notes

<pt-BR>
Ângulo e corda estimados, alarme de perda de conexão, histórico de reboques e encerramento manual confirmado pelo piloto.
</pt-BR>
<en-US>
Estimated tow angle and line length, connection-loss alarm, tow history and manual finish with pilot confirmation.
</en-US>
<es-419>
Ángulo y cuerda estimados, alarma de pérdida de conexión, historial y finalización manual confirmada por el piloto.
</es-419>
