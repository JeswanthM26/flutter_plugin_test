import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:apz_api_service/apz_api_service.dart";
import "package:apz_api_service/model/api_provider_exception.dart";
import "package:apz_api_service/model/result_response.dart";
import "package:apz_api_service/src/dio_client.dart";
import "package:connectivity_plus/connectivity_plus.dart";
import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

class MockDioClient extends Mock implements DioClient {}

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      DioClient(
        baseUrl: "",
        timeoutDuration: 1,
        isDebugModeEnabled: false,
        dataIntegrityEnabled: false,
        sslPinningEnabled: false,
        certificatePinningModel: null,
        payloadEncryption: false,
        publicKeyPath: "",
        privateKeyPath: "",
      ),
    );
    registerFallbackValue(Connectivity());
  });

  group("APZApiService", () {
    late APZApiService apiService;
    late MockDioClient mockDioClient;
    late MockConnectivity mockConnectivity;

    setUp(() {
      mockDioClient = MockDioClient();
      mockConnectivity = MockConnectivity();
      apiService =
          APZApiService(
              baseUrl: "https://example.com",
              timeoutDurationInSec: 10,
              isDebugModeEnabled: true,
            )
            ..dioClient = mockDioClient
            ..connectivityInstance = mockConnectivity;
    });

    test("postStreamRequest throws when not connected", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.none]);

      final Stream<String> stream = apiService.postStreamRequest(
        path: "/stream",
        body: <String, dynamic>{},
      );

      await expectLater(stream.toList(), throwsA(isA<ApiProviderException>()));
    });
    test("setToken calls DioClient.setToken", () {
      apiService.setToken("token123");
      verify(() => mockDioClient.setToken("token123")).called(1);
    });

    test("putRequest returns Error when Dio throws", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);

      final DioException dioException = DioException(
        requestOptions: RequestOptions(path: "/puterr"),
      );

      when(
        () => mockDioClient.put("/puterr", <String, dynamic>{}, null, null),
      ).thenThrow(dioException);

      final Result<Map<String, dynamic>> result = await apiService.putRequest(
        path: "/puterr",
        body: <String, dynamic>{},
      );

      expect(result, isA<Error<Map<String, dynamic>>>());
      final ApiProviderException ex =
          (result as Error<Map<String, dynamic>>).errorValue;
      expect(ex, isA<ApiProviderException>());
    });
    test("getRequest returns error if not connected", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.none]);
      final Result<Map<String, dynamic>> result = await apiService.getRequest(
        path: "/test",
      );
      expect(result, isA<Error<Map<String, dynamic>>>());
      expect(
        (result as Error<Map<String, dynamic>>).errorValue,
        isA<ApiProviderException>(),
      );
    });

    test("deleteRequest returns Error when Dio throws", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);

      final DioException dioException = DioException(
        requestOptions: RequestOptions(path: "/delerr"),
      );

      when(
        () => mockDioClient.delete("/delerr", null, null),
      ).thenThrow(dioException);

      final Result<Map<String, dynamic>> result = await apiService
          .deleteRequest(path: "/delerr");

      expect(result, isA<Error<Map<String, dynamic>>>());
      final ApiProviderException ex =
          (result as Error<Map<String, dynamic>>).errorValue;
      expect(ex, isA<ApiProviderException>());
    });

    test(
      "getRequest parses server error JSON when message equals special string",
      () async {
        when(() => mockConnectivity.checkConnectivity()).thenAnswer(
          (_) async => <ConnectivityResult>[ConnectivityResult.wifi],
        );

        final Map<String, String?> serverMap = <String, String?>{
          "type": "tt",
          "title": "tit",
          "detail": "det",
          "instance": "inst",
          "status": "st",
          "timetamp": "ts",
        };

        final DioException dioException = DioException(
          requestOptions: RequestOptions(path: "/srverr"),
          error: "Error response from server",
          message: "",
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: "/srverr"),
            statusCode: 500,
            data: json.encode(serverMap),
          ),
        );

        when(
          () => mockDioClient.get("/srverr", null, null),
        ).thenThrow(dioException);

        final Result<Map<String, dynamic>> result = await apiService.getRequest(
          path: "/srverr",
        );
        expect(result, isA<Error<Map<String, dynamic>>>());
        final ApiProviderException ex =
            (result as Error<Map<String, dynamic>>).errorValue;
        expect(ex.type, equals(serverMap["type"]));
        expect(ex.title, equals(serverMap["title"]));
        expect(ex.detail, equals(serverMap["detail"]));
        expect(ex.instance, equals(serverMap["instance"]));
        expect(ex.status, equals(serverMap["status"]));
        expect(ex.timetamp, equals(serverMap["timetamp"]));
      },
    );
    test("postRequest returns error if not connected", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.none]);
      final Result<Map<String, dynamic>> result = await apiService.postRequest(
        path: "/test",
        body: <String, dynamic>{},
      );
      expect(result, isA<Error<Map<String, dynamic>>>());
      expect(
        (result as Error<Map<String, dynamic>>).errorValue,
        isA<ApiProviderException>(),
      );
    });

    test("putRequest returns error if not connected", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.none]);
      final Result<Map<String, dynamic>> result = await apiService.putRequest(
        path: "/test",
        body: <String, dynamic>{},
      );
      expect(result, isA<Error<Map<String, dynamic>>>());
      expect(
        (result as Error<Map<String, dynamic>>).errorValue,
        isA<ApiProviderException>(),
      );
    });

    test("deleteRequest returns error if not connected", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.none]);
      final Result<Map<String, dynamic>> result = await apiService
          .deleteRequest(path: "/test");
      expect(result, isA<Error<Map<String, dynamic>>>());
      expect(
        (result as Error<Map<String, dynamic>>).errorValue,
        isA<ApiProviderException>(),
      );
    });

    test("uploadFile returns error if not connected", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.none]);
      final Result<Map<String, dynamic>> result = await apiService.uploadFile(
        path: "/upload",
      );
      expect(result, isA<Error<Map<String, dynamic>>>());
      expect(
        (result as Error<Map<String, dynamic>>).errorValue,
        isA<ApiProviderException>(),
      );
    });

    test("downloadFile returns error if not connected", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.none]);
      final Result<Map<String, dynamic>> result = await apiService.downloadFile(
        fileUrl: "/file",
        savePath: "/tmp/file",
      );
      expect(result, isA<Error<Map<String, dynamic>>>());
      expect(
        (result as Error<Map<String, dynamic>>).errorValue,
        isA<ApiProviderException>(),
      );
    });

    test("getRequest success path", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);

      final Response<dynamic> response = Response<dynamic>(
        requestOptions: RequestOptions(path: "/test"),
        data: <String, dynamic>{"ok": true},
        statusCode: 200,
      );

      when(
        () => mockDioClient.get("/test", null, null),
      ).thenAnswer((_) async => response);

      final Result<Map<String, dynamic>> result = await apiService.getRequest(
        path: "/test",
      );
      expect(result, isA<Success<Map<String, dynamic>>>());
      expect((result as Success<Map<String, dynamic>>).value["ok"], isTrue);
    });

    test("postRequest success path", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);

      final Response<dynamic> response = Response<dynamic>(
        requestOptions: RequestOptions(path: "/post"),
        data: <String, dynamic>{"created": true},
        statusCode: 200,
      );

      when(
        () => mockDioClient.post("/post", <String, dynamic>{}, null, null),
      ).thenAnswer((_) async => response);

      final Result<Map<String, dynamic>> result = await apiService.postRequest(
        path: "/post",
        body: <String, dynamic>{},
      );
      expect(result, isA<Success<Map<String, dynamic>>>());
      expect(
        (result as Success<Map<String, dynamic>>).value["created"],
        isTrue,
      );
    });

    test("putRequest success path", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);

      final Response<dynamic> response = Response<dynamic>(
        requestOptions: RequestOptions(path: "/put"),
        data: <String, dynamic>{"updated": true},
        statusCode: 200,
      );

      when(
        () => mockDioClient.put("/put", <String, dynamic>{}, null, null),
      ).thenAnswer((_) async => response);

      final Result<Map<String, dynamic>> result = await apiService.putRequest(
        path: "/put",
        body: <String, dynamic>{},
      );
      expect(result, isA<Success<Map<String, dynamic>>>());
      expect(
        (result as Success<Map<String, dynamic>>).value["updated"],
        isTrue,
      );
    });

    test("deleteRequest success path", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);

      final Response<dynamic> response = Response<dynamic>(
        requestOptions: RequestOptions(path: "/delete"),
        data: <String, dynamic>{"deleted": true},
        statusCode: 200,
      );

      when(
        () => mockDioClient.delete("/delete", null, null),
      ).thenAnswer((_) async => response);

      final Result<Map<String, dynamic>> result = await apiService
          .deleteRequest(path: "/delete");
      expect(result, isA<Success<Map<String, dynamic>>>());
      expect(
        (result as Success<Map<String, dynamic>>).value["deleted"],
        isTrue,
      );
    });

    test("postStreamRequest yields stream chunks", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);

      // Create a ResponseBody with a stream of bytes representing two lines
      final StreamController<Uint8List> controller =
          StreamController<Uint8List>();
      final ResponseBody responseBody = ResponseBody(controller.stream, 200);
      final Response<ResponseBody> response = Response<ResponseBody>(
        requestOptions: RequestOptions(path: "/stream"),
        data: responseBody,
        statusCode: 200,
      );

      when(
        () => mockDioClient.postStream(
          "/stream",
          <String, dynamic>{},
          null,
          null,
        ),
      ).thenAnswer((_) async => response);

      // Start listening to the stream (start subscription before adding events)
      final Stream<String> stream = apiService.postStreamRequest(
        path: "/stream",
        body: <String, dynamic>{},
      );
      final Future<List<String>> collected = stream.toList();

      // Send two lines and close controller
      controller
        ..add(Uint8List.fromList(utf8.encode("line1\n")))
        ..add(Uint8List.fromList(utf8.encode("line2\n")));
      await controller.close();

      final List<String> chunks = await collected;
      expect(chunks, containsAll(<String>["line1", "line2"]));
    });

    test("getRequest returns ApiProviderException when Dio throws", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);

      final DioException dioException = DioException(
        requestOptions: RequestOptions(path: "/error"),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: "/error"),
          statusCode: 500,
          data: <String, String>{"msg": "fail"},
        ),
      );

      when(
        () => mockDioClient.get("/error", null, null),
      ).thenThrow(dioException);

      final Result<Map<String, dynamic>> result = await apiService.getRequest(
        path: "/error",
      );
      expect(result, isA<Error<Map<String, dynamic>>>());
      final ApiProviderException ex =
          (result as Error<Map<String, dynamic>>).errorValue;
      expect(ex, isA<ApiProviderException>());
      expect(ex.statusCode, 500);
    });

    test("getRequest handles DioException with error as String", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);

      final DioException dioException = DioException(
        requestOptions: RequestOptions(path: "/strerr"),
        error: "plain error",
        message: "",
      );

      when(
        () => mockDioClient.get("/strerr", null, null),
      ).thenThrow(dioException);

      final Result<Map<String, dynamic>> result = await apiService.getRequest(
        path: "/strerr",
      );
      expect(result, isA<Error<Map<String, dynamic>>>());
      final ApiProviderException ex =
          (result as Error<Map<String, dynamic>>).errorValue;
      expect(ex.message, contains("plain error"));
    });

    test(
      "getRequest handles DioException with HandshakeException error",
      () async {
        when(() => mockConnectivity.checkConnectivity()).thenAnswer(
          (_) async => <ConnectivityResult>[ConnectivityResult.wifi],
        );

        // Use HandshakeException from dart:io to simulate TLS error
        const HandshakeException hs = HandshakeException("tls failed");

        final DioException dioException = DioException(
          requestOptions: RequestOptions(path: "/hs"),
          error: hs,
          message: "",
        );

        when(
          () => mockDioClient.get("/hs", null, null),
        ).thenThrow(dioException);

        final Result<Map<String, dynamic>> result = await apiService.getRequest(
          path: "/hs",
        );
        expect(result, isA<Error<Map<String, dynamic>>>());
        final ApiProviderException ex =
            (result as Error<Map<String, dynamic>>).errorValue;
        expect(ex.message, contains("tls failed"));
      },
    );

    test(
      "postRequest returns ApiProviderException when non-Dio error is thrown",
      () async {
        when(() => mockConnectivity.checkConnectivity()).thenAnswer(
          (_) async => <ConnectivityResult>[ConnectivityResult.wifi],
        );

        when(
          () => mockDioClient.post("/boom", <String, dynamic>{}, null, null),
        ).thenThrow(Exception("boom"));

        final Result<Map<String, dynamic>> result = await apiService
            .postRequest(path: "/boom", body: <String, dynamic>{});
        expect(result, isA<Error<Map<String, dynamic>>>());
        final ApiProviderException ex =
            (result as Error<Map<String, dynamic>>).errorValue;
        expect(ex.statusCode, isNotNull);
        expect(ex.message, contains("Exception"));
      },
    );

    test("getRequest returns Error when response is non-200", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);

      final Response<dynamic> response = Response<dynamic>(
        requestOptions: RequestOptions(path: "/bad"),
        data: <String, dynamic>{"err": "bad"},
        statusCode: 400,
      );

      when(
        () => mockDioClient.get("/bad", null, null),
      ).thenAnswer((_) async => response);

      final Result<Map<String, dynamic>> result = await apiService.getRequest(
        path: "/bad",
      );
      expect(result, isA<Error<Map<String, dynamic>>>());
      final ApiProviderException ex =
          (result as Error<Map<String, dynamic>>).errorValue;
      expect(ex.statusCode, 400);
      expect(ex.response, <String, String>{"err": "bad"});
    });

    test("postRequest returns Error when response is non-200", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);

      final Response<dynamic> response = Response<dynamic>(
        requestOptions: RequestOptions(path: "/postbad"),
        data: <String, dynamic>{"err": "bad"},
        statusCode: 500,
      );

      when(
        () => mockDioClient.post("/postbad", <String, dynamic>{}, null, null),
      ).thenAnswer((_) async => response);

      final Result<Map<String, dynamic>> result = await apiService.postRequest(
        path: "/postbad",
        body: <String, dynamic>{},
      );
      expect(result, isA<Error<Map<String, dynamic>>>());
      final ApiProviderException ex =
          (result as Error<Map<String, dynamic>>).errorValue;
      expect(ex.statusCode, 500);
    });

    test("putRequest returns Error when response is non-200", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);

      final Response<dynamic> response = Response<dynamic>(
        requestOptions: RequestOptions(path: "/putbad"),
        data: <String, dynamic>{"err": "bad"},
        statusCode: 418,
      );

      when(
        () => mockDioClient.put("/putbad", <String, dynamic>{}, null, null),
      ).thenAnswer((_) async => response);

      final Result<Map<String, dynamic>> result = await apiService.putRequest(
        path: "/putbad",
        body: <String, dynamic>{},
      );
      expect(result, isA<Error<Map<String, dynamic>>>());
      final ApiProviderException ex =
          (result as Error<Map<String, dynamic>>).errorValue;
      expect(ex.statusCode, 418);
    });

    test("deleteRequest returns Error when response is non-200", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);

      final Response<dynamic> response = Response<dynamic>(
        requestOptions: RequestOptions(path: "/delbad"),
        data: <String, dynamic>{"err": "bad"},
        statusCode: 404,
      );

      when(
        () => mockDioClient.delete("/delbad", null, null),
      ).thenAnswer((_) async => response);

      final Result<Map<String, dynamic>> result = await apiService
          .deleteRequest(path: "/delbad");
      expect(result, isA<Error<Map<String, dynamic>>>());
      final ApiProviderException ex =
          (result as Error<Map<String, dynamic>>).errorValue;
      expect(ex.statusCode, 404);
    });

    test("uploadFile returns Error when response is non-200", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);

      final Response<dynamic> response = Response<dynamic>(
        requestOptions: RequestOptions(path: "/uplbad"),
        data: <String, dynamic>{"err": "bad"},
        statusCode: 403,
      );

      when(
        () => mockDioClient.uploadFile("/uplbad", null, null, null),
      ).thenAnswer((_) async => response);

      final Result<Map<String, dynamic>> result = await apiService.uploadFile(
        path: "/uplbad",
      );
      expect(result, isA<Error<Map<String, dynamic>>>());
      final ApiProviderException ex =
          (result as Error<Map<String, dynamic>>).errorValue;
      expect(ex.statusCode, 403);
    });

    test("downloadFile returns Error when response is non-200", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);

      final Response<dynamic> response = Response<dynamic>(
        requestOptions: RequestOptions(path: "/downbad"),
        data: <String, dynamic>{"err": "bad"},
        statusCode: 402,
      );

      when(
        () => mockDioClient.downloadFile("/file", "/tmp", null, null, null),
      ).thenAnswer((_) async => response);

      final Result<Map<String, dynamic>> result = await apiService.downloadFile(
        fileUrl: "/file",
        savePath: "/tmp",
      );
      expect(result, isA<Error<Map<String, dynamic>>>());
      final ApiProviderException ex =
          (result as Error<Map<String, dynamic>>).errorValue;
      expect(ex.statusCode, 402);
    });

    test("uploadFile returns Error when DioException thrown", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);

      final DioException dioException = DioException(
        requestOptions: RequestOptions(path: "/uerr"),
      );
      when(
        () => mockDioClient.uploadFile("/uerr", null, null, null),
      ).thenThrow(dioException);

      final Result<Map<String, dynamic>> result = await apiService.uploadFile(
        path: "/uerr",
      );
      expect(result, isA<Error<Map<String, dynamic>>>());
      final ApiProviderException ex =
          (result as Error<Map<String, dynamic>>).errorValue;
      expect(ex, isA<ApiProviderException>());
    });

    test("downloadFile returns Error when generic exception thrown", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);

      when(
        () => mockDioClient.downloadFile("/file", "/tmp", null, null, null),
      ).thenThrow(Exception("disk full"));

      final Result<Map<String, dynamic>> result = await apiService.downloadFile(
        fileUrl: "/file",
        savePath: "/tmp",
      );
      expect(result, isA<Error<Map<String, dynamic>>>());
      final ApiProviderException ex =
          (result as Error<Map<String, dynamic>>).errorValue;
      expect(ex.message, contains("Exception"));
    });

    test("isConnected treats empty list as not connected", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[]);
      final Result<Map<String, dynamic>> result = await apiService.getRequest(
        path: "/willfail",
      );
      expect(result, isA<Error<Map<String, dynamic>>>());
    });

    test("uploadFile success path", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);

      final Response<dynamic> response = Response<dynamic>(
        requestOptions: RequestOptions(path: "/upload"),
        data: <String, dynamic>{"uploaded": true},
        statusCode: 200,
      );

      when(
        () => mockDioClient.uploadFile("/upload", null, null, null),
      ).thenAnswer((_) async => response);

      final Result<Map<String, dynamic>> result = await apiService.uploadFile(
        path: "/upload",
      );
      expect(result, isA<Success<Map<String, dynamic>>>());
      expect(
        (result as Success<Map<String, dynamic>>).value["uploaded"],
        isTrue,
      );
    });

    test("downloadFile success path", () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);

      final Response<dynamic> response = Response<dynamic>(
        requestOptions: RequestOptions(path: "/download"),
        data: <String, dynamic>{"downloaded": true},
        statusCode: 200,
      );

      when(
        () => mockDioClient.downloadFile("/file", "/tmp", null, null, null),
      ).thenAnswer((_) async => response);

      final Result<Map<String, dynamic>> result = await apiService.downloadFile(
        fileUrl: "/file",
        savePath: "/tmp",
      );
      expect(result, isA<Success<Map<String, dynamic>>>());
      expect(
        (result as Success<Map<String, dynamic>>).value["downloaded"],
        isTrue,
      );
    });

    test(
      "postStreamRequest throws ApiProviderException when no stream",
      () async {
        when(() => mockConnectivity.checkConnectivity()).thenAnswer(
          (_) async => <ConnectivityResult>[ConnectivityResult.wifi],
        );

        final Response<ResponseBody> response = Response<ResponseBody>(
          requestOptions: RequestOptions(path: "/nostream"),
          statusCode: 200,
        );

        when(
          () => mockDioClient.postStream(
            "/nostream",
            <String, dynamic>{},
            null,
            null,
          ),
        ).thenAnswer((_) async => response);

        final Stream<String> stream = apiService.postStreamRequest(
          path: "/nostream",
          body: <String, dynamic>{},
        );
        await expectLater(
          stream.toList(),
          throwsA(isA<ApiProviderException>()),
        );
      },
    );

    test(
      """postStreamRequest throws ApiProviderException when postStream throws DioException""",
      () async {
        when(() => mockConnectivity.checkConnectivity()).thenAnswer(
          (_) async => <ConnectivityResult>[ConnectivityResult.wifi],
        );

        final DioException dioException = DioException(
          requestOptions: RequestOptions(path: "/err"),
        );
        when(
          () =>
              mockDioClient.postStream("/err", <String, dynamic>{}, null, null),
        ).thenThrow(dioException);

        final Stream<String> stream = apiService.postStreamRequest(
          path: "/err",
          body: <String, dynamic>{},
        );
        await expectLater(
          stream.toList(),
          throwsA(isA<ApiProviderException>()),
        );
      },
    );

    test("dioClient and connectivityInstance getters/setters work", () {
      final DioClient newClient = DioClient(
        baseUrl: "https://example.com",
        timeoutDuration: 1,
        isDebugModeEnabled: false,
        dataIntegrityEnabled: false,
        sslPinningEnabled: false,
        certificatePinningModel: null,
        payloadEncryption: false,
        publicKeyPath: "",
        privateKeyPath: "",
      );
      apiService.dioClient = newClient;
      expect(apiService.dioClient, same(newClient));

      final Connectivity newConn = Connectivity();
      apiService.connectivityInstance = newConn;
      expect(apiService.connectivityInstance, same(newConn));
    });
  });
}
