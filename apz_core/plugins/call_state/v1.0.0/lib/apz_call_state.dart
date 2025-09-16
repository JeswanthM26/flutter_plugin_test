import "dart:async";
import "dart:io";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:permission_handler/permission_handler.dart";

/// enums
enum CallState {
  /// Indicates an incoming call is currently ringing.
  incoming,

  /// A call has been initiated by the user and is dialing (before it connects).
  outgoing,

  /// This state is active from the moment the call is
  ///  received until it is rejected.
  active,

  /// Represents the default state where there are no active,
  /// incoming, or outgoing calls.
  /// The phone is in a resting state.
  disconnected,
}

/// Class provides a real-time stream of phone call state events
/// (e.g., ringing, idle, offhook)
///  from the native platform to your Flutter application.
class ApzCallState {
  /// Public factory constructor
  factory ApzCallState() => _instance;
  // Private constructor
  ApzCallState._();

  // Singleton instance
  static ApzCallState _instance = ApzCallState._();

  /// Only for Testing
  @visibleForTesting
  void resetForTest() {
    _instance = ApzCallState._();
    _eventChannel = const EventChannel("call_state_events");
    _permissionService = PermissionService();
  }

  // Event channel
  static EventChannel _eventChannel = const EventChannel("call_state_events");

  PermissionService _permissionService = PermissionService();

  /// Only for Testing
  @visibleForTesting
  void configureForTest({
    final EventChannel? channel,
    final PermissionService? permissionService,
  }) {
    if (channel != null) {
      _eventChannel = channel;
    }
    if (permissionService != null) {
      _permissionService = permissionService;
    }
  }

  // Lazily initialized stream (non-nullable)
  late final Stream<CallState> _callStateStream = _eventChannel
      .receiveBroadcastStream()
      .cast<String>()
      .map((final String event) {
        switch (event) {
          case "disconnected":
            return CallState.disconnected;
          case "incoming":
            return CallState.incoming;
          case "active":
            return CallState.active;
          case "outgoing":
            return CallState.outgoing;
          default:
            return CallState.disconnected;
        }
      });

  /// Getter always returns non-null stream, but checks permission first
  Future<Stream<CallState>> get callStateStream async {
    final PermissionStatus status = await _permissionService
        .requestPhoneStatePermission();
    if (!status.isGranted) {
      throw Exception("Phone Permission is not granted");
    }
    return _callStateStream;
  }
}

/// For handling permissions
class PermissionService {
  /// Requesting Permission method
  Future<PermissionStatus> requestPhoneStatePermission() async {
    if (kIsWeb) {
      throw UnsupportedPlatformException(
        "ApzCallState is not supported on Web.",
      );
    } else if (Platform.isAndroid) {
      return Permission.phone.request();
    } 
    return PermissionStatus.granted;
  }
}
