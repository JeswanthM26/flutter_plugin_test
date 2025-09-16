import 'package:flutter_test/flutter_test.dart';
import 'package:apz_deeplink/deeplink_data.dart'; // Adjust this import path

void main() {
  group('DeeplinkData', () {
    // Test case for the primary constructor
    test('DeeplinkData constructor assigns all properties correctly', () {
      final DeeplinkData data = DeeplinkData(
        host: 'example.com',
        path: '/test/path',
        scheme: 'https',
        queryParameters: {'id': '123', 'name': 'test'},
      );

      expect(data.host, 'example.com');
      expect(data.path, '/test/path');
      expect(data.scheme, 'https');
      expect(data.queryParameters, {'id': '123', 'name': 'test'});
    });

    // Test cases for the fromUri factory constructor

    test('fromUri factory creates DeeplinkData from a simple URI', () {
      final Uri uri = Uri.parse('https://example.com/path');
      final DeeplinkData data = DeeplinkData.fromUri(uri);

      expect(data.host, 'example.com');
      expect(data.path, '/path');
      expect(data.scheme, 'https');
      expect(data.queryParameters, isEmpty);
    });

    test('fromUri factory creates DeeplinkData from a URI with query parameters', () {
      final Uri uri = Uri.parse('myapp://product?id=456&category=books');
      final DeeplinkData data = DeeplinkData.fromUri(uri);

      expect(data.host, 'product'); // For custom schemes, host is often the first path segment
      expect(data.path, ''); // Path is empty if host is the first segment
      expect(data.scheme, 'myapp');
      expect(data.queryParameters, {'id': '456', 'category': 'books'});
    });

    test('fromUri factory handles URI with no host but a path', () {
      final Uri uri = Uri.parse('/path/only?param=value');
      final DeeplinkData data = DeeplinkData.fromUri(uri);

      expect(data.host, '');
      expect(data.path, '/path/only');
      expect(data.scheme, '');
      expect(data.queryParameters, {'param': 'value'});
    });

    test('fromUri factory handles URI with no path or query parameters', () {
      final Uri uri = Uri.parse('myapp://');
      final DeeplinkData data = DeeplinkData.fromUri(uri);

      expect(data.host, '');
      expect(data.path, '');
      expect(data.scheme, 'myapp');
      expect(data.queryParameters, isEmpty);
    });

    test('fromUri factory handles complex URI with multiple query parameters', () {
      final Uri uri = Uri.parse('https://shop.com/items/details?sku=XYZ&color=red&size=L');
      final DeeplinkData data = DeeplinkData.fromUri(uri);

      expect(data.host, 'shop.com');
      expect(data.path, '/items/details');
      expect(data.scheme, 'https');
      expect(data.queryParameters, {'sku': 'XYZ', 'color': 'red', 'size': 'L'});
    });

    test('fromUri factory handles URI with encoded characters', () {
      final Uri uri = Uri.parse('https://example.com/search?q=hello%20world&page=1');
      final DeeplinkData data = DeeplinkData.fromUri(uri);

      expect(data.queryParameters, {'q': 'hello world', 'page': '1'});
    });

    // Test case for toString() method
    test('toString() returns a correct string representation', () {
      final DeeplinkData data = DeeplinkData(
        host: 'app.example.com',
        path: '/profile',
        scheme: 'customapp',
        queryParameters: {'user_id': 'abc'},
      );

      expect(data.toString(),
          "DeeplinkData(host: app.example.com, path: /profile, scheme: customapp, queryParameters: {user_id: abc})");
    });


    test('DeeplinkData instances with different properties are not equal', () {
      final DeeplinkData data1 = DeeplinkData(
        host: 'host.com',
        path: '/path1',
        scheme: 'scheme1',
        queryParameters: {'a': '1'},
      );
      final DeeplinkData data2 = DeeplinkData(
        host: 'host.com',
        path: '/path2', // Different path
        scheme: 'scheme1',
        queryParameters: {'a': '1'},
      );

      expect(data1, isNot(data2));
      expect(data1.hashCode, isNot(data2.hashCode));
    });

    test('DeeplinkData instances with different query parameters are not equal', () {
      final DeeplinkData data1 = DeeplinkData(
        host: 'host.com',
        path: '/path1',
        scheme: 'scheme1',
        queryParameters: {'a': '1', 'b': '2'},
      );
      final DeeplinkData data2 = DeeplinkData(
        host: 'host.com',
        path: '/path1',
        scheme: 'scheme1',
        queryParameters: {'a': '1', 'b': '3'}, // Different query param value
      );

      expect(data1, isNot(data2));
      expect(data1.hashCode, isNot(data2.hashCode));
    });
  });
}