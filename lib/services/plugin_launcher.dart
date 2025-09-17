
import 'dart:async';
import 'dart:convert'; // Added for base64Encode
import 'package:apz_app_shortcuts/shortcut_item.dart';
import 'package:apz_gps/location_exception.dart';
import 'package:apz_idle_timeout/apz_idle_timeout.dart';
import 'package:apz_network_state_perm/network_state_model.dart';
import 'package:apz_notification/apz_notification.dart';
import 'package:apz_qr/apz_qr_scanner.dart';
import 'package:apz_qr/generator/apz_qr_generator.dart';
import 'package:apz_qr/models/apz_qr_scanner_callbacks.dart';
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
import 'package:apz_custom_datepicker/apz_custom_datepicker.dart';
import 'package:apz_custom_datepicker/selection_type.dart';
import 'package:apz_photopicker/enum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/plugin_metadata.dart';


import 'package:apz_camera/apz_camera.dart';
import 'package:apz_contact/apz_contact.dart';
import 'package:apz_contact_picker/apz_contact_picker.dart';
//import 'package:apz_custom_datepicker/apz_custom_datepicker.dart';
import 'package:apz_device_info/apz_device_info.dart';

import 'package:apz_gps/apz_gps.dart';
import 'package:apz_in_app_review/apz_in_app_review.dart';
import 'package:apz_inapp_update/apz_inapp_update.dart';
import 'package:apz_network_state/apz_network_state.dart';
import 'package:apz_pdf_viewer/apz_pdf_viewer.dart';
import 'package:apz_photopicker/photopicker_image_model.dart';
import 'package:apz_photopicker/apz_photopicker.dart';
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
import 'package:url_launcher/url_launcher.dart';
import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';
import 'package:apz_universal_linking/apz_universal_linking.dart';
import 'package:apz_crypto/apz_crypto.dart';
import 'package:apz_auto_read_otp/apz_auto_read_otp.dart';
import 'package:apz_speech_to_text/apz_speech_to_text.dart';
import 'package:apz_text_to_speech/apz_text_to_speech.dart';
import 'package:apz_audioplayer/apz_audioplayer.dart';
import 'package:apz_charts/apz_charts.dart';
import 'package:apz_app_shortcuts/apz_app_shortcuts.dart';
import 'package:apz_call_state/apz_call_state.dart';






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
          
          if (picked.thumbnail != null) {
            logs.add('Thumbnail found for contact: ${picked.fullName}');
          } else {
            logs.add('No thumbnail found for contact: ${picked.fullName}');
          }
          
          if (picked.email != null && picked.email!.isNotEmpty) {
            logs.add('Email found for contact: ${picked.fullName}');
          } else {
            logs.add('No email found for contact: ${picked.fullName}');
          }
          
          return {
            'fullName': picked.fullName,
            'phoneNumber': picked.phoneNumber,
            'email': picked.email,
            'thumbnail': picked.thumbnail != null ? base64Encode(picked.thumbnail!) : null,
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
        
//  case 'date_picker':
//         final datePicker = ApzDatepicker();
//         final params = DatePickerParams(
//           initialDate: formData['initialDate'] ?? DateTime.now(),
//           minDate: formData['minDate'] ?? DateTime(2020),
//           maxDate: formData['maxDate'] ?? DateTime(2030),
//           dateFormat: formData['dateFormat'] ?? 'dd/MM/yyyy',
//           primaryColor: (formData['themeColor'] as Color?)?.value,
//         );
//         final result = await datePicker.showDatePicker(params: params);
//         return {'selectedDate': result};

      case 'custom_datepicker':
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
        final List<String> logs = [];
        try {
          logs.add('Device Info plugin started');
          final manager = APZDeviceInfoManager();
          final info = await manager.loadDeviceInfo();
          if (info == null) {
            logs.add('No device info returned from plugin');
            return {'error': 'Failed to get device info', 'logs': logs};
          }
          logs.add('Device info retrieved successfully');
          final result = {
            'brand': info.brand,
            'model': info.model,
            'osVersion': info.version?.release,
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
            'type': info.type,
            'devicename': info.deviceName,
            'baseOs': info.version?.baseOS,
            'previewSdk': info.version?.previewSdkInt,
            'securityPatch': info.version?.securityPatch,
            'codename': info.version?.codename,
            'release': info.version?.release,
            'incremental': info.version?.incremental,
            'sdkInt': info.version?.sdkInt,
            'logs': logs,
          };
          return result;
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[DeviceInfo] Exception: $e', e, st);
          return {
            'error': 'Failed to get device info. Please try again.',
            'logs': logs,
          };
        }
    

case 'gps':
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
        final List<String> logs = [];
        try {
          logs.add('In-App Update plugin started');
          final updater = ApzInAppUpdate();
          final updateType = formData['updateType'] ?? 'check';
          logs.add('Update type: $updateType');

          if (updateType == 'check') {
            logs.add('Checking for update...');
            final info = await updater.checkForUpdate();
            logs.add('Update info: $info');
            return {
              'updateAvailability': info.updateAvailability.toString(),
              'immediateUpdateAllowed': info.immediateUpdateAllowed,
              'flexibleUpdateAllowed': info.flexibleUpdateAllowed,
              'logs': logs,
            };
          } else if (updateType == 'immediate') {
            logs.add('Performing immediate update...');
            final result = await updater.performImmediateUpdate();
            logs.add('Immediate update result: $result');
            return {'result': 'Immediate update started', 'logs': logs};
          } else if (updateType == 'flexible') {
            logs.add('Starting flexible update...');
            final result = await updater.startFlexibleUpdate();
            logs.add('Flexible update result: $result');
            updater.installUpdateListener.listen((status) {
              logs.add('Install status: $status');
            });
            return {'result': 'Flexible update started', 'logs': logs};
          }
          return {'result': 'Unknown update type', 'logs': logs};
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[InAppUpdate] Exception: $e', e, st);
          return {
            'error': 'Failed to perform in-app update. Please try again.',
            'logs': logs,
          };
        }

 
case 'network_state':
        final List<String> logs = [];
        try {
          logs.add('Network State plugin started');
          final plugin = ApzNetworkState();

          logs.add('Getting network state...');
          final model = await plugin.getNetworkState();

          if (model == null) {
            logs.add('No data returned from plugin');
            return {'error': 'Failed to fetch network state', 'logs': logs};
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

          logs.add('Network state received: $result');
          result['logs'] = logs;
          return result;
        } on PermissionException catch (e) {
          logs.add('PermissionException: ${e.message}');
          return {'error': 'Permission denied: ${e.message}', 'logs': logs};
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[NetworkState] Unexpected error: $e\n$st');
          return {'error': 'Unexpected error occurred.', 'logs': logs};
        }

  case 'notification':
    await ApzNotification.instance.showLocalNotification(
      title: formData['title'] ?? '',
      body: formData['body'] ?? '',
    );
    return {'result': 'Notification triggered'};

  case 'pdf_viewer':
        final List<String> logs = [];
        try {
          logs.add('PDF Viewer plugin started');
          final source = formData['source'];
          final sourceType = formData['sourceType'];
          final password = formData['password'];
          final headers = formData['headers'];

          final config = PdfviewerModel(
            enterTitleText: 'Enter Password',
            okButtonText: 'OK',
            cancelButtonText: 'Cancel',
            pdfErrorText: 'Failed to load PDF',
            emptyPasswordErrorText: 'Password cannot be empty',
            scrollThumbColor: Colors.blue,
            pageNumberTextColor: Colors.white,
          );

          final controller = ApzPdfViewerController();

          final pdfViewer = ApzPdfViewer(
            source: source,
            sourceType: ApzPdfSourceType.values
                .firstWhere((e) => e.toString().split('.').last == sourceType),
            controller: controller,
            config: config,
            headers: headers,
          );

          logs.add('PDF Viewer configured');

          return {
            'widget': pdfViewer,
            'logs': logs,
          };
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[PDFViewer] Exception: $e', e, st);
          return {
            'error': 'Failed to open PDF Viewer. Please try again.',
            'logs': logs,
          };
        }

 

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

case 'qr':
        final List<String> logs = [];
        try {
          logs.add('QR plugin started');
          final operation = formData['operation'];
          logs.add('Operation: $operation');

          switch (operation) {
            case 'Generate QR Code':
              final generator = ApzQRGenerator();
              final text = formData['text'] ?? '';
              final height = formData['height'] ?? 200;
              final width = formData['width'] ?? 200;
              final margin = formData['margin'] ?? 0;
              logs.add('Generating QR code with text: "$text", height: $height, width: $width, margin: $margin');
              final bytes = await generator.generate(
                text: text,
                height: height,
                width: width,
                margin: margin,
              );
              logs.add('QR code generated successfully');
              return {'qrBytes': bytes, 'logs': logs};
            case 'Scan QR Code':
              final completer = Completer<Map<String, dynamic>>();
              final scanner = ApzQrScanner(
                callbacks: ApzQrScannerCallbacks(
                  onScanSuccess: (code) {
                    logs.add('Scan successful: ${code?.text}');
                    if (!completer.isCompleted) {
                      completer.complete({
                        'result': code?.text,
                        'logs': logs,
                      });
                    }
                  },
                  onScanFailure: (code) {
                    logs.add('Scan failed: ${code?.error}');
                    if (!completer.isCompleted) {
                      completer.complete({
                        'error': 'Failed to scan QR code.',
                        'logs': logs,
                      });
                    }
                  },
                  onError: (error) {
                    logs.add('Error: $error');
                    if (!completer.isCompleted) {
                      completer.complete({
                        'error': 'An error occurred during scanning.',
                        'logs': logs,
                      });
                    }
                  },
                ),
              );
              logs.add('QR Scanner configured');
              return {
                'widget': Scaffold(
                  appBar: AppBar(title: const Text('QR Scanner')),
                  body: scanner,
                ),
                'logs': logs,
                'completer': completer,
              };
            default:
              return {'error': 'Unknown QR operation', 'logs': logs};
          }
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[QR] Exception: $e', e, st);
          return {
            'error': 'Failed to perform QR operation. Please try again.',
            'logs': logs,
          };
        }

  case 'screenshot':
        final List<String> logs = [];
        try {
          logs.add('Screenshot plugin started');
          final security = ApzScreenSecurity();
          final isSecure = await security.isScreenSecureEnabled();

          if (isSecure) {
            logs.add('Screen security is enabled, screenshot is disabled');
            return {'error': 'Screenshot is disabled because screen security is enabled.', 'logs': logs};
          }

          logs.add('Screen security is disabled, taking screenshot...');
          final screenshot = ApzScreenshot();
          final result = await screenshot.captureAndShare(
            context,
            text: formData['text'] ?? '',
            customFileName: formData['customFileName'],
          );
          logs.add('Screenshot result: $result');
          return {'result': result, 'logs': logs};
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[Screenshot] Exception: $e', e, st);
          return {
            'error': 'Failed to take screenshot. Please try again.',
            'logs': logs,
          };
        }

  case 'send_sms':
    final sendSMS = ApzSendSMS();
    final status = await sendSMS.send(
      phoneNumber: formData['phoneNumber'] ?? '',
      message: formData['message'] ?? '',
    );
    return {'status': status.toString()};
    
  case 'app_switch':
  final switchPlugin = ApzAppSwitch();
  final logs = <String>['App Switch plugin started, listening for events...'];
  final controller = StreamController<Map<String, dynamic>>();

  switchPlugin.lifecycleStream.listen(
    (AppLifecycleState state) {
      final logMessage = 'App lifecycle state changed: ${describeEnum(state)}';
      logs.add(logMessage);
      controller.add({
        'state': describeEnum(state),
        'logs': List.from(logs), // Send a copy
      });
    },
    onError: (error) {
      final logMessage = 'Error in app switch stream: $error';
      logs.add(logMessage);
      controller.add({
        'error': logMessage,
        'logs': List.from(logs),
      });
      controller.close();
    },
    onDone: () {
      controller.close();
    },
  );

  return {'stream': controller.stream};

case 'biometric':
        final List<String> logs = [];
        try {
          logs.add('Biometric plugin started');
          final biometric = ApzBiometric();
          final result = await biometric.authenticate(
            reason: formData['reason'] ?? 'Authenticate to access the app',
            stickyAuth: formData['stickyAuth'] ?? true,
            biometricOnly: formData['biometricOnly'] ?? true,
          );
          logs.add('Authentication result: ${result.status}');
          return {
            'status': result.status,
            'message': result.message,
            'logs': logs,
          };
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[Biometric] Exception: $e', e, st);
          return {
            'error': 'Failed to authenticate. Please try again.',
            'logs': logs,
          };
        }

case 'deeplink':
        final List<String> logs = [];
        try {
          logs.add('Deeplink plugin started');
          final deeplink = ApzDeeplink();

          // Always initialize the listener
          await deeplink.initialize();
          logs.add('Deeplink listener initialized');

          if (formData['getInitialLink'] == true) {
            logs.add('Getting initial link...');
            final initialLink = await deeplink.getInitialLink();
            logs.add('Initial link: $initialLink');
            return {
              'initialLink': initialLink,
              'logs': logs,
            };
          } else {
            logs.add('Listening for deeplink stream...');
            final completer = Completer<Map<String, dynamic>>();
            deeplink.linkStream.listen((data) {
              logs.add('Deeplink received: $data');
              completer.complete({
                'deeplink': data.toString(),
                'logs': logs,
              });
            });
            return {
              'streamListening': true,
              'note': 'Live stream listening enabled. Handle via StreamBuilder or subscription.',
              'logs': logs,
              'completer': completer,
            };
          }
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[Deeplink] Exception: $e', e, st);
          return {
            'error': 'Failed to handle deeplink. Please try again.',
            'logs': logs,
          };
        }

case 'digi_scan':
        final List<String> logs = [];
        try {
          logs.add('Digi Scan plugin started');
          final scanner = ApzDigiScan();
          final scanType = formData['scanType'] ?? 'image';
          final maxSizeInMB =
              double.tryParse(formData['maxSizeInMB'].toString()) ?? 1.0;
          final pages = int.tryParse(formData['pages'].toString()) ?? 5;

          if (scanType == 'image') {
            logs.add('Scanning as image...');
            final result =
                await scanner.scanAsImage(maxSizeInMB, pages: pages);
            logs.add('Scan result: $result');
            return {'scannedImages': result, 'logs': logs};
          } else {
            logs.add('Scanning as PDF...');
            final result = await scanner.scanAsPdf(maxSizeInMB, pages: pages);
            logs.add('Scan result: $result');
            return {'pdfUri': result, 'logs': logs};
          }
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[DigiScan] Exception: $e', e, st);
          return {
            'error': 'Failed to scan document. Please try again.',
            'logs': logs,
          };
        }

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
        final List<String> logs = [];
        try {
          logs.add('Network State Perm plugin started');
          final plugin = ApzNetworkStatePerm();
          final String url = formData['url'] ?? "https://www.i-exceed.com/";

          logs.add('Getting network state with permissions...');
          final NetworkStateModel? result = await plugin.getNetworkState(url: url);
          if (result == null) {
            logs.add('No data returned from plugin');
            return {"error": "No data returned", "logs": logs};
          }

          logs.add('Network state received: ${result.toMap()}');
          final map = result.toMap();
          map['logs'] = logs;
          return map;
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[NetworkStatePerm] Exception: $e', e, st);
          return {
            'error': 'Failed to get network state. Please try again.',
            'logs': logs,
          };
        }
case 'apz_peripherals':
        final List<String> logs = [];
        try {
          logs.add('Peripherals plugin started');
          final plugin = APZPeripherals();
          final String operation = formData['operation'];
          logs.add('Operation: $operation');

          switch (operation) {
            case 'battery':
              final int? level = await plugin.getBatteryLevel();
              logs.add('Battery level: $level%');
              return {'batteryLevel': '$level%', 'logs': logs};

            case 'bluetooth':
              final bool? isBluetoothSupported = await plugin.isBluetoothSupported();
              logs.add('Bluetooth supported: $isBluetoothSupported');
              return {'bluetoothSupported': isBluetoothSupported.toString(), 'logs': logs};

            case 'nfc':
              final bool? isNFCSupported = await plugin.isNFCSupported();
              logs.add('NFC supported: $isNFCSupported');
              return {'nfcSupported': isNFCSupported.toString(), 'logs': logs};

            default:
              logs.add('Unknown operation');
              return {'error': 'Unknown operation', 'logs': logs};
          }
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[Peripherals] Exception: $e', e, st);
          return {
            'error': 'Failed to perform peripherals operation. Please try again.',
            'logs': logs,
          };
        }
case 'apz_screen_security':
        final List<String> logs = [];
        try {
          logs.add('Screen Security plugin started');
          final security = ApzScreenSecurity();
          final String operation = formData['operation'];
          logs.add('Operation: $operation');

          switch (operation) {
            case 'enable':
              final result = await security.enableScreenSecurity();
              logs.add('Enable screen security result: $result');
              return {'action': 'enable', 'success': result.toString(), 'logs': logs};
            case 'disable':
              final result = await security.disableScreenSecurity();
              logs.add('Disable screen security result: $result');
              return {'action': 'disable', 'success': result.toString(), 'logs': logs};
            case 'status':
              final result = await security.isScreenSecureEnabled();
              logs.add('Screen security status: $result');
              return {'action': 'status', 'isSecureEnabled': result.toString(), 'logs': logs};
            default:
              logs.add('Invalid operation');
              return {'error': 'Invalid operation', 'logs': logs};
          }
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[ScreenSecurity] Exception: $e', e, st);
          return {
            'error': 'Failed to perform screen security operation. Please try again.',
            'logs': logs,
          };
        }
case 'apz_share':
        final List<String> logs = [];
        try {
          logs.add('Share plugin started');
          final share = ApzShare();
          final String type = formData['shareType'];
          final String title = formData['title'] ?? '';
          final String? text = formData['text'];
          final String? subject = formData['subject'];

          logs.add('Share type: $type');

          switch (type) {
            case 'text':
              logs.add('Sharing text: "$text" with title "$title" and subject "$subject"');
              await share.shareText(
                title: title,
                text: text ?? '',
                subject: subject,
              );
              logs.add('Text shared successfully');
              return {'type': 'text', 'status': 'Shared successfully', 'logs': logs};

            case 'file':
              final String filePath = formData['filePath'];
              logs.add('Sharing file: "$filePath" with title "$title" and text "$text"');
              await share.shareFile(
                filePath: filePath,
                title: title,
                text: text,
              );
              logs.add('File shared successfully');
              return {'type': 'file', 'filePath': filePath, 'status': 'Shared successfully', 'logs': logs};

            case 'multiple_files':
              final List<String> filePaths = (formData['filePaths'] as String)
                  .split(',')
                  .map((s) => s.trim())
                  .toList();
              logs.add('Sharing multiple files: "$filePaths" with title "$title" and text "$text"');
              await share.shareMultipleFiles(
                filePaths: filePaths,
                title: title,
                text: text,
              );
              logs.add('Multiple files shared successfully');
              return {'type': 'multiple_files', 'filePaths': filePaths, 'status': 'Shared successfully', 'logs': logs};

            case 'asset_file':
              final String assetPath = formData['assetPath'];
              final String mimeType = formData['mimeType'] ?? 'application/octet-stream';
              logs.add('Sharing asset file: "$assetPath" with title "$title", text "$text", and mimeType "$mimeType"');
              await share.shareAssetFile(
                assetPath: assetPath,
                title: title,
                text: text,
                mimeType: mimeType,
              );
              logs.add('Asset file shared successfully');
              return {'type': 'asset_file', 'assetPath': assetPath, 'status': 'Shared successfully', 'logs': logs};

            default:
              logs.add('Invalid share type selected: $type');
              return {'error': 'Invalid shareType selected', 'logs': logs};
          }
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[Share] Exception: $e', e, st);
          return {
            'error': 'Failed to share. Please try again.',
            'logs': logs,
          };
        }

case 'apz_idle_timeout':
        final List<String> logs = [];
        try {
          logs.add('Idle Timeout plugin started');
          final timeoutSeconds = int.tryParse(formData['timeoutSeconds'].toString()) ?? 10;
          final triggerNow = formData['triggerNow'] ?? false;
          
          final idleTimeout = ApzIdleTimeout();
          idleTimeout.start(
            () async {
              logs.add('Idle timeout callback triggered');
              // In a real app, you would implement a logout or other action here.
              // For this test app, we'll just log the event.
                 showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Idle Timeout'),
                  content: const Text('The app has been idle for a while.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            timeout: Duration(seconds: timeoutSeconds),
          );

          if (triggerNow) {
            idleTimeout.reset();
            logs.add('Idle timeout triggered manually');
          } else {
            logs.add('Idle timeout started');
          }

          return {
            'status': 'IdleTimeout started',
            'timeout': timeoutSeconds,
            'logs': logs,
          };
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[IdleTimeout] Exception: $e', e, st);
          return {
            'error': 'Failed to start Idle Timeout. Please try again.',
            'logs': logs,
          };
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
  case 'jailbreak_root_detection':
        final List<String> logs = [];
        try {
          logs.add('Jailbreak Root Detection plugin started');
          final jailbreakDetector = JailbreakRootDetection.instance;
          logs.add('JailbreakRootDetection instance obtained');

          final isJailBroken = await jailbreakDetector.isJailBroken;
          logs.add('isJailBroken check completed: $isJailBroken');

          final issues = await jailbreakDetector.checkForIssues;
          logs.add(
              'checkForIssues completed: ${issues.map((e) => e.name).join(', ')}');

          final isNotTrusted = await jailbreakDetector.isNotTrust;
          logs.add('isNotTrust check completed: $isNotTrusted');

          return {
            'isJailBroken': isJailBroken,
            'issues': issues.map((e) => e.name).toList(),
            'isNotTrusted': isNotTrusted,
            'logs': logs,
          };
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[JailbreakDetection] Exception: $e', e, st);
          return {
            'error':
                'Failed to perform jailbreak/root detection. Please try again.',
            'logs': logs,
          };
        }
 case 'apz_universal_linking':
        final List<String> logs = [];
        try {
          logs.add('Universal Linking plugin started');
          final universalLink = ApzUniversalLinking();
          logs.add('ApzUniversalLinking instance created');

          final controller = StreamController<Map<String, dynamic>>();

          // Get the initial link
          universalLink.getInitialLink().then((link) {
            if (link != null) {
              logs.add('Initial link received: ${link.fullUrl}');
              controller.add({
                'link': link.fullUrl,
                'queryParams': link.queryParams,
                'logs': List.from(logs),
              });
            }
          });

          // Listen for incoming links
          universalLink.linkStream.listen((link) {
            logs.add('Link received: ${link.fullUrl}');
            controller.add({
              'link': link.fullUrl,
              'queryParams': link.queryParams,
              'logs': List.from(logs),
            });
          }, onError: (error) {
            logs.add('Error in link stream: $error');
            controller.add({
              'error': 'Error in link stream: $error',
              'logs': List.from(logs),
            });
          });

          return {'stream': controller.stream};
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[UniversalLinking] Exception: $e', e, st);
          return {
            'error':
                'Failed to initialize universal linking. Please try again.',
            'logs': logs,
          };
        }
         case 'apz_crypto':
        final List<String> logs = [];
        try {
          logs.add('Crypto plugin started');
          final crypto = ApzCrypto();
          logs.add('ApzCrypto instance created');
          final operation = formData['operation'];
          logs.add('Operation: $operation');

          switch (operation) {
            case 'Symmetric Encrypt':
              final result = crypto.symmetricEncrypt(
                textToEncrypt: formData['textToEncrypt'],
                key: formData['key_sym_enc'],
                iv: formData['iv_sym_enc'],
              );
              return {'result': result, 'logs': logs};
            case 'Symmetric Decrypt':
              final result = crypto.symmetricDecrypt(
                cipherText: formData['cipherText'],
                key: formData['key_sym_dec'],
                iv: formData['iv_sym_dec'],
              );
              return {'result': result, 'logs': logs};
            case 'Asymmetric Encrypt':
              final result = await crypto.asymmetricEncrypt(
                publicKeyPath: formData['publicKeyPath'],
                textToEncrypt: formData['textToEncrypt_asym'],
              );
              return {'result': result, 'logs': logs};
            case 'Asymmetric Decrypt':
              final result = await crypto.asymmetricDecrypt(
                privateKeyPath: formData['privateKeyPath_asym_dec'],
                encryptedData: formData['encryptedData'],
              );
              return {'result': result, 'logs': logs};
            case 'Generate Signature':
              final result = await crypto.generateSignature(
                privateKeyPath: formData['privateKeyPath_sig'],
                textToSign: formData['textToSign'],
              );
              return {'result': result, 'logs': logs};
            case 'Verify Signature':
              final result = await crypto.verifySignature(
                publicKeyPath: formData['publicKeyPath_ver'],
                originalText: formData['originalText'],
                signature: formData['signature'],
              );
              return {'result': result, 'logs': logs};
            case 'Generate Hash':
              final result = crypto.generateHashDigest(
                textToHash: formData['textToHash'],
                type: formData['hashType'] == 'SHA-384'
                    ? HashType.sha384
                    : formData['hashType'] == 'SHA-512'
                        ? HashType.sha512
                        : HashType.sha256,
              );
              return {'result': result, 'logs': logs};
            case 'Generate Hash with Salt':
              final result = crypto.generateHashDigestWithSalt(
                textToHash: formData['textToHash_salt'],
                salt: formData['salt'],
                type: formData['hashType_salt'] == 'SHA-384'
                    ? HashType.sha384
                    : formData['hashType_salt'] == 'SHA-512'
                        ? HashType.sha512
                        : HashType.sha256,
                iterationCount: formData['iterationCount'],
                outputKeyLength: formData['outputKeyLength'],
              );
              return {'result': result, 'logs': logs};
            case 'Generate Random Bytes':
              final result = crypto.generateRandomBytes(
                length: formData['length_bytes'],
              );
              return {'result': base64Encode(result), 'logs': logs};
            case 'Generate Random Alphanumeric':
              final result = crypto.generateRandomAlphanumeric(
                length: formData['length_alphanum'],
              );
              return {'result': result, 'logs': logs};
            default:
              return {'error': 'Unknown crypto operation', 'logs': logs};
          }
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[Crypto] Exception: $e', e, st);
          return {
            'error': 'Failed to perform crypto operation. Please try again.',
            'logs': logs,
          };
        }
case 'apz_auto_read_otp':
        final List<String> logs = [];
        try {
          logs.add('Auto Read OTP plugin started');
          final autoReadOtp = APZAutoReadOtp();
          logs.add('APZAutoReadOtp instance created');
          final listenerType = formData['listenerType'] == 'retriever'
              ? ListenerType.retriever
              : ListenerType.consent;
          final senderNumber = formData['senderNumber'];
          logs.add('Listener Type: $listenerType');
          if (senderNumber != null) {
            logs.add('Sender Number: $senderNumber');
          }

          final controller = StreamController<Map<String, dynamic>>();

          autoReadOtp.onSms = (String sms) {
            logs.add('SMS received: $sms');
            controller.add({
              'sms': sms,
              'logs': List.from(logs),
            });
            autoReadOtp.stopOtpListener();
            controller.close();
          };

          autoReadOtp.startOTPListener(
            type: listenerType,
            senderNumber: senderNumber,
          );

          return {'stream': controller.stream};
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[AutoReadOtp] Exception: $e', e, st);
          return {
            'error': 'Failed to start OTP listener. Please try again.',
            'logs': logs,
          };
        }
      case 'apz_speech_to_text':
        final List<String> logs = [];
        try {
          logs.add('Speech to Text plugin started');
          final speechToText = ApzSpeechToText();
          logs.add('ApzSpeechToText instance created');
          final language = formData['language'];
          final listenDuration = formData['listenDuration'];
          logs.add('Language: $language, Duration: $listenDuration');

          final controller = StreamController<Map<String, dynamic>>();

          speechToText.initialize(
            callback: ({String? text, String? error, bool? isListening}) {
              logs.add('isListening: $isListening, text: $text, error: $error');
              controller.add({
                'isListening': isListening,
                'text': text,
                'error': error,
                'logs': List.from(logs),
              });
              if (isListening == false) {
                controller.close();
              }
            },
          );

          await speechToText.startListening(
            language: language,
            listenDuration: listenDuration,
          );

          return {'stream': controller.stream};
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[SpeechToText] Exception: $e', e, st);
          return {
            'error': 'Failed to start speech listener. Please try again.',
            'logs': logs,
          };
        }
      case 'apz_text_to_speech':
        final List<String> logs = [];
        try {
          logs.add('Text to Speech plugin started');
          final textToSpeech = ApzTextToSpeech();
          logs.add('ApzTextToSpeech instance created');
          final text = formData['text'];
          final voiceName = formData['voiceName'];
          final locale = formData['locale'];
          final rate = formData['rate'];
          final pitch = formData['pitch'];
          final volume = formData['volume'];

          if (voiceName != null && locale != null) {
            await textToSpeech.setVoice(voiceName, locale);
            logs.add('Voice set to: $voiceName ($locale)');
          }
          if (rate != null) {
            await textToSpeech.setSpeechRate(rate);
            logs.add('Rate set to: $rate');
          }
          if (pitch != null) {
            await textToSpeech.setPitch(pitch);
            logs.add('Pitch set to: $pitch');
          }
          if (volume != null) {
            await textToSpeech.setVolume(volume);
            logs.add('Volume set to: $volume');
          }

          final result = await textToSpeech.speak(text);
          logs.add('Speak method called. Result: $result');
          return {'result': 'Speak method called. Result: $result', 'logs': logs};
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[TextToSpeech] Exception: $e', e, st);
          return {
            'error': 'Failed to perform text to speech. Please try again.',
            'logs': logs,
          };

        }

        case 'apz_audioplayer':
        final List<String> logs = [];
        try {
          logs.add('Audio Player plugin started');
          final audioPlayer = ApzAudioplayer();
          logs.add('ApzAudioplayer instance created');
          final sourceType = formData['sourceType'];
          final audioPath = formData['audioPath'];
          final isLoop = formData['isLoop'];
          final stopAfterSeconds = formData['stopAfterSeconds'];
          logs.add('Source Type: $sourceType, Path: $audioPath, Loop: $isLoop, Stop After: $stopAfterSeconds');

          switch (sourceType) {
            case 'url':
              await audioPlayer.playUrlAudio(
                audioUrl: audioPath,
                isLoop: isLoop,
                stopAfterSeconds: stopAfterSeconds,
              );
              break;
            case 'asset':
              await audioPlayer.playAssetAudio(
                audioUrl: audioPath,
                isLoop: isLoop,
                stopAfterSeconds: stopAfterSeconds,
              );
              break;
            case 'file':
              await audioPlayer.playFileAudio(
                filePath: audioPath,
                isLoop: isLoop,
                stopAfterSeconds: stopAfterSeconds,
              );
              break;
          }
          return {'result': 'Audio playback started.', 'logs': logs};
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[AudioPlayer] Exception: $e', e, st);
          return {
            'error': 'Failed to play audio. Please try again.',
            'logs': logs,
          };
        }
//  case 'apz_charts':
//         final List<String> logs = [];
//         try {
//           logs.add('Charts plugin started');
//           final chartType = ChartType.values.firstWhere(
//               (e) => e.toString() == 'ChartType.${formData['chartType']}');
//           logs.add('Chart Type: $chartType');

//           final chartDataJson = jsonDecode(formData['chartData']);
//           final chartConfigJson = formData['chartConfig'] != null && formData['chartConfig'].toString().isNotEmpty
//               ? jsonDecode(formData['chartConfig'])
//               : null;

//           // Manual JSON parsing to create chart data objects
//           final labels = List<String>.from(chartDataJson['labels'] ?? []);
//           final datasets = (chartDataJson['datasets'] as List<dynamic>? ?? [])
//               .map((datasetJson) {
//                 // Assuming APZDataSet is the type for the dataset objects in the plugin
//                 // and it has a constructor that takes label and data.
//                 return APZDataSet(
//                   label: datasetJson['label'] as String? ?? '',
//                   data: List<num>.from(datasetJson['data'] ?? []),
//                 );
//               }).toList();

//           BaseChartData chartData;
//           BaseChartConfig chartConfig;

//           switch (chartType) {
//             case ChartType.line:
//               chartData = APZLineData(labels: labels, datasets: datasets);
//               chartConfig = chartConfigJson != null
//                   ? LineChartConfig.fromJson(chartConfigJson)
//                   : LineChartConfig();
//               break;
//             case ChartType.bar:
//               chartData = APZBarData(labels: labels, datasets: datasets);
//               chartConfig = chartConfigJson != null
//                   ? BarChartConfig.fromJson(chartConfigJson)
//                   : BarChartConfig();
//               break;
//             case ChartType.pie:
//               chartData = APZPieData(labels: labels, datasets: datasets);
//               chartConfig = chartConfigJson != null
//                   ? PieChartConfig.fromJson(chartConfigJson)
//                   : PieChartConfig();
//               break;
//             case ChartType.radar:
//               chartData = APZRadarData(labels: labels, datasets: datasets);
//               chartConfig = chartConfigJson != null
//                   ? RadarChartConfig.fromJson(chartConfigJson)
//                   : RadarChartConfig();
//               break;
//             case ChartType.scatter:
//               chartData = APZScatterData(labels: labels, datasets: datasets);
//               chartConfig = chartConfigJson != null
//                   ? ScatterChartConfig.fromJson(chartConfigJson)
//                   : ScatterChartConfig();
//               break;
//           }

//           return {
//             'widget': APZChart(
//               type: chartType,
//               data: chartData,
//               config: chartConfig,
//             ),
//             'logs': logs,
//           };
//         } catch (e, st) {
//           logs.add('Exception occurred: $e');
//           logs.add('Stacktrace: $st');
//           logger.error('[Charts] Exception: $e', e, st);
//           return {
//             'error': 'Failed to create chart. Please check your JSON data and config. Error: $e',
//             'logs': logs,
//           };
//         }
//       case 'apz_app_shortcuts':
//         final List<String> logs = [];
//         try {
//           logs.add('App Shortcuts plugin started');
//           final appShortcuts = ApzAppShortcuts();
//           logs.add('ApzAppShortcuts instance created');
//           final shortcutsJson = jsonDecode(formData['shortcuts']);
//           final shortcuts = (shortcutsJson as List)
//               .map((item) => ShortcutItem(
//                     id: item['id'],
//                     title: item['title'],
//                     icon: item['icon'],
//                   ))
//               .toList();
//           await appShortcuts.setShortcutItems(shortcuts);
//           logs.add('Shortcuts set');

//           final controller = StreamController<Map<String, dynamic>>();
//           appShortcuts.registerShortcutCallback((id) {
//             logs.add('Shortcut tapped: $id');
//             controller.add({
//               'shortcutId': id,
//               'logs': List.from(logs),
//             });
//           });

//           return {'stream': controller.stream};
//         } catch (e, st) {
//           logs.add('Exception occurred: $e');
//           logs.add('Stacktrace: $st');
//           logger.error('[AppShortcuts] Exception: $e', e, st);
//           return {
//             'error': 'Failed to set app shortcuts. Please try again.',
//             'logs': logs,
//           };
//         }

      // case 'apz_charts':
      //   final List<String> logs = [];
      //   try {
      //     logs.add('Charts plugin started');
      //     final chartType = ChartType.values.firstWhere(
      //         (e) => e.toString() == 'ChartType.${formData['chartType']}');
      //     logs.add('Chart Type: $chartType');
      //     final chartDataJson = jsonDecode(formData['chartData']);
      //     final chartConfigJson = formData['chartConfig'] != null
      //         ? jsonDecode(formData['chartConfig'])
      //         : null;

      //     BaseChartData chartData;
      //     BaseChartConfig chartConfig;

      //     switch (chartType) {
      //       case ChartType.line:
      //         chartData = APZLineData.fromJson(chartDataJson);
      //         chartConfig = chartConfigJson != null
      //             ? LineChartConfig.fromJson(chartConfigJson)
      //             : LineChartConfig();
      //         break;
      //       case ChartType.bar:
      //         chartData = APZBarData.fromJson(chartDataJson);
      //         chartConfig = chartConfigJson != null
      //             ? BarChartConfig.fromJson(chartConfigJson)
      //             : BarChartConfig();
      //         break;
      //       case ChartType.pie:
      //         chartData = APZPieData.fromJson(chartDataJson);
      //         chartConfig = chartConfigJson != null
      //             ? PieChartConfig.fromJson(chartConfigJson)
      //             : PieChartConfig();
      //         break;
      //       case ChartType.radar:
      //         chartData = APZRadarData.fromJson(chartDataJson);
      //         chartConfig = chartConfigJson != null
      //             ? RadarChartConfig.fromJson(chartConfigJson)
      //             : RadarChartConfig();
      //         break;
      //       case ChartType.scatter:
      //         chartData = APZScatterData.fromJson(chartDataJson);
      //         chartConfig = chartConfigJson != null
      //             ? ScatterChartConfig.fromJson(chartConfigJson)
      //             : ScatterChartConfig();
      //         break;
      //     }

      //     return {
      //       'widget': APZChart(
      //         type: chartType,
      //         data: chartData,
      //         config: chartConfig,
      //       ),
      //       'logs': logs,
      //     };
      //   } catch (e, st) {
      //     logs.add('Exception occurred: $e');
      //     logs.add('Stacktrace: $st');
      //     logger.error('[Charts] Exception: $e', e, st);
      //     return {
      //       'error': 'Failed to create chart. Please check your JSON data and config.',
      //       'logs': logs,
      //     };
      //   }
case 'apz_app_shortcuts':
        final List<String> logs = [];
        try {
          logs.add('App Shortcuts plugin started');
          final appShortcuts = ApzAppShortcuts();
          logs.add('ApzAppShortcuts instance created');
          final shortcutsJson = jsonDecode(formData['shortcuts']);
          final shortcuts = (shortcutsJson as List)
              .map((item) => ShortcutItem(
                    id: item['id'],
                    title: item['title'],
                    icon: item['icon'],
                  ))
              .toList();
          await appShortcuts.setShortcutItems(shortcuts);
          logs.add('Shortcuts set');

          final controller = StreamController<Map<String, dynamic>>();
          appShortcuts.registerShortcutCallback((id) {
            logs.add('Shortcut tapped: $id');
            controller.add({
              'shortcutId': id,
              'logs': List.from(logs),
            });
          });

          return {'stream': controller.stream};
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[AppShortcuts] Exception: $e', e, st);
          return {
            'error': 'Failed to set app shortcuts. Please try again.',
            'logs': logs,
          };
        }
      case 'apz_call_state':
        final List<String> logs = [];
        try {
          logs.add('Call State plugin started');
          final callState = ApzCallState();
          logs.add('ApzCallState instance created');

          final controller = StreamController<Map<String, dynamic>>();

          callState.callStateStream.then((stream) {
            stream.listen((state) {
              logs.add('Call state changed: $state');
              controller.add({
                'callState': state.toString(),
                'logs': List.from(logs),
              });
            });
          });

          return {'stream': controller.stream};
        } catch (e, st) {
          logs.add('Exception occurred: $e');
          logs.add('Stacktrace: $st');
          logger.error('[CallState] Exception: $e', e, st);
          return {
            'error': 'Failed to start call state listener. Please try again.',
            'logs': logs,
          };
        }


      default:
        return 'Plugin not supported.';
    }
  }     
}
