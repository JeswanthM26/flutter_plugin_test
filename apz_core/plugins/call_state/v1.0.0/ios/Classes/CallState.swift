import Flutter
import UIKit
import CallKit

public class CallState: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var callObserver: CXCallObserver?
    private var lastState: String = "disconnected"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterEventChannel(name: "call_state_events", binaryMessenger: registrar.messenger())
        let instance = CallState()
        channel.setStreamHandler(instance)
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        self.callObserver = CXCallObserver()
        self.callObserver?.setDelegate(self, queue: nil)

        // Emit initial state snapshot
        emitInitialState()

        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.callObserver = nil
        self.eventSink = nil
        return nil
    }

    // -----------------------
    // Emit initial snapshot state (No false outgoing)
    // -----------------------
    private func emitInitialState() {
        guard let calls = callObserver?.calls else {
            eventSink?("disconnected")
            lastState = "disconnected"
            return
        }

        var initialState = "disconnected"
        if calls.isEmpty {
            initialState = "disconnected"
        } else if calls.contains(where: { $0.hasConnected }) {
            // ✅ Always treat connected calls as "active" at initialization
            initialState = "active"
        } else if calls.contains(where: { !$0.hasConnected && !$0.isOutgoing }) {
            initialState = "incoming"
        } else if calls.contains(where: { $0.isOutgoing && !$0.hasConnected }) {
            // We are initializing -> treat OFFHOOK (outgoing) same as active? NO → keep outgoing
            // You can flip this to "active" if you never want outgoing on init.
            initialState = "outgoing"
        }

        eventSink?(initialState)
        lastState = initialState
    }
}

extension CallState: CXCallObserverDelegate {
    public func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        var state: String

        if call.hasEnded {
            state = "disconnected"
        } else if call.hasConnected {
            state = "active"
        } else if call.isOutgoing && !call.hasConnected {
            state = "outgoing"
        } else if !call.isOutgoing && !call.hasConnected {
            state = "incoming"
        } else {
            state = "disconnected"
        }

        // Prevent duplicate emission
        if state != lastState {
            eventSink?(state)
            lastState = state
        }
    }
}
