import "package:apz_device_fingerprint/utils/fingerprint_utils.dart";
import "package:flutter/material.dart";
import "package:universal_html/html.dart" as html;

/// This class is used to collect and format fingerprint data for
/// web applications. It gathers various device and browser-related metadata.
class FingerprintData {
  /// Fetches the fingerprint data by collecting various metadata.
  /// Returns a formatted string containing the fingerprint data.
  /// Throws an exception if the operation fails.
  Future<String> getFingerprint(final FingerprintUtils fingerprintUtils) async {
    try {
      const String nullString = "null";
      const String naString = "N/A";

      final DateTime now = DateTime.now();
      final Map<String, String> userAgentData = _parseUserAgentSimple();
      final Map<String, String> fullWebGLProfile = await getFullWebGLProfile();

      const String source = "Web";
      final String secureId = _getSecureId(fingerprintUtils);
      const String deviceManufacturer = naString;
      final String deviceModel = html.window.navigator.platform ?? nullString;
      final String screenResolution =
          """${html.window.screen?.width ?? 0} x ${html.window.screen?.height ?? 0} pixels""";
      final String deviceType = _getDeviceType();
      const String totalDiskSpace = naString;
      final String totalRAM =
          _getMemoryEstimate() ?? nullString; // Experimental
      final String cpuCount =
          html.window.navigator.hardwareConcurrency?.toString() ?? nullString;
      const String cpuArchitecture = naString;
      const String cpuEndianness = naString;
      const String deviceName = naString;
      const String glesVersion = naString;
      const String osVersion = naString;
      const String osBuildNumber = naString;
      const String kernelVersion = naString;
      final String enabledKeyboardLanguages = html.window.navigator.language;
      final String installId = _getInstallId(fingerprintUtils);
      final String timeZone = now.timeZoneName;
      final String connectionType = _getConnectionType() ?? nullString;
      const String freeDiskSpace = naString;
      final String latLong =
          (await fingerprintUtils.getLatLong()) ?? nullString;
      final String colorDepth =
          "${html.window.screen?.colorDepth ?? nullString}";
      final String orientation =
          html.window.screen?.orientation?.type ?? nullString;
      final String userAgent = userAgentData["userAgent"] ?? nullString;
      final String deviceInfo = userAgentData["deviceInfo"] ?? nullString;
      final String browser = userAgentData["browser"] ?? nullString;
      final String browserVersion =
          userAgentData["browserVersion"] ?? nullString;
      final String deviceMode = _getDeviceMode();
      final String webglData =
          fullWebGLProfile["UNMASKED_RENDERER_WEBGL"] ?? naString;
      final String graphicCardDetails = fullWebGLProfile["VERSION"] ?? naString;

      final List<String> deviceFingerprintList = <String>[
        source,
        secureId,
        deviceManufacturer,
        deviceModel,
        screenResolution,
        deviceType,
        totalDiskSpace,
        totalRAM,
        cpuCount,
        cpuArchitecture,
        cpuEndianness,
        colorDepth,
        browser,
        webglData,
        deviceName,
        glesVersion,
        osVersion,
        osBuildNumber,
        kernelVersion,
        enabledKeyboardLanguages,
        installId,
        timeZone,
        orientation,
        userAgent,
        deviceInfo,
        browserVersion,
        deviceMode,
        graphicCardDetails,
        connectionType,
        freeDiskSpace,
        latLong,
      ];

      final String digest = fingerprintUtils.generateDigest(
        deviceFingerprintList,
      );
      return digest;
    } on Exception catch (_) {
      rethrow;
    }
  }

  String _getDeviceType() {
    final String userAgent = html.window.navigator.userAgent.toLowerCase();
    if (userAgent.contains("mobile")) {
      return "Mobile";
    }
    if (userAgent.contains("tablet")) {
      return "Tablet";
    }
    return "Desktop";
  }

  String _getSecureId(final FingerprintUtils fingerprintUtils) {
    // Use localStorage to persist identifier across sessions
    const String key = "apzFingerprintSecureId";
    final String? id = html.window.localStorage[key];

    if (id != null) {
      return id;
    }
    final String newId = fingerprintUtils.generateRandomString();
    html.window.localStorage[key] = newId;
    return newId;
  }

  String _getInstallId(final FingerprintUtils fingerprintUtils) {
    const String key = "apzFingerprintInstallId";
    final String? id = html.window.sessionStorage[key];

    if (id != null) {
      return id;
    }

    final String newId = fingerprintUtils.generateRandomString();
    html.window.sessionStorage[key] = newId;
    return newId;
  }

  String? _getConnectionType() {
    try {
      final html.NetworkInformation? connection =
          html.window.navigator.connection;
      return connection?.effectiveType;
    } on Exception catch (_) {
      return null;
    }
  }

  String? _getMemoryEstimate() {
    try {
      final num? memory = html.window.navigator.deviceMemory;
      return memory != null ? "$memory GB" : null;
    } on Exception catch (_) {
      return null;
    }
  }

  Map<String, String> _parseUserAgentSimple() {
    final String userAgent = html.window.navigator.userAgent;
    String deviceInfo = "null";
    String browser = "null";
    String version = "null";

    // Extract the text between the first '(' and ')'
    final RegExp parensPattern = RegExp(r"\((.*?)\)");
    final RegExpMatch? match = parensPattern.firstMatch(userAgent);
    if (match != null) {
      deviceInfo = match.group(1)?.trim() ?? "null";
    }

    // Extract browser name and version
    // Typical UA: "... Chrome/119.0.0.0 ..."
    final RegExp browserPattern = RegExp(
      r"(Firefox|Chrome|Edg|Safari|OPR|MSIE|Trident)/([\d\.]+)",
    );
    final RegExpMatch? browserMatch = browserPattern.firstMatch(userAgent);
    if (browserMatch != null) {
      browser = browserMatch.group(1) ?? "null";
      // version = browserMatch.group(2) ?? "null";
      if (browser == "Safari" && userAgent.contains("Version/")) {
        // Safari has a different version format
        final RegExp safariVersionPattern = RegExp(r"Version/([\d\.]+)");
        final RegExpMatch? safariMatch = safariVersionPattern.firstMatch(
          userAgent,
        );
        version = safariMatch?.group(1) ?? "null";
      } else {
        version = browserMatch.group(2) ?? "null";
      }
    }

    return <String, String>{
      "userAgent": userAgent,
      "deviceInfo": deviceInfo,
      "browser": browser,
      "browserVersion": version,
    };
  }

  /// Gathers detailed WebGL information to enhance fingerprinting accuracy.
  Future<Map<String, String>> getFullWebGLProfile() async {
    final html.CanvasElement canvas = html.CanvasElement(width: 1, height: 1);
    final Object? gl = canvas.getContext("webgl");

    if (gl == null || gl is! html.CanvasRenderingContext) {
      return <String, String>{"error": "WebGL not supported"};
    }

    final Map<String, String> profile = <String, String>{};

    try {
      profile["VENDOR"] = (gl as dynamic).getParameter(0x1F00);
      profile["RENDERER"] = (gl as dynamic).getParameter(0x1F01);
      profile["VERSION"] = (gl as dynamic).getParameter(0x1F02);
      profile["SHADING_LANGUAGE_VERSION"] = (gl as dynamic).getParameter(
        0x8B8C,
      );

      final Object? debugInfo = (gl as dynamic).getExtension(
        "WEBGL_debug_renderer_info",
      );
      if (debugInfo != null) {
        profile["UNMASKED_VENDOR_WEBGL"] = (gl as dynamic).getParameter(
          (debugInfo as dynamic).UNMASKED_VENDOR_WEBGL,
        );
        profile["UNMASKED_RENDERER_WEBGL"] = (gl as dynamic).getParameter(
          (debugInfo as dynamic).UNMASKED_RENDERER_WEBGL,
        );
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }

    return profile;
  }

  String _getDeviceMode() {
    final String mode =
        html.window.matchMedia("(prefers-color-scheme: dark)").matches
        ? "Dark"
        : "Light";
    return mode;
  }
}
