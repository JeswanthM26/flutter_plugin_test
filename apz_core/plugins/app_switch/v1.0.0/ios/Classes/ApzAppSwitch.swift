import Flutter
import UIKit

/** ApzAppSwitch: Handles method calls from Flutter and streams app lifecycle events. */
public class ApzAppSwitch: NSObject, FlutterPlugin, FlutterStreamHandler, ApzAppSwitchStateCallback {

  /// The MethodChannel for direct calls from Flutter (e.g., initialization).
  private var methodChannel: FlutterMethodChannel?

  /// The EventChannel for streaming lifecycle events to Flutter.
  private var eventChannel: FlutterEventChannel?

  /// The native lifecycle detector instance.
  private var lifecycleDetector: ApzAppSwitchStateDetector?

  /// The EventSink to send events back to Flutter. This is active when a Flutter listener is present.
  private var eventSink: FlutterEventSink?

  /**
   * Registers the plugin with the Flutter engine.
   * This is the entry point for native code when the Flutter app initializes the plugin.
   */
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = ApzAppSwitch()

    // Setup MethodChannel (if you add any specific method calls later, like an explicit init)
    instance.methodChannel = FlutterMethodChannel(name: "apz_app_switch_method", binaryMessenger: registrar.messenger())
    instance.methodChannel?.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        if call.method == "initialize" {
            // Acknowledge the initialization call. Actual stream setup is in onListen.
            result(nil)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    // Setup EventChannel for streaming lifecycle states
    instance.eventChannel = FlutterEventChannel(name: "apz_app_switch_events", binaryMessenger: registrar.messenger())
    // Set this class instance as the StreamHandler to manage listening and cancelling streams.
    instance.eventChannel?.setStreamHandler(instance)
  }

  // MARK: - FlutterStreamHandler Methods

  /**
   * Called when a Flutter client starts listening to the event stream.
   * This is where we initialize and start our native lifecycle detector.
   */
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events // Store the event sink

    // Initialize and register the native detector when a listener subscribes.
    // This class (ApzAppSwitch) will act as the delegate for callbacks from iOSAppLifecycleDetector.
    lifecycleDetector = ApzAppSwitchStateDetector(delegate: self)
    
    // Send the current app lifecycle state immediately upon subscription.
    let currentState = UIApplication.shared.applicationState
    switch currentState {
    case .active:
        self.eventSink?(AppLifecycleState.resumed.rawValue)
    case .inactive:
        self.eventSink?(AppLifecycleState.inactive.rawValue)
    case .background:
        self.eventSink?(AppLifecycleState.paused.rawValue)
    @unknown default:
        // Handle future cases or unexpected states, default to detached or log error
        self.eventSink?(AppLifecycleState.detached.rawValue)
    }
    
    return nil
  }

  /**
   * Called when a Flutter client stops listening to the event stream.
   * This is where we clean up native observers to prevent memory leaks.
   */
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    // Remove all observers registered by the lifecycle detector.
    lifecycleDetector?.removeObservers()
    // Clear references.
    lifecycleDetector = nil
    self.eventSink = nil
    return nil
  }

  // MARK: - iOSAppLifecycleStateCallback Conformance

  /**
   * Callback from the native `iOSAppLifecycleDetector` when the app's state changes.
   * This method sends the updated state to the Flutter stream.
   *
   * @param state The new `AppLifecycleState` detected by the native listener.
   */
  func onStateChanged(state: AppLifecycleState) {
    // Send the raw string value of the enum to Flutter via the event sink.
    eventSink?(state.rawValue)
  }

  // MARK: - Unused MethodCallHandler Method (Removed getPlatformVersion)

  // As per the original request, `getPlatformVersion` is removed.
  // The `methodChannel` is now primarily for an `initialize` call.
  // If no method calls are handled directly, this handler might be simpler or removed.
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // If you had other method calls besides "initialize" you would handle them here.
    // For now, it only handles "initialize" (defined above in onAttachedToEngine)
    // or falls through to notImplemented if an unknown method is called.
    result(FlutterMethodNotImplemented)
  }
}
