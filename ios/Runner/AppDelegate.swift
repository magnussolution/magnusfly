import Flutter
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

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    configurePilotBackgroundChannels(engineBridge.applicationRegistrar.messenger())
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
