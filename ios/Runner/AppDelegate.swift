import Flutter
import AVFoundation
import CoreMotion
import CoreLocation
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, FlutterStreamHandler, CLLocationManagerDelegate {
  private let altimeter = CMAltimeter()
  private let locationManager = CLLocationManager()
  private var barometerEventSink: FlutterEventSink?
  private var pilotBackgroundTask: UIBackgroundTaskIdentifier = .invalid
  private var pilotEngineRunning = false
  private let varioAudioEngine = AVAudioEngine()
  private var varioAudioNodes: [AVAudioPlayerNode] = []

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    configurePilotBackgroundChannels(engineBridge.applicationRegistrar.messenger())
    configureDriverVarioAudioChannel(engineBridge.applicationRegistrar.messenger())
  }

  private func configureDriverVarioAudioChannel(_ messenger: FlutterBinaryMessenger) {
    let methodChannel = FlutterMethodChannel(
      name: "com.magnussolution.magnusfly/driver_vario_audio",
      binaryMessenger: messenger
    )
    methodChannel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "unavailable", message: "Vario audio is unavailable.", details: nil))
        return
      }

      switch call.method {
      case "playBeep":
        guard
          let arguments = call.arguments as? [String: Any],
          let frequencyHz = arguments["frequencyHz"] as? Double,
          let durationMs = arguments["durationMs"] as? Int
        else {
          result(FlutterError(code: "invalid_arguments", message: "Invalid beep arguments.", details: nil))
          return
        }

        let volume = arguments["volume"] as? Double ?? 0.7
        self.playDriverVarioBeep(
          frequencyHz: frequencyHz,
          durationMs: durationMs,
          volume: volume
        )
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func playDriverVarioBeep(frequencyHz: Double, durationMs: Int, volume: Double) {
    let sampleRate = 44100.0
    let durationSeconds = max(0.03, Double(durationMs) / 1000.0)
    let frameCount = AVAudioFrameCount(sampleRate * durationSeconds)
    guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
          let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount),
          let samples = buffer.floatChannelData?[0] else {
      return
    }

    buffer.frameLength = frameCount
    let amplitude = Float(max(0, min(volume, 1)) * 0.35)
    let fadeFrames = max(1, Int(sampleRate * 0.006))

    for frame in 0..<Int(frameCount) {
      let progress = Double(frame) / sampleRate
      let envelopeIn = min(1.0, Double(frame) / Double(fadeFrames))
      let envelopeOut = min(1.0, Double(Int(frameCount) - frame) / Double(fadeFrames))
      let envelope = Float(min(envelopeIn, envelopeOut))
      samples[frame] = Float(sin(2.0 * Double.pi * frequencyHz * progress)) * amplitude * envelope
    }

    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      return
    }

    let playerNode = AVAudioPlayerNode()
    varioAudioNodes.append(playerNode)
    varioAudioEngine.attach(playerNode)
    varioAudioEngine.connect(playerNode, to: varioAudioEngine.mainMixerNode, format: format)

    if !varioAudioEngine.isRunning {
      do {
        try varioAudioEngine.start()
      } catch {
        varioAudioEngine.detach(playerNode)
        varioAudioNodes.removeAll { $0 === playerNode }
        return
      }
    }

    playerNode.scheduleBuffer(buffer, at: nil, options: []) { [weak self, weak playerNode] in
      DispatchQueue.main.async {
        guard let self, let playerNode else {
          return
        }

        playerNode.stop()
        self.varioAudioEngine.detach(playerNode)
        self.varioAudioNodes.removeAll { $0 === playerNode }
      }
    }
    playerNode.play()
  }

  private func configurePilotBackgroundChannels(_ messenger: FlutterBinaryMessenger) {
    let methodChannel = FlutterMethodChannel(
      name: "com.magnussolution.magnusfly/pilot_background",
      binaryMessenger: messenger
    )
    methodChannel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "unavailable", message: "Pilot engine is unavailable.", details: nil))
        return
      }

      switch call.method {
      case "isAvailable":
        result(CMAltimeter.isRelativeAltitudeAvailable())
      case "isRunning":
        result(self.pilotEngineRunning)
      case "start":
        self.startPilotEngine(result)
      case "stop":
        self.stopPilotEngine()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let eventChannel = FlutterEventChannel(
      name: "com.magnussolution.magnusfly/pilot_barometer",
      binaryMessenger: messenger
    )
    eventChannel.setStreamHandler(self)
  }

  private func startPilotEngine(_ result: @escaping FlutterResult) {
    guard CMAltimeter.isRelativeAltitudeAvailable() else {
      result(FlutterError(
        code: "barometer_unavailable",
        message: "This iOS device does not expose relative altitude data.",
        details: nil
      ))
      return
    }

    if pilotEngineRunning {
      result(nil)
      return
    }

    beginPilotBackgroundTask()
    startLocationKeepAlive()
    pilotEngineRunning = true

    altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { [weak self] data, error in
      guard let self else {
        return
      }

      if let error {
        self.barometerEventSink?(FlutterError(
          code: "barometer_error",
          message: error.localizedDescription,
          details: nil
        ))
        return
      }

      guard let data else {
        return
      }

      self.barometerEventSink?([
        "pressureHpa": data.pressure.doubleValue * 10,
        "relativeAltitudeMeters": data.relativeAltitude.doubleValue,
        "timestampMillis": Int(Date().timeIntervalSince1970 * 1000),
      ])
    }

    result(nil)
  }

  private func stopPilotEngine() {
    guard pilotEngineRunning else {
      return
    }

    altimeter.stopRelativeAltitudeUpdates()
    stopLocationKeepAlive()
    pilotEngineRunning = false
    endPilotBackgroundTask()
  }

  private func startLocationKeepAlive() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.pausesLocationUpdatesAutomatically = false

    if #available(iOS 9.0, *) {
      locationManager.allowsBackgroundLocationUpdates = true
    }

    switch currentLocationAuthorizationStatus() {
    case .notDetermined:
      locationManager.requestAlwaysAuthorization()
    case .authorizedWhenInUse:
      locationManager.requestAlwaysAuthorization()
      locationManager.startUpdatingLocation()
    case .authorizedAlways:
      locationManager.startUpdatingLocation()
    case .restricted, .denied:
      break
    @unknown default:
      break
    }
  }

  private func stopLocationKeepAlive() {
    locationManager.stopUpdatingLocation()
  }

  private func currentLocationAuthorizationStatus() -> CLAuthorizationStatus {
    if #available(iOS 14.0, *) {
      return locationManager.authorizationStatus
    }

    return CLLocationManager.authorizationStatus()
  }

  private func beginPilotBackgroundTask() {
    if pilotBackgroundTask != .invalid {
      return
    }

    pilotBackgroundTask = UIApplication.shared.beginBackgroundTask(withName: "MagnusFlyPilot") { [weak self] in
      self?.stopPilotEngine()
    }
  }

  private func endPilotBackgroundTask() {
    guard pilotBackgroundTask != .invalid else {
      return
    }

    UIApplication.shared.endBackgroundTask(pilotBackgroundTask)
    pilotBackgroundTask = .invalid
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    barometerEventSink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    barometerEventSink = nil
    return nil
  }
}
