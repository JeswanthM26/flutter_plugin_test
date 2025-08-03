
import 'dart:async';
import 'dart:convert'; // Added for base64Encode
import 'package:apz_gps/location_exception.dart';
import 'package:apz_idle_timeout/apz_idle_timeout.dart';
import 'package:apz_network_state_perm/network_state_model.dart';
import 'package:apz_notification/apz_notification.dart';
import 'package:apz_qr/generator/apz_qr_generator.dart';
import 'package:apz_screenshot/apz_screenshot.dart';
import 'package:apz_utils/apz_utils.dart';
import 'package:apz_webview/models/accept_decline_btn.dart';
import 'package:apz_webview/models/title_data.dart';
import 'package:apz_webview/models/webview_callbacks.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';


import 'package:apz_camera/enum.dart';
import 'package:apz_camera/image_model.dart';
import 'package:apz_custom_datepicker/custom_date_picker_params.dart';
import 'package:apz_custom_datepicker/selection_type.dart';
import 'package:apz_photopicker/enum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/plugin_metadata.dart';

// Import your plugins here
import 'package:apz_camera/apz_camera.dart';
import 'package:apz_contact/apz_contact.dart';
import 'package:apz_contact_picker/apz_contact_picker.dart';
import 'package:apz_custom_datepicker/apz_custom_datepicker.dart';
import 'package:apz_device_info/apz_device_info.dart';

import 'package:apz_gps/apz_gps.dart';
import 'package:apz_in_app_review/apz_in_app_review.dart';
import 'package:apz_inapp_update/apz_inapp_update.dart';
import 'package:apz_network_state/apz_network_state.dart';
// import 'package:apz_notification/apz_notification.dart';
import 'package:apz_pdf_viewer/apz_pdf_viewer.dart';
import 'package:apz_photopicker/photopicker_image_model.dart';
import 'package:apz_photopicker/apz_photopicker.dart';
//import 'package:apz_qr/apz_qr.dart';
//import 'package:apz_screenshot/apz_screenshot.dart';
import 'package:apz_send_sms/apz_send_sms.dart';
import 'package:apz_app_switch/apz_app_switch.dart';
import 'package:apz_biometric/apz_biometric.dart';
import 'package:apz_deeplink/apz_deeplink.dart';
import 'package:apz_device_fingerprint/apz_device_fingerprint.dart';
import 'package:apz_digi_scan/apz_digi_scan.dart';
import 'package:apz_file_operations/apz_file_operations.dart';
import 'package:apz_network_state_perm/apz_network_state_perm.dart';
import 'package:apz_peripherals/apz_peripherals.dart';
import 'package:apz_screen_security/apz_screen_security.dart';
import 'package:apz_share/apz_share.dart';
import 'package:apz_webview/apz_webview.dart';
class PluginLauncher {
  static Future<dynamic> launch(
    PluginMetadata plugin,
    Map<String, dynamic> formData,
    BuildContext context,
    APZLoggerProvider logger,
   // dynamic navigatorKey,
  ) async {
    switch (plugin.name) {
      case 'camera':
        final List<String> logs = [];
        try {
          logs.add('Camera plugin started');
          final imageModel = ImageModel(
            crop: formData['crop'] ?? true,
            quality: formData['quality'] ?? 80,
            fileName: formData['fileName'] ?? 'my_image',
            format: (formData['format'] == 'png') ? ImageFormat.png : ImageFormat.jpeg,
            targetWidth: formData['targetWidth'] ?? 1080,
            targetHeight: formData['targetHeight'] ?? 1080,
            cameraDeviceSensor: (formData['cameraDeviceSensor'] == 'front')
                ? CameraDeviceSensor.front
                : CameraDeviceSensor.rear,
            cropTitle: formData['cropTitle'] ?? 'Crop Image',
          );
          logs.add('ImageModel created: '
              'crop=${imageModel.crop}, quality=${imageModel.quality}, fileName=${imageModel.fileName}, format=${imageModel.format}, targetWidth=${imageModel.targetWidth}, targetHeight=${imageModel.targetHeight}, cameraDeviceSensor=${imageModel.cameraDeviceSensor}, cropTitle=${imageModel.cropTitle}');
          final camera = ApzCamera();
          logs.add('ApzCamera instance created');
          final result = await camera.pickFromCamera(
            cancelCallback: () { logs.add('Camera operation cancelled by user'); },
            imagemodel: imageModel,
          );
          if (result == null) {
            logs.add('No image captured (result is null)');
            return {'error': 'No image was captured.', 'logs': logs};
          }
          logs.add('Image captured successfully');
          logs.add('Image path: \'${result.imageFile?.path}\'');
          logs.add('Base64 size (KB): ${result.base64ImageSizeInKB}');
          return {
            'imageFile': result.imageFile,
            'imagePath': result.imageFile?.path,
            'base64': result.base64String,
            'base64SizeKB': result.base64ImageSizeInKB,
            'logs': logs,
          };
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[Camera] Exception: $e', e, st);
          return {
            'error': 'Failed to capture image. Please check camera permissions and try again.',
            'logs': logs,
          };
        }

     
case 'contact':
  final List<String> logs = [];
  try {
    logs.add('Contact plugin started');
    final fetchEmail = formData['fetchEmail'] ?? true;
    final fetchPhoto = formData['fetchPhoto'] ?? true;
    final searchQuery = formData['searchQuery'];
    logs.add('Params: fetchEmail=$fetchEmail, fetchPhoto=$fetchPhoto, searchQuery=$searchQuery');
    final contact = ApzContact();
    logs.add('ApzContact instance created');
    final contactsModel = await contact.loadContacts(
      fetchEmail: fetchEmail,
      fetchPhoto: fetchPhoto,
      searchQuery: searchQuery,
    );
    logs.add('Contacts loaded: count=${contactsModel.contacts.length}');
    if (contactsModel.contacts.isEmpty) {
      logs.add('No contacts found for the given search query.');
      return {
        'error': searchQuery != null && searchQuery.toString().isNotEmpty
          ? 'No contacts found for "$searchQuery".'
          : 'No contacts found.',
        'logs': logs,
      };
    }
    final contactsList = contactsModel.contacts.map((c) {
      String? photoBase64;
      if (fetchPhoto && c.photoBytes != null) {
        try {
          photoBase64 = base64Encode(c.photoBytes!);
          logs.add('Photo found for contact: ${c.name}');
        } catch (_) {
          logs.add('Failed to encode photo for contact: ${c.name}');
        }
      } else if (fetchPhoto) {
        logs.add('No photo found for contact: ${c.name}');
      }
      if (fetchEmail && (c.emails == null || c.emails.isEmpty)) {
        logs.add('No email found for contact: ${c.name}');
      }
      return {
        'name': c.name,
        'firstName': c.firstName,
        'lastName': c.lastName,
        'numbers': c.numbers,
        'emails': c.emails,
        'photoBase64': photoBase64,
      };
    }).toList();
    logs.add('Contacts processed and ready for display.');
    return {
      'contacts': contactsList,
      'logs': logs,
    };
  } on PermissionException catch (e) {
    logs.add('PermissionException: ${e.message}');
    return {
      'error': 'Permission denied to access contacts. Please enable permissions and try again.',
      'logs': logs,
    };
  } catch (e, st) {
    logs.add('Exception occurred: $e');
    logs.add('Stacktrace: $st');
    return {
      'error': 'Failed to fetch contacts. Please try again.',
      'logs': logs,
    };
  }

      case 'contact_picker':
        final List<String> logs = [];
        try {
          logs.add('Contact picker plugin started');
          final picker = ApzContactPicker();
          logs.add('ApzContactPicker instance created');
          final picked = await picker.pickContacts();
          if (picked == null) {
            logs.add('No contact selected (user cancelled)');
            return {'error': 'No contact was selected.', 'logs': logs};
          }
          logs.add('Contact picked successfully: ${picked.fullName}');
          
          // Check for thumbnail
          if (picked.thumbnail != null && picked.thumbnail!.isNotEmpty) {
            logs.add('Thumbnail found for contact: ${picked.fullName}');
          } else {
            logs.add('No thumbnail found for contact: ${picked.fullName}');
          }
          
          // Check for email
          if (picked.email != null && picked.email!.isNotEmpty) {
            logs.add('Email found for contact: ${picked.fullName}');
          } else {
            logs.add('No email found for contact: ${picked.fullName}');
          }
          
          return {
            'fullName': picked.fullName,
            'phoneNumber': picked.phoneNumber,
            'email': picked.email,
            'thumbnail': picked.thumbnail,
            'logs': logs,
          };
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[ContactPicker] Exception: $e', e, st);
          return {
            'error': 'Failed to pick contact. Please try again.',
            'logs': logs,
          };
        }

      case 'date_picker':
        final datePicker = ApzCustomDatepicker();
        final params = CustomDatePickerParams(
          context: context,
          minDate: formData['minDate'] ?? DateTime(2020),
          maxDate: formData['maxDate'] ?? DateTime(2030),
          initialDate: formData['initialDate'] ?? DateTime.now(),
          selectionType: (formData['calendarType'] == 'range')
              ? SelectionType.range
              : SelectionType.single,
          themeColor: formData['themeColor'],
          dateFormat: formData['dateFormat'] ?? 'dd/MM/yyyy',
        );
        final result = await datePicker.showCustomDate(params);
        return result;

      case 'device_info':
        final manager = APZDeviceInfoManager();
        final info = await manager.loadDeviceInfo();
        if (info == null) return null;
        // Manually build a map from the info object
        return {
          'brand': info.brand,
          'model': info.model,
          'osVersion': info.version,
          'manufacturer': info.manufacturer,
          'board': info.board,
          'bootloader': info.bootloader,
          'display': info.display,
          'fingerprint': info.fingerprint,
          'hardware': info.hardware,
          'host': info.host,
          'id': info.id,
          'product': info.product,
          'tags': info.tags,
          'isPhysicalDevice': info.isPhysicalDevice,
          'isiosApponMac': info.isIosAppOnMac,
          'type':info.type,
          'devicename': info.deviceName,
          //'baseOs':info.baseOs,
          // 'previewSdk':info.previewSdk,
          // 'securityPatch':info.securityPatch,
          // 'Codename':info.Codename,
          // 'release':info.release,
          // 'version': info.version,
          // 'incremental':info.incremental,
          // 'sdkInt':info.sdkInt

        };
    

case 'gps':
//final logger = APZLoggerProvider();
  logger.debug('[GPS] Plugin started');

  try {
    final gps = ApzGPS();
    final location = await gps.getCurrentLocation();

    logger.info('[GPS] Location fetched: ${location.toMap()}');

    return {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'accuracy': location.accuracy,
      'altitude': location.altitude,
      'speed': location.speed,
      'timestamp': location.timestamp?.toIso8601String(),
    };
  } on PermissionException catch (e) {
    logger.error('[GPS] PermissionException: ${e.message}', e);
    return {'error': 'Permission denied: ${e.message}'};
  } on LocationException catch (e) {
    logger.error('[GPS] LocationException: ${e.message}', e);
    return {'error': 'Location error: ${e.message}'};
  } catch (e, st) {
    logger.error('[GPS] Unexpected error: $e', e, st);
    return {'error': 'Unexpected error occurred.'};
  }

  
  case 'in_app_review':
    final review = ApzInAppReview();
    await review.requestReview();
    return {'result': 'Review dialog requested'};

  case 'inapp_update':
    final updater = ApzInAppUpdate();
    final updateType = formData['updateType'] ?? 'check';
    if (updateType == 'check') {
      final info = await updater.checkForUpdate();
      return {
        'updateAvailability': info.updateAvailability.toString(),
        'immediateUpdateAllowed': info.immediateUpdateAllowed,
        'flexibleUpdateAllowed': info.flexibleUpdateAllowed,
      };
    } else if (updateType == 'immediate') {
      await updater.performImmediateUpdate();
      return {'result': 'Immediate update started'};
    } else if (updateType == 'flexible') {
      await updater.startFlexibleUpdate();
      return {'result': 'Flexible update started'};
    }
    return {'result': 'Unknown update type'};

 
case 'network_state':
  logger.info('[NetworkState] Plugin started');
  try {
    final plugin = ApzNetworkState();
    final model = await plugin.getNetworkState();

    if (model == null) {
      logger.error('[NetworkState] Failed: model is null');
      return {'error': 'Failed to fetch network state'};
    }

    final result = {
      'mcc': model.mcc,
      'mnc': model.mnc,
      'networkType': model.networkType,
      'connectionType': model.connectionType,
      'isVpn': model.isVpn,
      'ipAddress': model.ipAddress,
      'bandwidthMbps': model.bandwidthMbps,
      'latency': model.latency,
      'ssid': model.ssid,
      'signalStrengthLevel': model.signalStrengthLevel,
    };

    logger.info('[NetworkState] Result: $result');
    return result;
  } on PermissionException catch (e) {
    logger.error('[NetworkState] PermissionException: ${e.message}');
    return {'error': 'Permission denied: ${e.message}'};
  } catch (e, st) {
    logger.error('[NetworkState] Unexpected error: $e\n$st');
    return {'error': 'Unexpected error occurred.'};
  }

  case 'notification':
    await ApzNotification.instance.showLocalNotification(
      title: formData['title'] ?? '',
      body: formData['body'] ?? '',
    );
    return {'result': 'Notification triggered'};

  // case 'pdf_viewer':
  //   // You may want to launch a new screen to show the PDF, or just return the config for now
  //   return {
  //     'source': formData['source'],
  //     'sourceType': formData['sourceType'],
  //     'password': formData['password'],
  //     'headers': formData['headers'],
  //   };

  // case 'photopicker':
  //   final picker = ApzPhotopicker();
  //   final imageModel = ImageModel(
  //     crop: formData['crop'] ?? true,
  //     quality: formData['quality'] ?? 80,
  //     fileName: formData['fileName'] ?? 'my_image',
  //     format: (formData['format'] == 'png') ? ImageFormat.png : ImageFormat.jpeg,
  //     targetWidth: formData['targetWidth'] ?? 1080,
  //     targetHeight: formData['targetHeight'] ?? 1080,
  //     cropTitle: formData['cropTitle'] ?? 'Crop Image',
  //   );
  //   final result = await picker.pickFromGallery(
  //     cancelCallback: () {},
  //     imagemodel: imageModel,
  //   );
  //   if (result == null) return null;
  //   return {
  //     'imageFile': result.imageFile,
  //     'imagePath': result.imageFile?.path,
  //     'base64': result.base64String,
  //     'base64SizeKB': result.base64ImageSizeInKB,
  //   };
 

case 'photopicker':
  final picker = ApzPhotopicker();
  final imageModel = PhotopickerImageModel(
    crop: formData['crop'] ?? true,
    quality: formData['quality'] ?? 80,
    fileName: formData['fileName'] ?? 'my_image',
    format: (formData['format'] == 'png')
        ? PhotopickerImageFormat.png
        : PhotopickerImageFormat.jpeg,
    targetWidth: formData['targetWidth'] ?? 1080,
    targetHeight: formData['targetHeight'] ?? 1080,
    cropTitle: formData['cropTitle'] ?? 'Crop Image',
  );
  final result = await picker.pickFromGallery(
    cancelCallback: () {},
    imagemodel: imageModel,
  );
  if (result == null) return null;
  return {
    'imageFile': result.imageFile,
    'imagePath': result.imageFile?.path,
    'base64': result.base64String,
    'base64SizeKB': result.base64ImageSizeInKB,
  };
  // case 'qr':
  //   // If you want to support both scan and generate, you may need a field to choose
  //   // For generator:
  //   final generator = ApzQRGenerator();
  //   final bytes = await generator.generateQrCode(
  //     text: formData['text'] ?? '',
  //     height: formData['height'] ?? 120,
  //     width: formData['width'] ?? 120,
  //     margin: formData['margin'] ?? 0,
  //     // logoBytes: ... // handle if you want to support logo upload
  //   );
  //   return {'qrBytes': bytes};


  case 'screenshot':
    final screenshot = ApzScreenshot();
    final result = await screenshot.captureAndShare(
      context,
      text: formData['text'] ?? '',
      customFileName: formData['customFileName'],
    );
    return {'result': result};

  case 'send_sms':
    final sendSMS = ApzSendSMS();
    final status = await sendSMS.send(
      phoneNumber: formData['phoneNumber'] ?? '',
      message: formData['message'] ?? '',
    );
    return {'status': status.toString()};
    
  case 'app_switch':
  final switchPlugin = ApzAppSwitch();
  final completer = Completer<Map<String, dynamic>>();

  switchPlugin.lifecycleStream.listen(
    (AppLifecycleState state) {
      completer.complete({
        'state': describeEnum(state),
      });
    },
    onError: (error) {
      completer.completeError(error);
    },
  );
case 'biometric':
  final biometric = ApzBiometric();

  final result = await biometric.authenticate(
    reason: formData['reason'] ?? 'Authenticate to access the app',
    stickyAuth: formData['stickyAuth'] ?? true,
    biometricOnly: formData['biometricOnly'] ?? true,
    androidAuthMessage: const AndroidAuthMessages(
      signInTitle: 'Biometric Authentication',
      cancelButton: 'Cancel',
      biometricHint: 'Touch sensor',
    ),
    // iosAuthMessage: const IOSAuthMessages(
    //   localizedReason: 'Authenticate to access the app',
    //   cancelButton: 'OK',
    // ),
  );

  return {
    'status': result.status,
    'message': result.message,
  };

  // case 'biometric':
  // final biometric = ApzBiometric();

  // final result = await biometric.authenticate(
  //   reason: formData['reason'] ?? 'Authenticate to access the app',
  //   stickyAuth: formData['stickyAuth'] ?? true,
  //   biometricOnly: formData['biometricOnly'] ?? true,
  //   androidAuthMessage: const AndroidAuthMessages(
  //     signInTitle: 'Biometric Authentication',
  //     cancelButton: 'Cancel',
  //     biometricHint: 'Touch sensor',
  //   ),
  //   iosAuthMessage: const IOSAuthMessages(
  //     localizedReason: 'Authenticate to access the app',
  //     cancelButton: 'OK',
  //   ),
  // );

  // return {
  //   'status': result.status,
  //   'message': result.message,
  // };

case 'deeplink':
  final deeplink = ApzDeeplink();

  // Always initialize the listener
  await deeplink.initialize();

  if (formData['getInitialLink'] == true) {
    final initialLink = await deeplink.getInitialLink();
    return {
      'initialLink': initialLink,
    };
  } else {
    // Use stream to get a link — for now we just return a placeholder
    // In a real app, you’d listen and route accordingly
    return {
      'streamListening': true,
      'note': 'Live stream listening enabled. Handle via StreamBuilder or subscription.',
    };
  }
// case 'device_fingerprint':
//   final fingerprint = FingerprintData();
//   final utils = FingerprintUtils();
//   final result = await fingerprint.getFingerprint(utils);

//   return {
//     'fingerprint': result,
//   };


  case 'device_fingerprint':
  final plugin = ApzDeviceFingerprint();
  final String fingerprint = await plugin.getFingerprint();
  return {
    'fingerprint': fingerprint,
  };

// case 'digi_scan_image':
//   final scanner = ApzDigiScan();
//   final maxSizeInMB = double.tryParse(values['maxSizeInMB'].toString()) ?? 1.0;
//   final pages = int.tryParse(values['pages'].toString()) ?? 5;
//   final result = await scanner.scanAsImage(maxSizeInMB, pages: pages);
//   return {
//     'scannedImages': result,
//   };

// case 'digi_scan_pdf':
//   final scanner = ApzDigiScan();
//   final maxSizeInMB = double.tryParse(values['maxSizeInMB'].toString()) ?? 2.0;
//   final pages = int.tryParse(values['pages'].toString()) ?? 6;
//   final result = await scanner.scanAsPdf(maxSizeInMB, pages: pages);
//   return {
//     'pdfUri': result,
//   };

case 'file_operations':
  final ops = ApzFileOperations();
  final bool allowMultiple = formData['allowMultiple'] ?? false;
  final int maxMB = formData['maxFileSizeInMB'] ?? 5;
  final String extText = formData['additionalExtensions'] as String? ?? '';
  final List<String> extList = extText
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  final files = await ops.pickFile(
    allowMultiple: allowMultiple,
    additionalExtensions: extList,
    maxFileSizeInMB: maxMB,
  );

  if (files == null) return {'files': null};

  return {
    'files': files.map((f) => {
      'name': f.name,
      'path': f.path,
      'mimeType': f.mimeType,
      'size': f.size,
      'base64': f.base64String,
    }).toList(),
  };
case 'network_state_perm':
  final plugin = ApzNetworkStatePerm();
  final String url = formData['url'] ?? "https://www.i-exceed.com/";

  final NetworkStateModel? result = await plugin.getNetworkState(url: url);
  if (result == null) return {"error": "No data returned"};

  return result.toMap();
case 'apz_peripherals':
  final plugin = APZPeripherals();
  final String operation = formData['operation'];

  switch (operation) {
    case 'battery':
      final int? level = await plugin.getBatteryLevel();
      return {'batteryLevel': '$level%'};

    case 'bluetooth':
      final bool? isBluetoothSupported = await plugin.isBluetoothSupported();
      return {'bluetoothSupported': isBluetoothSupported.toString()};

    case 'nfc':
      final bool? isNFCSupported = await plugin.isNFCSupported();
      return {'nfcSupported': isNFCSupported.toString()};

    default:
      return {'error': 'Unknown operation'};
  }
case 'apz_screen_security':
  final security = ApzScreenSecurity();
  final String operation = formData['operation'];

  try {
    switch (operation) {
      case 'enable':
        final result = await security.enableScreenSecurity();
        return {'action': 'enable', 'success': result.toString()};
      case 'disable':
        final result = await security.disableScreenSecurity();
        return {'action': 'disable', 'success': result.toString()};
      case 'status':
        final result = await security.isScreenSecureEnabled();
        return {'action': 'status', 'isSecureEnabled': result.toString()};
      default:
        return {'error': 'Invalid operation'};
    }
  } catch (e) {
    return {'error': e.toString()};
  }
case 'apz_share':
  final share = ApzShare();
  final String type = formData['shareType'];
  final String title = formData['title'] ?? '';
  final String? text = formData['text'];
  final String? subject = formData['subject'];

  try {
    switch (type) {
      case 'text':
        await share.shareText(
          title: title,
          text: text ?? '',
          subject: subject,
        );
        return {'type': 'text', 'status': 'Shared successfully'};

      case 'file':
        final String filePath = formData['filePath'];
        await share.shareFile(
          filePath: filePath,
          title: title,
          text: text,
        );
        return {'type': 'file', 'filePath': filePath, 'status': 'Shared successfully'};

      case 'multiple_files':
        final List<String> filePaths = (formData['filePaths'] as String)
            .split(',')
            .map((s) => s.trim())
            .toList();
        await share.shareMultipleFiles(
          filePaths: filePaths,
          title: title,
          text: text,
        );
        return {'type': 'multiple_files', 'filePaths': filePaths, 'status': 'Shared successfully'};

      case 'asset_file':
        final String assetPath = formData['assetPath'];
        final String mimeType = formData['mimeType'] ?? 'application/octet-stream';
        await share.shareAssetFile(
          assetPath: assetPath,
          title: title,
          text: text,
          mimeType: mimeType,
        );
        return {'type': 'asset_file', 'assetPath': assetPath, 'status': 'Shared successfully'};

      default:
        return {'error': 'Invalid shareType selected'};
    }
  } catch (e) {
    return {'error': e.toString()};
  }

case 'apz_webview':
  //final context = navigatorKey.currentContext;
  if (context == null) return {'error': 'No valid context'};

  final apzWebview = ApzWebview();

  final String url = formData['url'];
  final bool usePost = formData['usePost'] ?? false;
  final bool showButtons = formData['showAcceptReject'] ?? false;

  Map<String, String> postData = {};
  if (usePost && formData['postData'] != null && formData['postData'].toString().trim().isNotEmpty) {
    final pairs = formData['postData'].toString().split('&');
    for (var pair in pairs) {
      final kv = pair.split('=');
      if (kv.length == 2) {
        postData[kv[0]] = kv[1];
      }
    }
  }

  final callbacks = WebviewCallbacks(
    closeBtnAction: () {
      Navigator.of(context).pop(); // closes webview
    },
    onError: (error) {
      debugPrint('Webview error: $error');
    },
  );

  final titleData = TitleData(title: 'Webview', titleColor: Colors.black);

  final btnModel = AcceptDeclineBtn(
    acceptText: 'Accept',
    declineText: 'Decline',
    acceptBgColor: Colors.green,
    declineBgColor: Colors.red,
    acceptTextColor: Colors.white,
    declineTextColor: Colors.white,
    acceptTapAction: () {
      debugPrint('Accepted');
      Navigator.of(context).pop();
    },
    declineTapAction: () {
      debugPrint('Declined');
      Navigator.of(context).pop();
    },
  );

  try {
    if (usePost) {
      await apzWebview.openWebviewWithPost(
        context: context,
        url: url,
        postData: postData,
        webviewCallbacks: callbacks,
        titleData: titleData,
        isAcceptRejectVisible: showButtons,
        acceptDeclineBtn: showButtons ? btnModel : null,
      );
    } else {
      await apzWebview.openWebview(
        context: context,
        url: url,
        webviewCallbacks: callbacks,
        titleData: titleData,
        isAcceptRejectVisible: showButtons,
        acceptDeclineBtn: showButtons ? btnModel : null,
      );
    }

    return {
      'url': url,
      'requestType': usePost ? 'POST' : 'GET',
      'buttons': showButtons ? 'shown' : 'hidden'
    };
  } catch (e) {
    return {'error': e.toString()};
  }

// case 'apz_idle_timeout':
//   final int timeoutSeconds = int.tryParse(formData['timeoutSeconds'].toString()) ?? 10;
//   final bool triggerNow = formData['triggerNow'] ?? false;

//   final context = navigatorKey.currentContext;
//   if (context == null) return {'error': 'No context found'};

//   final idleTimeout = ApzIdleTimeout();

//   idleTimeout.start(() async {
//     if (!context.mounted) return;
//     final bool? result = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("Idle Timeout"),
//         content: const Text("No activity detected."),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(false),
//             child: const Text("Stay"),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(true),
//             child: const Text("Logout"),
//           ),
//         ],
//       ),
//     );

//     if (result == true) {
//       idleTimeout.pause();
//       //return {'status': 'Logged out due to inactivity'};
//     } else {
//       idleTimeout.reset();
//       //return {'status': 'User chose to stay'};
//     }
//   }, timeout: Duration(seconds: timeoutSeconds));

//   if (triggerNow) {
//     idleTimeout.reset(); // reset to start immediately
//     return {
//       'status': 'IdleTimeout started manually',
//       'timeout': timeoutSeconds,
//     };
//   }

//   return {
//     'status': 'IdleTimeout started',
//     'timeout': timeoutSeconds,
//   };

      default:
        return 'Plugin not supported.';
    }
  }
}