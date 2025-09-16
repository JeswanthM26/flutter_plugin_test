# apz_play_integrity

A Flutter plugin for integrating **Google Play Integrity API** into your Android apps.  
This plugin allows your app to verify that it is running on a genuine, unmodified device and that the binary has not been tampered with.

---

## ✨ Features

- Fetch **Play Integrity tokens** from Google Play services
- Support for **device integrity**, **app integrity**, and **account verification**
- Easy integration with backend verification
- Configurable API key and nonce handling

---

## 📦 Installation

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  apz_play_integrity:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/play_integrity/v1.0.0
```

```dart
import "package:apz_play_integrity/apz_play_integrity.dart";

// ApzPlayIntegrity is a singleton class. Always use ApzPlayIntegrity() to get the instance.
final ApzPlayIntegrity apzPlayIntegrity = ApzPlayIntegrity();

// 1. Prepare Standard Integrity API (required before requesting Standard token)
Future<void> prepareStandard() async {
  try {
    final bool prepared = await apzPlayIntegrity.prepareStandardIntegrityToken(
      cloudProjectNumber: "1234567890",
    );
    print("Standard Integrity API prepared: $prepared");
  } catch (e) {
    print("Error preparing Standard Integrity API: $e");
  }
}

// 2. Request Standard Integrity Token (for low-value actions)
// IMPORTANT: You must call prepareStandardIntegrityToken and wait for its response before calling requestStandardIntegrityToken.
Future<void> requestStandardToken() async {
  try {
    // First, prepare the Standard Integrity API
    final bool prepared = await apzPlayIntegrity.prepareStandardIntegrityToken(
      cloudProjectNumber: "1234567890",
    );
    if (prepared) {
      final String? token = await apzPlayIntegrity.requestStandardIntegrityToken(
        requestHash: "base64EncodedRequestHash", // optional
      );
      print("Standard Integrity Token: $token");
    } else {
      print("Standard Integrity API not prepared.");
    }
  } catch (e) {
    print("Error requesting Standard Integrity Token: $e");
  }
}

// 3. Request Classic Integrity Token (for high-value actions)
// You can call requestClassicIntegrityToken independently, without preparing Standard Integrity API.
Future<void> requestClassicToken() async {
  try {
    final String? token = await apzPlayIntegrity.requestClassicIntegrityToken(
      nonce: "base64EncodedNonce",
      cloudProjectNumber: "1234567890",
    );
    print("Classic Integrity Token: $token");
  } catch (e) {
    print("Error requesting Classic Integrity Token: $e");
  }
}
```

## Security Best Practice

For enhanced security, always generate the nonce and requestHash on your backend server and provide them to your app through a secure API. This prevents client-side manipulation and helps safeguard against replay and tampering attacks.

| Feature                                     | Standard API Request                                          | Classic API Request                                           |
| ------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------- |
| **Minimum Android SDK Version**             | Android 5.0 (API level 21) or higher                          | Android 4.4 (API level 19) or higher                          |
| **Google Play Requirements**                | Google Play Store and Google Play services                    | Google Play Store and Google Play services                    |
| **API Warm Up Required**                    | ✔️ Yes (a few seconds)                                        | ❌ No                                                         |
| **Typical Request Latency**                 | A few hundred milliseconds                                    | A few seconds                                                 |
| **Potential Request Frequency**             | Frequent (on-demand checks for any action)                    | Infrequent (one-off checks for sensitive actions)             |
| **Timeouts**                                | Long timeout recommended (e.g., 1 minute) due to server calls | Long timeout recommended (e.g., 1 minute) due to server calls |
| **Integrity Verdict Token**                 | Contains device, app, and account details ✔️                  | Contains device, app, and account details ✔️                  |
| **Token Caching**                           | Protected on-device caching by Google Play                    | Not recommended                                               |
| **Decrypt & Verify via Google Play Server** | ✔️                                                            | ✔️                                                            |
| **Typical Decryption Latency**              | 10s of milliseconds with 99.9% availability                   | 10s of milliseconds with 99.9% availability                   |
| **Decrypt & Verify Locally**                | ❌ No                                                         | ✔️ Yes                                                        |
| **Decrypt & Verify Client-side**            | ❌ No                                                         | ❌ No                                                         |
| **Integrity Verdict Freshness**             | Some automatic caching and refreshing by Google Play          | All verdicts recomputed on each request                       |
| **Requests per App per Day**                | 10,000 by default (can be increased)                          | 10,000 by default (can be increased)                          |
| **Requests per App Instance per Minute**    | Warmups: 5 per minute. Integrity tokens: No public limit\*    | Integrity tokens: 5 per minute                                |
| **Mitigate against Tampering**              | Use `requestHash` field                                       | Use `nonce` field with content binding                        |
| **Mitigate against Replay Attacks**         | Automatic mitigation by Google Play                           | Use `nonce` field with server-side logic                      |

Jira Link: https://appzillon.atlassian.net/browse/AN-163
