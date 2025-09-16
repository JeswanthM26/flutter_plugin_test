# 🌟 apz_in_app_review

A lightweight Flutter plugin to trigger in-app reviews using native UI prompts on Android and iOS. This plugin abstracts platform differences and exposes a simple API to request a review from users at appropriate moments in your app.

---

## ✨ Features

- One-line API to trigger in-app review
- No UI to manage manually — API handles it
- Gracefully handles unsupported platforms or denied availability

---

## 🚀 Getting Started

### 1. Add Dependency

```yaml
dependencies:
  apz_contact:
  git:
    url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
    ref: develop
    path: apz_core/plugins/in_app_review/v1.0.0
```

Then run:

```bash
flutter pub get
```

---

## 📦 Usage

### Import the plugin

```dart
import "package:apz_in_app_review/apz_in_app_review.dart";
```

### Request In-App Review

```dart
final ApzInAppReview review = ApzInAppReview();

try {
  await review.requestReview();
}  catch (e) {
  // Handle exceptions
}
```
---

## 🛠 Platform Support

- ✅ Android
- ✅ iOS

---

## 🧠 Best Practices
### ✅ Do:

- Trigger the in-app review flow after a user has experienced enough of your app to provide useful feedback.
- Allow enough time in the session before prompting
- Ensure the prompt isn’t shown repeatedly

### 🚫 Don't:

- Do not prompt the user excessively for a review. This approach helps minimize user frustration and 
  limit API usage 
- Show repeatedly within short time
- Block user flows waiting for a review response

---

## Guidelines

Kindly go through the guidelines link below before consuming this plugin.

 - https://developer.android.com/guide/playcore/in-app-review#quotas,
 - https://developer.android.com/guide/playcore/in-app-review#design-guidelines,
 - https://developer.android.com/guide/playcore/in-app-review#when-to-request
 - https://developer.apple.com/documentation/storekit/requestreviewaction#overview


## 📬 Contributions

PRs and suggestions are welcome! Please open an issue or create a pull request.

---
## Jira Links
-https://appzillon.atlassian.net/browse/AN-130

