
/// A Dart model class representing network state information.
class NetworkStateModel {
  /// Represents the state of the network, including carrier information,
  NetworkStateModel({
    required this.mcc,
    required this.mnc,
    required this.networkType,
    required this.connectionType,
    required this.isVpn,
    required this.ipAddress,
    required this.bandwidthMbps,
    required this.ssid,
    required this.signalStrengthLevel,
    required this.latency,
  });

  /// factory constructor to create an instance from a map.
  factory NetworkStateModel.fromMap(final Map<Object?, Object?> map) {
    final Map<String, dynamic> data = <String, dynamic>{
      for (final MapEntry<Object?, Object?> entry in map.entries)
        if (entry.key is String) entry.key! as String: entry.value,
    };

    return NetworkStateModel(
      mcc: data["mcc"] ?? "",
      mnc: data["mnc"] ?? "",
      networkType: data["networkType"],
      connectionType: data["connectionType"] ?? "",
      isVpn: data["isVpn"] ?? false,
      ipAddress: data["ipAddress"] ?? "",
      bandwidthMbps: data["bandwidthMbps"],
      ssid: data["ssid"],
      signalStrengthLevel: data["signalStrengthLevel"] ?? -1,
      latency: data["latency"] ?? -1,
    );
  }


  /// mcc: Mobile Country Code (e.g., "310" for USA).
  final String mcc;

  /// mnc: Mobile Network Code (e.g., "012" for Verizon).
  final String mnc;

  /// networkType: Type of network connection (e.g., "LTE", "WiFi").
  final dynamic networkType; // Can be int on Android, String on iOS
  /// connectionType: Type of connection (e.g., "cellular", "wifi").
  final String connectionType;

  /// isVpn: Indicates if the connection is through a VPN.
  final bool isVpn;

  /// ipAddress: The IP address of the device.
  final String ipAddress;

  /// bandwidthMbps: Estimated bandwidth in Mbps (if available).
  final dynamic bandwidthMbps;

  /// ssid: SSID of the WiFi network (if connected).
  final dynamic ssid;

  /// signalStrengthLevel: Signal strength level
  /// (e.g., -1 for no signal, 0-4 for levels).
  final int signalStrengthLevel;

  /// latency: Estimated latency in milliseconds (if available).
  final double latency;

  /// Converts the instance to a map representation.
  Map<String, dynamic> toMap() => <String, dynamic>{
    "mcc": mcc,
    "mnc": mnc,
    "networkType": networkType,
    "connectionType": connectionType,
    "isVpn": isVpn,
    "ipAddress": ipAddress,
    "bandwidthMbps": bandwidthMbps,
    "ssid": ssid,
    "signalStrengthLevel": signalStrengthLevel,
  };
}
