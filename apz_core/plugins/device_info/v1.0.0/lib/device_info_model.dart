/// Model class to represent device information.
class DeviceInfoModel {
  /// Constructor for DeviceInfoModel
  DeviceInfoModel({
    this.board,
    this.bootloader,
    this.brand,
    this.deviceName,
    this.display,
    this.fingerprint,
    this.hardware,
    this.host,
    this.id,
    this.manufacturer,
    this.model,
    this.product,
    this.name,
    this.tags,
    this.type,
    this.version,
    this.isPhysicalDevice,
    this.isIosAppOnMac,
    this.identifierForVendor,
  });

  /// Creates an instance of DeviceInfoModel from a map
  factory DeviceInfoModel.fromMap(final Map<String, dynamic> map) =>
      DeviceInfoModel(
        board: map["board"],
        bootloader: map["bootloader"],
        brand: map["brand"],
        deviceName: map["deviceName"],
        display: map["display"],
        fingerprint: map["fingerprint"],
        hardware: map["hardware"],
        host: map["host"],
        id: map["id"],
        manufacturer: map["manufacturer"],
        model: map["model"],
        product: map["product"],
        name: map["name"],
        tags: map["tags"],
        type: map["type"],
        version: map["version"] != null
            ? VersionInfo.fromMap(
                (map["version"] as Map<Object?, Object?>)
                    .cast<String, dynamic>(),
              )
            : null,
        isPhysicalDevice: map["isPhysicalDevice"],
        isIosAppOnMac: map["isIosAppOnMac"],
        identifierForVendor: map["identifierForVendor"],
      );

  /// Board name
  final String? board;

  /// Bootloader version
  final String? bootloader;

  /// Brand name
  final String? brand;

  /// Device name
  final String? deviceName;

  /// Display information
  final String? display;

  /// Fingerprint
  final String? fingerprint;

  /// Hardware information
  final String? hardware;

  /// Host information
  final String? host;

  /// Device ID
  final String? id;

  /// Manufacturer name
  final String? manufacturer;

  /// Model name
  final String? model;

  /// Product name
  final String? product;

  /// Name
  final String? name;

  /// Tags
  final String? tags;

  /// Type
  final String? type;

  /// Version information
  final VersionInfo? version;

  /// Indicates if the device is physical
  final bool? isPhysicalDevice;

  /// Indicates if the iOS app is running on a Mac
  final bool? isIosAppOnMac;

  /// Identifier for vendor
  final String? identifierForVendor;
}

/// Model class to represent version information of the device.
class VersionInfo {
  /// Constructor for VersionInfo
  VersionInfo({
    this.baseOS,
    this.previewSdkInt,
    this.securityPatch,
    this.codename,
    this.incremental,
    this.release,
    this.sdkInt,
  });

  /// Creates an instance of VersionInfo from a map
  factory VersionInfo.fromMap(final Map<String, dynamic> map) => VersionInfo(
    baseOS: map["baseOS"],
    previewSdkInt: map["previewSdkInt"],
    securityPatch: map["securityPatch"],
    codename: map["codename"],
    incremental: map["incremental"],
    release: map["release"],
    sdkInt: map["sdkInt"],
  );

  /// Base OS version
  final String? baseOS;

  /// Preview SDK integer
  final int? previewSdkInt;

  /// Security patch level
  final String? securityPatch;

  /// Codename
  final String? codename;

  /// Incremental version
  final String? incremental;

  /// Release version
  final String? release;

  /// SDK integer
  final int? sdkInt;
}
