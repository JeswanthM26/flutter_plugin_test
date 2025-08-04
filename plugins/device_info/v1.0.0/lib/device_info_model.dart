class DeviceInfoModel {
  final String? board;
  final String? bootloader;
  final String? brand;
  final String? deviceName;
  final String? display;
  final String? fingerprint;
  final String? hardware;
  final String? host;
  final String? id;
  final String? manufacturer;
  final String? model;
  final String? product;
  final String? name;
  final String? tags;
  final String? type;
  final VersionInfo? version;
  final bool? isPhysicalDevice;
  final bool? isIosAppOnMac;
  final String? identifierForVendor;

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

  factory DeviceInfoModel.fromMap(Map<String, dynamic> map) {
    return DeviceInfoModel(
      board: map['board'],
      bootloader: map['bootloader'],
      brand: map['brand'],
      deviceName: map['deviceName'],
      display: map['display'],
      fingerprint: map['fingerprint'],
      hardware: map['hardware'],
      host: map['host'],
      id: map['id'],
      manufacturer: map['manufacturer'],
      model: map['model'],
      product: map['product'],
      name: map['name'],
      tags: map['tags'],
      type: map['type'],
      version: map['version'] != null
          ? VersionInfo.fromMap(
              (map['version'] as Map<Object?, Object?>).cast<String, dynamic>())
          : null,
      isPhysicalDevice: map['isPhysicalDevice'],
      isIosAppOnMac: map['isIosAppOnMac'],
      identifierForVendor: map['identifierForVendor'],
    );
  }
}

class VersionInfo {
  final String? baseOS;
  final int? previewSdkInt;
  final String? securityPatch;
  final String? codename;
  final String? incremental;
  final String? release;
  final int? sdkInt;

  VersionInfo({
    this.baseOS,
    this.previewSdkInt,
    this.securityPatch,
    this.codename,
    this.incremental,
    this.release,
    this.sdkInt,
  });

  factory VersionInfo.fromMap(Map<String, dynamic> map) {
    return VersionInfo(
      baseOS: map['baseOS'],
      previewSdkInt: map['previewSdkInt'],
      securityPatch: map['securityPatch'],
      codename: map['codename'],
      incremental: map['incremental'],
      release: map['release'],
      sdkInt: map['sdkInt'],
    );
  }
}
