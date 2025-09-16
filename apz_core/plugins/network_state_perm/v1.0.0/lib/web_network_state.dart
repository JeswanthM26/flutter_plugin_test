@JS()
library;

import "dart:js_interop";

@JS()
/// Plugin to fetch network state details from the web platform.
external NavigatorWithConnection get navigator;

/// Extension to access the connection property of the Navigator interface.
extension type NavigatorWithConnection(JSObject _)
    implements JSObject {
  /// Returns the NetworkInformation object if available, otherwise null.
  external NetworkInformation? get connection;
}

@JS()
/// Represents the NetworkInformation interface, providing details 
/// about the network connection.
extension type NetworkInformation(JSObject _) implements JSObject {
  external String effectiveType;
  external num downlink;
  external num rtt;
  external bool saveData;
}
