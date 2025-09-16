# 📡 apz_network_state_perm

A lightweight and powerful Flutter plugin to **fetch detailed network state information** on Android devices. this plugin provides enhanced real-time metrics like bandwidth, signal strength, carrier details, latency and VPN detection in a single unified API. Built for extensibility, testing, and real-world usage.

---

## ✨ Features

- Detects and returns:
  - Carrier Name (eg:airtel,jio)
  - Mobile Country Code (MCC)
  - Mobile Network Code (MNC)
  - Network Type (e.g., LTE, WiFi, 5G) only in IOS
  - Connection Type (Mobile/WiFi)
  - VPN Detection (true/false)
  - Device IP Address
  - Current Bandwidth (Mbps)
  - Latency Milliseconds (ms) only in IOS
  - Connected WiFi SSID
  - Signal Strength (Level 0–4)
- Native permission handling internally
- Supports dependency injection for testing

---

## 🚀 Getting Started

### Add Dependency

```yaml
dependencies:
  apz_network_state_perm:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/network_state_perm/v1.0.0
```

```bash
flutter pub get
```
### iOS (`Info.plist`)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to retrieve WiFi network information.</string>
```

### iOS (`Podfile`)

Add this snippet to the bottom of your iOS `Podfile`, inside the `post_install do |installer| ... end` block:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CONTACTS=1'
      ]
    end
  end
end

---

## 📦 Usage

### Import

```dart
import 'package:apz_network_state/apz_network_state.dart';
```

### Fetch Network Info

```dart
final plugin = ApzNetworkState();

try {
  final NetworkStateModel model = await plugin.getNetworkState();

  print('MCC: ${model.mcc}');
  print('MNC: ${model.mnc}');
  print('carrierName: ${model.carrierName}');
  print('Network Type: ${model.networkType}');
  print('Connection Type: ${model.connectionType}');
  print('VPN: ${model.isVpn}');
  print('IP: ${model.ipAddress}');
  print('Bandwidth: ${model.bandwidthMbps} Mbps');
  print('Latency: ${model.latency} Milliseconds (ms) ');
  print('SSID: ${model.ssid}');
  print('Signal Strength: ${model.signalStrengthLevel}/4');
} on PermissionException {
      // Log or handle permission-specific error
      rethrow; // let UI or use case layer handle this
    } on UnsupportedPlatformException {
      // Log or handle unsupported platform error
      rethrow; // let UI or use case layer handle this
    } catch (e) {
      // Log or handle unexpected errors
      rethrow;
    }
```

---

## 📄 NetworkStateModel

```dart
class NetworkStateModel {
  final String carrierName;
  final String mcc;
  final String mnc;
  final dynamic networkType;
  final String connectionType;
  final bool isVpn;
  final String ipAddress;
  final dynamic bandwidthMbps;
  final double latency
  final dynamic ssid;
  final int signalStrengthLevel;
}
```

---

## 🛠 Platform Support

- ✅ Android
- ✅ iOS

---

## 🧪 Testing & DI

Supports dependency injection for testing.

```dart
class FakeNetworkState implements ApzNetworkState {
  @override
  Future<NetworkStateModel> getNetworkDetails() async {
    return NetworkStateModel(
      carrierName:"airtel",
      mcc: "404",
      mnc: "10",
      networkType: "LTE",
      connectionType: "Mobile",
      isVpn: false,
      ipAddress: "192.168.1.2",
      bandwidthMbps: 25.0,
      latency: 1.0
      ssid: "JioFiber",
      signalStrengthLevel: 3,
    );
  }
}
```
---
---

### Jira Ticket

- [network_state_perm](https://appzillon.atlassian.net/browse/AN-11)

---

