# APZ API Service (apz_api_service)

Thin, testable wrapper around Dio providing convenient request helpers, SSL certificate pinning, optional payload encryption, optional integrity check of payload, upload/download helpers and a streaming POST helper for server-sent chunks.

This README documents the public API exposed by the package (as implemented in `lib/apz_api_service.dart`) and shows idiomatic usage including handling the `Result<T>` return type and `ApiProviderException` errors.

### HTTP verbs supported

The library provides helpers that cover the common HTTP verbs and file operations. Map of verbs to APZApiService helpers:

- GET — `getRequest({ path, queryParameters?, headers? })`
- POST — `postRequest({ path, body, queryParameters?, headers? })`
  - Streaming POST — `postStreamRequest({ path, body, queryParameters?, headers? })` returns `Stream<String>`
- PUT — `putRequest({ path, body, queryParameters?, headers? })`
- DELETE — `deleteRequest({ path, queryParameters?, headers? })`
- Multipart upload (POST) — `uploadFile({ path, queryParameters?, headers?, progressCallback? })` (uses `MultipartFile.fromFile`)
- File download — `downloadFile({ fileUrl, savePath, queryParameters?, headers?, progressCallback? })`

All of the above accept optional headers and query parameters where relevant.

## Installation

Add the package to your `pubspec.yaml` (example using a git checkout from your internal repo):

```yaml
apz_api_service:
  git:
    url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
    ref: develop
    path: apz_core/api_service/v1.0.0
```

## Quick contract

- Inputs: API path/URL as `String`, optional headers and query parameters, JSON-like Map bodies for non-file requests.
- Outputs: Most methods return `Future<Result<Map<String, dynamic>>>` where `Result` is either `Success<T>` (value available) or `Error<T>` (contains `ApiProviderException`).
- Streaming: `postStreamRequest` returns `Stream<String>` of UTF-8 decoded lines from the server.
- Errors: network/Dio errors and internal exceptions are converted to `ApiProviderException`.

## Initialization

Constructor (note: this is a regular constructor — the class is not a singleton):

```dart
final apiService = APZApiService(
  baseUrl: 'https://api.example.com',
  timeoutDurationInSec: 30,
  isDebugModeEnabled: true,
  dataIntegrityEnabled = false, // optional
  sslPinningEnabled: false, // optional
  certificatePinningModel: null, // used when sslPinningEnabled=true
  payloadEncryption: false, // optional
  publicKeyPath: '', // used when payloadEncryption=true
  privateKeyPath: '', // used when payloadEncryption=true
);
```

## setToken

Call `setToken` to add an Authorization header to subsequent requests:

```dart
apiService.setToken('your_token_here');
```

## Using the Result<T> return type

All non-streaming network helpers (get/post/put/delete/uploadFile/downloadFile) return `Future<Result<Map<String, dynamic>>>`.

Example: handle success and error explicitly:

```dart
final Result<Map<String, dynamic>> result = await apiService.getRequest(path: '/endpoint');
if (result is Success<Map<String, dynamic>>) {
  final Map<String, dynamic> body = result.value;
  // use body
} else if (result is Error<Map<String, dynamic>>) {
  final ApiProviderException ex = result.errorValue;
  // inspect ex.statusCode, ex.message, ex.response, etc.
}
```

ApiProviderException fields commonly available (see `lib/model/api_provider_exception.dart`):

- `statusCode` — HTTP status or internal error code
- `message` — human readable message
- `response` — raw server response when available
- `errorType`, `type`, `title`, `detail`, `instance`, `status`, `timetamp` — these may be populated for structured server errors

## Example requests

### GET

```dart
final result = await apiService.getRequest(
  path: '/items',
  queryParameters: {'page': 1},
);
// inspect Result as shown above
```

### POST

```dart
final result = await apiService.postRequest(
  path: '/items',
  body: {'name': 'item'},
);
```

### PUT

```dart
final result = await apiService.putRequest(
  path: '/items/123',
  body: {'name': 'new'},
);
```

### DELETE

```dart
final result = await apiService.deleteRequest(path: '/items/123');
```

## Streaming POST (server-sent chunks)

The `postStreamRequest` method performs a POST and exposes the response stream as a `Stream<String>` of UTF-8 decoded lines. It will throw `ApiProviderException` when connectivity checks fail or when the response contains no stream.

```dart
try {
  final Stream<String> stream = apiService.postStreamRequest(
    path: '/stream-endpoint',
    body: {'query': '...'},
  );

  await for (final String chunk in stream) {
    // handle chunk (already decoded and line-split)
  }
} on ApiProviderException catch (ex) {
  // handle streaming errors
}
```

## File upload and download

Notes:

- `DioClient.uploadFile` expects a local file path (it uses `MultipartFile.fromFile`). Pass the local file system path to the method that ultimately calls into `DioClient`.
- `APZApiService.uploadFile` exposes a `path` parameter which is passed through to `DioClient.uploadFile`. In the library's tests and implementation the `path` argument is used both as the endpoint and as a file path when calling `DioClient.uploadFile` — supply the correct value for your usage (either endpoint or full local path) depending on how you construct the call in your app. The simplest safe usage is to pass the local file path when uploading from the device filesystem.

Upload example (progress callback optional):

```dart
final result = await apiService.uploadFile(
  path: '/upload', // or a local file path depending on your call-site; see notes above
  queryParameters: null,
  headers: null,
  progressCallback: (count, total) {
    // update UI progress
  },
);

if (result is Success<Map<String, dynamic>>) {
  // upload succeeded
} else if (result is Error<Map<String, dynamic>>) {
  final ex = result.errorValue;
  // inspect error
}
```

Download example:

```dart
final result = await apiService.downloadFile(
  fileUrl: 'https://example.com/file',
  savePath: '/local/path/file',
  progressCallback: (count, total) { /* ... */ },
);
```

## Platform notes

- The package uses `dart:io` and `MultipartFile.fromFile` for uploads. While some parts of the code guard SSL pinning with `kIsWeb`, file-based upload/download and certain `dart:io` exceptions are not web-safe. Do not assume full web compatibility without conditional imports or adapter code.

## Testing helpers

For tests you can replace the internal `DioClient` and `Connectivity` instances via the `@visibleForTesting` setters exposed on `APZApiService`:

```dart
apiService.dioClient = mockDioClient;
apiService.connectivityInstance = mockConnectivity;
```

This makes the class easy to unit test (see `test/` in the package for examples).

## Error handling summary

- Methods return `Result.success` on HTTP 200 (request success code). Non-200 responses are converted to `Result.error` with an `ApiProviderException` containing the response and status code.
- Network/Dio exceptions are converted to `ApiProviderException` with parsed server fields when available.

---

## Jira Links

- https://appzillon.atlassian.net/browse/AN-70
- https://appzillon.atlassian.net/browse/AN-87
- https://appzillon.atlassian.net/browse/AN-103
- https://appzillon.atlassian.net/browse/AN-107
- https://appzillon.atlassian.net/browse/AN-203
- https://appzillon.atlassian.net/browse/AN-204
