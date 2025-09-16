import "dart:convert";
import "dart:io";
import "package:apz_photopicker/apz_photopicker.dart";
import "package:apz_photopicker/photopicker_image_model.dart";
import "package:apz_photopicker/photopicker_result.dart";
import "package:apz_qr/apz_qr_scanner.dart";
import "package:apz_qr/view/animated_scanner_line.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_zxing/flutter_zxing.dart" as zxing;
import "package:mocktail/mocktail.dart";
import "package:permission_handler/permission_handler.dart";

class MockZxingCode {
  static zxing.Code valid() =>
      _FakeZxingCode(text: "valid-code", isValid: true);
  static zxing.Code invalid() => _FakeZxingCode(text: "", isValid: false);
}

class _FakeZxingCode implements zxing.Code {
  final String? _text;
  final bool _isValid;

  _FakeZxingCode({String? text, bool isValid = false})
    : _text = text,
      _isValid = isValid;

  @override
  String? get text => _text;

  @override
  bool get isValid => _isValid;

  @override
  String? get error => null;

  @override
  Uint8List? get rawBytes => null;

  @override
  int get format => 0;

  @override
  bool get isInverted => false;

  @override
  bool get isMirrored => false;

  @override
  int get duration => 0;

  @override
  Uint8List? get imageBytes => null;

  @override
  int get imageWidth => 0;

  @override
  int get imageHeight => 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockPermissionService extends Mock implements PermissionService {}

class MockApzCameraPlugin extends Mock implements ApzPhotopicker {}

class MockZxing extends Mock implements zxing.Zxing {}

class MockCallbacks extends Mock implements ApzQrScannerCallbacks {}

class FakeDecodeParams extends Fake implements zxing.DecodeParams {}

class FakeCameraResult extends PhotopickerResult {
  @override
  final File? imageFile;

  FakeCameraResult(this.imageFile);
}

class FakeImageModel extends Fake implements PhotopickerImageModel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockPermissionService mockPermissionService;
  setUp(() {
    mockPermissionService = MockPermissionService();
  });
  setUpAll(() {
    registerFallbackValue(FakeDecodeParams());
    registerFallbackValue(FakeImageModel());
  });
  group("ApzQrScanner Widget Tests", () {
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });
    testWidgets("Permission granted updates _hasPermission to true", (
      tester,
    ) async {
      // Arrange: mock the permission service to return granted
      when(
        () => mockPermissionService.requestCameraPermission(),
      ).thenAnswer((_) async => PermissionStatus.granted);

      // Create the widget with the state key
      final key = GlobalKey<ApzScannerViewState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApzQrScanner(key: key, callbacks: ApzQrScannerCallbacks()),
          ),
        ),
      );

      // Inject the mock service
      key.currentState!.permissionService = mockPermissionService;

      // Act: call the method under test
      await key.currentState!.checkAndRequestPermissions();

      await tester.pump(); // wait for setState

      // Assert: _hasPermission should be true
      expect(key.currentState!.hasPermission, isTrue);
    });

    testWidgets(
      "If widget is unmounted, no SnackBar is shown when permission denied",
      (tester) async {
        when(
          () => mockPermissionService.requestCameraPermission(),
        ).thenAnswer((_) async => PermissionStatus.denied);

        final key = GlobalKey<ApzScannerViewState>();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ApzQrScanner(key: key, callbacks: ApzQrScannerCallbacks()),
            ),
          ),
        );

        // key.currentState!.setPermissionService(mockPermissionService);
        key.currentState!.permissionService = mockPermissionService;

        // Unmount widget before permission check completes
        await tester.pumpWidget(Container());

        // Now call method (the mounted flag is false)
        await key.currentState?.checkAndRequestPermissions();

        await tester.pump();

        // Since widget is unmounted, no SnackBar should appear
        expect(find.byType(SnackBar), findsNothing);
      },
    );

    testWidgets("Manual override of _hasPermission", (tester) async {
      final key = GlobalKey<ApzScannerViewState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApzQrScanner(key: key, callbacks: ApzQrScannerCallbacks()),
          ),
        ),
      );

      key.currentState?.testHasPermission(hasPermission: true);
      await tester.pump(); // Reflect state update

      expect(key.currentState?.hasPermission, isTrue);
    });

    testWidgets("Manual override of has no permission", (tester) async {
      final key = GlobalKey<ApzScannerViewState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApzQrScanner(key: key, callbacks: ApzQrScannerCallbacks()),
          ),
        ),
      );
      key.currentState?.testHasPermission(hasPermission: false);
      await tester.pump(); // Reflect state update
      expect(key.currentState?.hasPermission, isFalse);
    });

    testWidgets("Displays waiting message when permission not granted", (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final widget = ApzQrScanner(callbacks: ApzQrScannerCallbacks());
                // Access state and set permission
                final state = context
                    .findAncestorStateOfType<ApzScannerViewState>();
                state?.testHasPermission(hasPermission: false);
                return widget;
              },
            ),
          ),
        ),
      );

      await tester.pump(); // To rebuild

      expect(find.text("Waiting for permissions..."), findsOneWidget);
    });

    testWidgets("ApzQrScanner renders with default values", (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ApzQrScanner(callbacks: ApzQrScannerCallbacks()),
          ),
        ),
      );
      expect(find.byType(ApzQrScanner), findsOneWidget);
    });

    testWidgets("testing all icons", (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApzQrScanner(callbacks: ApzQrScannerCallbacks()),
          ),
        ),
      );
    });

    testWidgets("does not render scanner line when showScannerLine is false", (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApzQrScanner(callbacks: ApzQrScannerCallbacks()),
          ),
        ),
      );

      expect(find.byType(AnimatedScannerLine), findsNothing);
    });

    testWidgets("calls onScanSuccess when scan result is valid", (
      tester,
    ) async {
      Code? scannedCode;

      final key = GlobalKey<ApzScannerViewState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApzQrScanner(
              key: key,
              callbacks: ApzQrScannerCallbacks(
                onScanSuccess: (code) => scannedCode = code,
              ),
            ),
          ),
        ),
      );

      final state = tester.state<ApzScannerViewState>(
        find.byType(ApzQrScanner),
      );
      state.handleScanSuccess(MockZxingCode.valid());

      expect(scannedCode?.text, "valid-code");
      expect(scannedCode?.isValid, isTrue);
    });

    testWidgets("calls onScanFailure when scan result is invalid", (
      tester,
    ) async {
      Code? failedCode;

      final key = GlobalKey<ApzScannerViewState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApzQrScanner(
              callbacks: ApzQrScannerCallbacks(
                onScanFailure: (code) => failedCode = code,
              ),
              key: key,
            ),
          ),
        ),
      );

      key.currentState?.handleScanFailure(MockZxingCode.invalid());

      await tester.pump();

      expect(failedCode?.isValid, isFalse);
    });

    testWidgets("calls onMultiScanSuccess when multi scan result is valid", (
      tester,
    ) async {
      Codes? scannedCodes;

      final key = GlobalKey<ApzScannerViewState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApzQrScanner(
              key: key,
              callbacks: ApzQrScannerCallbacks(
                onMultiScanSuccess: (codes) => scannedCodes = codes,
              ),
              config: ApzQrScannerConfig(isMultiScan: true),
            ),
          ),
        ),
      );

      final state = tester.state<ApzScannerViewState>(
        find.byType(ApzQrScanner),
      );

      // Create a mock zxing.Codes object with valid _FakeZxingCode list
      final mockCodes = zxing.Codes(
        codes: [MockZxingCode.valid(), MockZxingCode.valid()],
        duration: 100,
      );

      state.handleMultiScanSuccess(mockCodes);

      expect(scannedCodes?.codes.length, 2);
      expect(scannedCodes?.codes[0].text, "valid-code");
    });

    testWidgets("calls onMultiScanFailure when multi scan result fails", (
      tester,
    ) async {
      Codes? failedCodes;

      final key = GlobalKey<ApzScannerViewState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApzQrScanner(
              key: key,
              config: ApzQrScannerConfig(isMultiScan: true),
              callbacks: ApzQrScannerCallbacks(
                onMultiScanFailure: (codes) => failedCodes = codes,
              ),
            ),
          ),
        ),
      );

      final state = tester.state<ApzScannerViewState>(
        find.byType(ApzQrScanner),
      );

      final mockCodes = zxing.Codes(
        codes: [MockZxingCode.invalid(), MockZxingCode.invalid()],
        duration: 50,
      );

      state.handleMultiScanFailure(mockCodes);

      expect(failedCodes?.codes.every((code) => code.isValid == false), isTrue);
    });

    testWidgets("calls onMultiScanModeChanged when multi scan mode changes", (
      tester,
    ) async {
      bool? modeChanged;

      final key = GlobalKey<ApzScannerViewState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApzQrScanner(
              key: key,
              callbacks: ApzQrScannerCallbacks(
                onMultiScanModeChanged: ({required bool isEnabled}) =>
                    modeChanged = isEnabled,
              ),
            ),
          ),
        ),
      );

      final state = tester.state<ApzScannerViewState>(
        find.byType(ApzQrScanner),
      );

      state.handleMultiScanModeChanged(enabled: true);

      expect(modeChanged, isTrue);

      state.handleMultiScanModeChanged(enabled: false);

      expect(modeChanged, isFalse);
    });

    testWidgets(
      "does not render ApzAnimatedScannerLine when showScannerLine is false",
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ApzQrScanner(callbacks: ApzQrScannerCallbacks()),
            ),
          ),
        );

        expect(find.byType(AnimatedScannerLine), findsNothing);
      },
    );
    testWidgets(
      "displays error message when UnsupportedPlatformException is caught",
      (tester) async {
        // Define a widget that simulates the error scenario
        Widget errorWidget() => MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Simulate an exception being thrown
                try {
                  throw UnsupportedPlatformException("Platform not supported");
                } catch (e) {
                  if (e is UnsupportedPlatformException) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          e.message,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else {
                    return Container(); // fallback
                  }
                }
              },
            ),
          ),
        );

        await tester.pumpWidget(errorWidget());

        // Verify that the error message is displayed
        expect(find.text("Platform not supported"), findsOneWidget);
        expect(find.byType(Center), findsOneWidget);
        expect(find.byType(Text), findsOneWidget);
      },
    );
    testWidgets("displays error message for UnsupportedPlatformException", (
      tester,
    ) async {
      // Create a dummy widget that throws inside build
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                try {
                  throw UnsupportedPlatformException("Platform not supported");
                } catch (e) {
                  if (e is UnsupportedPlatformException) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          e.message,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }
                  return Container();
                }
              },
            ),
          ),
        ),
      );
      // Confirm the message appears
      expect(find.text("Platform not supported"), findsOneWidget);
    });
  });

  final Map<String, String> decodedStrings = {
    "qrcode_1.jpg":
        "upi://pay?pa=paytmqr281005050101v998y7wmi33g@paytm&pn=Paytm%20Merchant&paytmqr=281005050101V998Y7WMI33G",
    "qrcode_2.jpg":
        "upi://pay?pa=UJJBB07631751975@Ujjivan&pn=ujjivan%20merchant&mc=0763&tn=&am=&cu=INR&sign=7IUB/I4V35vGqxhlX4ij8PyXdsQ52BznbWkxodXOHuwFM5w2kGomOQubRLqmZ6IYRQSL/a/G4WDA1+5bSZ4J8Q==",
    "qrcode_3.jpeg":
        "upi://pay?pa=rishadr801-3@okhdfcbank&pn=Rishad%20Rio&aid=uGICAgIDD7Iq8Iw",
    "qrcode_4.jpeg":
        "upi://pay?pa=rishadr801-3@okhdfcbank&pn=Rishad%20Rio&aid=uGICAgIDD7Iq8Iw",
    "qrcode_5.png":
        "upi://pay?pa=BHARATPE09892269394@yesbankltd&pn=Verified Merchant&cu=INR&tn=GREAT MISSION T&tr=APP",
    "qrcode_6.png":
        "upi://pay?pa=BHARATPE09899182921@yesbankltd&pn=ESSGI INFOTECH PRIVA&cu=INR&tn=Pay To ESSGI INFOTECH PRIVA&tr=WHATSAPP_QR",
    "qrcode_7.png":
        "https://www.paypal.com/qrcodes/managed/524dfb05-5685-4eef-8cdd-c5d670b57f99",
    "qrcode_8.png":
        "upi://pay?pa=btsgfoundation@upi&pn=&cu=INR&mode=02&purpose=00&orgid=189999&sign=MEUCIQDvL8FClP2dRY2lsDCElO7INA0PHpLQBElhvmG7oIhkxgIgd5zhb33/+CxDSlQxeO+LErR7nnF+kAx0tQtbuas6rRE=",
    "qrcode_9.jpg":
        "upi://pay?pa=9366127215@okbizaxis&pn=HUMANE%20ANIMAL%20SOCIET&mc=8011&aid=uGICAgIDvpdSYVQ&tr=BCR2DN6T26H7NNTO",
    "qrcode_10.png": "https://qatarpay.com/resolver/handler.ashx",
    "qrcode_11.jpg":
        "upi://pay?pa=&pn=&mc=0000&tid=&tr=&tn=&am=&cu=INR&refUrl=https://www.ujjivansfb.in/",
    "qrcode_12.png":
        "https://ABH000000CGB1234563434333ddfffffasjfk459nkdkd002000000340122300002305654530403@findmydevice.com",
    "qrcode_13.png":
        "https://www.google.com/search?q=dollar+logo+in+red+background&tbm=isch&chips=q:dollar+logo+in+red+background,online_chips:png:lJcnK8WwOpQ%3D&rlz=1C1CHBF_enIN962IN962&hl=en&sa=X&ved=2ahUKEwj0rdjJ4rL8AhW9j9gFHUQNDLsQ4lYoA3oECAEQKw&biw=1263&bih=552#imgrc=8wjeLZwdN-2H1M",
    "qrcode_14.png":
        "https://ABH000000CGB1234563434333ddfffffasjfk459nkdkd002000000340122300002305654530403@findmydevice.com",
    "qrcode_15.png":
        "https://www.google.com/search?q=online+rent+receipt+generator+without+watermark+free+download&rlz=1C1CHBF_enIN962IN962&oq=&aqs=chrome.3.35i39i362l8.309351j0j7&sourceid=chrome&ie=UTF-8",
    "qrcode_16.jpg":
        "upi://pay?pa=pramodujj23may@ujjivan&pn=Pramod%20Desai&mc=0000&tid=&tr=&tn=&am=250.00&cu=INR&refUrl=https://www.ujjivansfb.in/",
    "qrcode_17.jpg":
        "00020101021130500016orbpkhppxxx@orbp01090001003820213Oriental Bank5204599953038405802KH5920Café Klaing Co., Ltd6010Phnom Penh9917001316698604339146304C372",
    "qrcode_18.png":
        "00020101021130450016abaakhppxxx@abaa01090002069990208ABA Bank40390006abaP2P011262C02DF65D0102090002069995204000053038405802KH5910Ratana KIN6010Phnom Penh6304D187",
    "qrcode_19.png":
        "00020101021130450016abaakhppxxx@abaa01090002069990208ABA Bank40390006abaP2P011262C02DF65D0102090002069995204000053038405802KH5910Ratana KIN6010Phnom Penh6304D187",
    "qrcode_20.png":
        "00020101021127610108991656240212SARAN14@BDAF0429SARAN MURALEEDHARAN LAILAMANI5920SARAN MURALEEDHARAN 63044128",
    "qrcode_21.PNG":
        "00020101021127610108991656240212SARAN14@BDAF0429SARAN MURALEEDHARAN LAILAMANI5920SARAN MURALEEDHARAN 63044128",
    "qrcode_22.PNG":
        "0002010102120828BMUSOMRXXXXX-175411111111111266801151754111111111110211AbrarBD2020033012345678901234567890123456789052045411530351254033.25502015802OM5918Abrar super market6015MUSCAT   GHUBRA6110123456789062440016123456789012345604201234567890123456789063043a25",
    "qrcode_23.jpg":
        "00020101021130450016abaakhppxxx@abaa01090003399720208ABA Bank40390006abaP2P01126085C0D59CFC02090003399725204000053038405802KH5908Man MATH6010Phnom Penh6304E7B6",
    "qrcode_24.jpg":
        "00020101021129450016abaakhppxxx@abaa01090003399720208ABA Bank40390006abaP2P01126085C0D59CFC02090003399725204000053038405802KH5908Man MATH6010Phnom Penh63044727",
    "qrcode_25.jpg":
        "00020101021129270016aswlkhppxxx@aswl01031375204599953038405802KH5910POY SITHON6010Phnom Penh621602128559674441689917001317056179989276304DD11",
    "qrcode_26.jpg":
        "upi://pay?pa=9910013971@okbizaxis&pn=Weblink%20In%20Pvt.Ltd&mc=7372&aid=uGICAgIDD6K34Qg&tr=BCR2DN6T7PBI7VTZ",
    "qrcode_27.jpg": "01234565",
    "qrcode_28.png": "614141000036",
    "qrcode_29.png": "00012345678905",
    "qrcode_30.png": "01234565",
    "qrcode_31.png": "705632085943",
    "qrcode_32.jpg": "CSE370",
    "qrcode_33.png": "3PRM8P",
    "qrcode_34.png": "(11)100518(15)111018(10)17",
    "qrcode_35.png":
        "rVrfX7Br3MnFURpa76NuXvXtWYcKjD4UT7VjgW2vDLDavbTayTeBGYUejckHsjnG4hqf6KESUyeyaykGZKShBhJYLdSK4ZGdF9ak8vZnmVd8XJcv38eDkpe8uxZ7e3UM7WrJHTueG5CyzdTfqRdYdDBkWWryBdJNExtaaTTpZE9ta8yXJqy6Can6twVnqk4vwPzKYzYRSQDf4pPMmcmTrygjt7dhcqbJBsw7rLbmB7ceWZS6htUEwB4yEz4nnagL6tSCQbfkXXPTjh8MUXLd5eL9zz8wnfJJc9tZWPjvNk97f7MpgC4WYuVtnWgdJLcDQkWA9LAXJPnVCrAh4E98ZHpkPMEeN5MUaFxSzKT9GZ2ahrSxuTPS7wEHdJsXPv7Q2TaSE6vKJaWHq7Vc9XRbmVJzupeZ5KSYaV4upuEnr9xZZBZP6xYhWRpWLR6kQ8VLLndRPm87Mtn4cs3TmL44HcTMKpRbztwfMkBC2HKTAPZxqpduRCbf6KY6ADqG8eFu",
    "qrcode_36.png":
        "It was the best of times, it was the worst of times, it was the age of wisdom, it was the age of foolishness, it was the epoch of belief, it was the epoch of incredulity, it was the season of Light, it was the season of Darkness, it was the spring of hope, it was the winter of despair, we had everything before us, we had nothing before us, we were all going direct to Heaven, we were all going direct the other way<DC4>in short, the period was so far like the present period, that some of its noisiest authorities insisted on its being received, for good or for evil, in the superlative degree of comparison only.<LF><LF>There were a king with a large jaw and a queen with a plain face, on the throne of England; there were a king with a large jaw and a queen with a fair face, on the throne of France. In both countries it was clearer than crystal to the lords of the State preserves of loaves and fishes, that things in general were settled for ever.<LF><LF>It was the year of Our Lord one thousand seven hundred and seventy-five. Spiritual revelations were conceded to England at that favoured period, as at this. Mrs. Southcott had recently attained her five-and-twentieth blessed birthday, of whom a prophetic private in the Life Guards had heralded the sublime appearance by announcing that arrangements were made for the swallowing up of London and Westminster. Even the Cock-lane ghost had been laid only a round dozen of years, after rapping out its messages, as the spirits of this very year last past (supernaturally deficient in originality) rapped out theirs. Mere messages in the earthly order of events had lately come to the English Crown and People, from a congress of British subjects in America: which, strange to relate, have proved more important to the human race than any communications yet received through any of the chickens of the Cock-lane brood.",
    "qrcode_37.png":
        "shc:/567629095243206034602924374044603122295953265460346029254077280433602870286471674522280928613331456437653141590640220306450459085643550341424541364037063665417137241236380304375622046737407532323925433443326057360106452931531270742428395038692212766728666731266342087422573776302062041022437658685343255820002167287607585708105505622752282407670809680507692361773323356634342439664440596761410443377667202663224433674530596175400038397052612140292974753658337372662132066669047253044469405210524536242721550377673434280323045475690310233670562227414567090555653507636250537239522776211205312561442568282012726838630039087127042463716936535535602928393065580072763158437500341209546904210458383257586630101033123422114008776058732325243477645920113037325929083272452732223707055550412927584543582550667760036577724025621136525340592771740903663844771261692077697211447057562509437029626707254539002011763240720310114260256672645965627243654061066553770056003044082967606162724306592273682223412466107335331229606157521057357572327529693965670332063208596309543400076452696835713027450728663529345234666377297208583525543653527774072234735706452828641140633528387577054371703966706421520708254156041170353656054471407636552612616834377244090406554327122559623453686207006139712936404138601156656945315611255669116044703333731263580306106975715411702932060511012768634011703371553353213365032550756476005853005224547339310064671161682376335069647622323339523133724171327531702738363650063527592633763908656123314363227707566731311074",
    "qrcode_38.png":
        "Version 25 QR Code, up to 1853 characters at L level. A QR code (abbreviated from Quick Response code) is a type of matrix barcode (or two-dimensional code) that is designed to be read by smartphones. The code consists of black modules arranged in a square pattern on a white background. The information encoded may be text, a URL, or other data.Created by Toyota subsidiary Denso Wave in 1994, the QR code is one of the most popular types of two-dimensional barcodes. The QR code was designed to allow its contents to be decoded at high speed. The technology has seen frequent use in Japan and South Korea; the United Kingdom is the seventh-largest national consumer of QR codes. Although initially used for tracking parts in vehicle manufacturing, QR codes now are used in a much broader context, including both commercial tracking applications and convenience-oriented applications aimed at mobile phone users (termed mobile tagging). QR codes may be used to display text to the user, to add a vCard contact to the user's device, to open a Uniform Resource Identifier (URI), or to compose an e-mail or text message. Users can generate and print their own QR codes for others to scan and use by visiting one of several paid and free QR code generating sites or apps.",
    "qrcode_39.png":
        "http://info.tmrdirect.com/bid/105473/Are-your-QR-Codes-too-hard-to-read?utm_campaign=This-is-an-example-of-a-long-url-for-qr-codes&utm_source=blog",
    "qrcode_40.png":
        "BEGIN:VCARD FN:John Doe TEL;WORK;VOICE:(049)012-345-678 PHOTO;JPEG;ENCODING=BASE64:/9j/4AAQSkZJRgABAQEASABIAAD/2wBDABQODxIPDRQSEBIXFRQYHjIhHhwcHj0sLiQySUBMS0dARkVQWnNiUFVtVkVGZIhlbXd7gYKBTmCNl4x9lnN+gXz/wAALCAAoACgBAREA/8QAGQABAAMBAQAAAAAAAAAAAAAAAwIEBQEG/8QALBAAAgEEAQIDBwUAAAAAAAAAAQIDAAQRIRIxUQUTQRQiQmFxofAzscHR8f/aAAgBAQAAPwApBcKQEVebk/qNoDv8qKzufaecbJgjZZdq2MZxSSnzJQQBk7xntQzRuOAiwXbuaryqAcE57/3W6YYroGOfQ4FMjsf8o7bwlLKRStwZIxknkNt0A+mqmbFJW5QOAQdgjpWNeXAiLLbsCE0WPxE+govMPHjMvluyhgc6Ir0CBfN0rAemWK5+5B+mqj4vdy2Ua3CRhxyCnlrho9KOC6mvTCRDJCDnlyGBUrrw20aJ0mUqeXIFP5rOezgUBRKeKjCJwx67zuqsF3cWzHywCh6qNAmuXV/cOIzJGYwSHx1yM9ftW1H4kJYOasScZyCARvp+/X5UKMzsVOV18ScdY+Xun7UbshwHfH52oJAqylX6ggAaFSmEkUYilhjuIVJKehAO+tUJA8lzJKENuDgBV90AAYArkruioQzFDnOTmpxXGGGFLDsfzVf/2Q==END:VCARD",
    "qrcode_41.png":
        "BEGIN:VCARD VERSION:3.0 N:Frank;van der Heijden ORG:Timeless Design EMAIL;TYPE=INTERNET:info@timelessdesign.nl URL:http://www.timelessdesign.nl TEL;TYPE=CELL:0653541887 TEL:0316845436 ADR:;;Annie M.G. Schmidtstraat 16;Duiven;Gelderland;6921TP;Nederland END:VCARD",
    // "qrcode_42.png": "",
    "qrcode_43.png":
        "Version 25 QR Code, up to 1853 characters at L level. A QR code (abbreviated from Quick Response code) is a type of matrix barcode (or two-dimensional code) that is designed to be read by smartphones. The code consists of black modules arranged in a square pattern on a white background. The information encoded may be text, a URL, or other data. Created by Toyota subsidiary Denso Wave in 1994, the QR code is one of the most popular types of two-dimensional barcodes. The QR code was designed to allow its contents to be decoded at high speed. The technology has seen frequent use in Japan and South Korea; the United Kingdom is the seventh-largest national consumer of QR codes. Although initially used for tracking parts in vehicle manufacturing, QR codes now are used in a much broader context, including both commercial tracking applications and convenience-oriented applications aimed at mobile phone users (termed mobile tagging). QR codes may be used to display text to the user, to add a vCard contact to the user's device, to open a Uniform Resource Identifier (URI), or to compose an e-mail or text message. Users can generate and print their own QR codes for others to scan and use by visiting one of several paid and free QR code generating sites or apps.",
    "qrcode_44.jpg":
        "00020101021229480009khqr@aclb0111855151829180216ACLEDA Banks Plc520420005802KH5401153038405908Satya So6010Phnom Penh6269011215134128549002090168855320808Purchase99240009khqr@aclb0307QRPAYME63040133",
    "qrcode_45.jpg":
        "00020101021229480009khqr@aclb0111855151829180216ACLEDA Banks Plc520420005802KH5401153038405908Satya So6010Phnom Penh6269011215134128549002090168855320808Purchase99240009khqr@aclb0307QRPAYME63040133",
    "qrcode_46.jpg":
        "00020101021229480009khqr@aclb0111855151829180216ACLEDA Banks Plc520420005802KH5401153038405908Satya So6010Phnom Penh6269011215134128549002090168855320808Purchase99240009khqr@aclb0307QRPAYME63040133",
    "qrcode_47.jpg":
        "00020101021130500016orbpkhppxxx@orbp01090001003940213Oriental Bank5204599953031165802KH5914ELLYNA FLORIST6010Phnom Penh621502118558632330399170013167081818584563040738",
    "qrcode_48.jpg":
        "00020101021130500016orbpkhppxxx@orbp01090001003940213Oriental Bank5204599953031165802KH5914ELLYNA FLORIST6010Phnom Penh621502118558632330399170013167081818584563040738",
    "qrcode_49.jpg":
        "00020101021130500016orbpkhppxxx@orbp01090001003820213Oriental Bank5204599953038405802KH5920Café Klaing Co., Ltd6010Phnom Penh9917001316698604339146304C372",
    "qrcode_50.jpg":
        "00020101021130500016orbpkhppxxx@orbp01090001003820213Oriental Bank5204599953038405802KH5920Café Klaing Co., Ltd6010Phnom Penh9917001316698604339146304C372",
    "qrcode_51.jpg":
        "00020101021129480009khqr@aclb0111855147344950216ACLEDA Banks Plc520420005802KH53038405908Ouk Sril6010Phnom Penh6238020901092967299210009khqr@aclb0304MYQR6304A60E",
    "qrcode_52.jpg":
        "00020101021129480009khqr@aclb0111855147344950216ACLEDA Banks Plc520420005802KH53038405908Ouk Sril6010Phnom Penh6238020901092967299210009khqr@aclb0304MYQR6304A60E",
    "qrcode_53.png":
        "Do what you want 'cause a pirate is free, you are a pirate!Yar - har - fiddle-dee-dee, being a pirate is all right with me!",
    "qrcode_54.png":
        "upi://pay?pa=BHARATPE.9100018845@icici&pn=BharatPe%20Merchant&cu=INR&tn=Verified%20Merchant",
    "qrcode_55.jpg":
        "upi://pay?pa=BHARATPE.9100018845@icici&pn=BharatPe%20Merchant&cu=INR&tn=Verified%20Merchant",
    "qrcode_56.png":
        r"RANDOM_STRING-0023432 wsed 123  456444 d f rg rf fgf g fde12312312390d3C34533455sDhjA3n$5NnG,1212<dfdf>asads{wew}IHAswGrh+QWDFDSasm,.lk!@#qwe$%^ASDzxc&*(+_)aszxcvbnmASDFGHJKLqwertyuio ,./;'dA][|~`aswrd-END",
  };
  group("ApzQrScanner Gallery Decode Tests", () {
    for (final entry in decodedStrings.entries) {
      testWidgets("handleGalleryIconPressed - ${entry.key}", (tester) async {
        // 1. Load QR image bytes
        final byteData = await rootBundle.load("assets/test/${entry.key}");
        final bytes = byteData.buffer.asUint8List();

        // 2. Prepare mocks
        final mockCameraPlugin = MockApzCameraPlugin();
        final mockZxing = MockZxing();

        final mockFile = PhotopickerResult(
          base64String: base64Encode(bytes),
          imageFile: File("${Directory.systemTemp.path}/${entry.key}"),
        );

        when(
          () => mockCameraPlugin.pickFromGallery(
            cancelCallback: any(named: "cancelCallback"),
            imagemodel: any(named: "imagemodel"),
          ),
        ).thenAnswer((_) async => mockFile);

        final mockCode = zxing.Code(text: entry.value, isValid: true);

        when(
          () => mockZxing.readBarcodeImagePathString(any(), any()),
        ).thenAnswer((_) async => mockCode);
        // 3. Capture scan result
        String? resultText;

        // 4. Pump the widget
        await tester.pumpWidget(
          MaterialApp(
            home: ApzQrScanner(
              key: UniqueKey(),
              callbacks: ApzQrScannerCallbacks(
                onScanSuccess: (code) => resultText = mockCode.text,
                onScanFailure: (_) => fail("Scan failed"),
                onError: (_) => fail("Error occurred"),
              ),
            ),
          ),
        );
        await tester.pump(Duration(seconds: 5));
        expect(mockCode.text, equals(entry.value));
      });
    }
  });
}
