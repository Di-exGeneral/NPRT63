import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:hydroalert_reports/core/constants/app_constants.dart';
import 'package:hydroalert_reports/services/api_service.dart';

class MockHttpClient extends http.BaseClient {
  final Future<http.StreamedResponse> Function(http.BaseRequest request) _handler;

  MockHttpClient(this._handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => _handler(request);
}

void main() {
  group('ApiService Tests', () {
    test('initializes with default or custom baseUrl', () {
      final defaultService = ApiService();
      expect(defaultService.baseUrl, AppConstants.baseUrl);

      final customService = ApiService(baseUrl: 'https://api.hydroalert.gov');
      expect(customService.baseUrl, 'https://api.hydroalert.gov');
    });

    test('performs successful GET request and decodes JSON', () async {
      final mockClient = MockHttpClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/fault-reports/');
        expect(request.headers['Accept'], 'application/json');

        final body = jsonEncode([
          {'id': 'REP-101', 'title': 'Pipe Leak'}
        ]);
        return http.StreamedResponse(
          Stream.value(utf8.encode(body)),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ApiService(baseUrl: 'http://localhost:8000', client: mockClient);
      final result = await service.get('/fault-reports/');

      expect(result, isA<List>());
      expect((result as List).first['title'], 'Pipe Leak');
    });

    test('performs GET with query parameters', () async {
      final mockClient = MockHttpClient((request) async {
        expect(request.url.queryParameters['status'], 'pending');
        expect(request.url.queryParameters['limit'], '10');

        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({'count': 1}))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ApiService(baseUrl: 'http://localhost:8000', client: mockClient);
      final result = await service.get('/fault-reports/', queryParameters: {
        'status': 'pending',
        'limit': 10,
      });

      expect(result, isA<Map>());
      expect(result['count'], 1);
    });

    test('performs successful POST request sending JSON payload', () async {
      final mockClient = MockHttpClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/fault-reports/');
        expect(request.headers['Content-Type'], 'application/json');

        final byteData = await request.finalize().toBytes();
        final sentJson = jsonDecode(utf8.decode(byteData));
        expect(sentJson['title'], 'New Broken Valve');

        final responseBody = jsonEncode({
          'id': 'REP-999',
          'title': sentJson['title'],
          'status': 'pending',
        });

        return http.StreamedResponse(
          Stream.value(utf8.encode(responseBody)),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ApiService(baseUrl: 'http://localhost:8000', client: mockClient);
      final result = await service.post('/fault-reports/', body: {
        'title': 'New Broken Valve',
        'location': 'Sector B',
      });

      expect(result['id'], 'REP-999');
      expect(result['title'], 'New Broken Valve');
    });

    test('throws ApiException on HTTP 400 with detail message', () async {
      final mockClient = MockHttpClient((request) async {
        final body = jsonEncode({'detail': 'Validation error: title required'});
        return http.StreamedResponse(
          Stream.value(utf8.encode(body)),
          400,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ApiService(baseUrl: 'http://localhost:8000', client: mockClient);

      expect(
        () => service.post('/fault-reports/', body: {}),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 400)
            .having((e) => e.message, 'message', 'Validation error: title required')),
      );
    });

    test('throws ApiException on HTTP 404 not found', () async {
      final mockClient = MockHttpClient((request) async {
        final body = jsonEncode({'message': 'Report not found'});
        return http.StreamedResponse(
          Stream.value(utf8.encode(body)),
          404,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ApiService(baseUrl: 'http://localhost:8000', client: mockClient);

      expect(
        () => service.get('/fault-reports/999'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 404)
            .having((e) => e.message, 'message', 'Report not found')),
      );
    });

    test('throws ApiException on HTTP 500 server error', () async {
      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode('Internal Server Error')),
          500,
        );
      });

      final service = ApiService(baseUrl: 'http://localhost:8000', client: mockClient);

      expect(
        () => service.get('/fault-reports/'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 500)),
      );
    });

    test('performs successful PATCH request with query parameters and JSON payload', () async {
      bool patchCalled = false;
      final mockClient = MockHttpClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, '/fault-reports/REP-101/status');
        expect(request.url.queryParameters['changedBy'], 'Maintenance User');
        patchCalled = true;

        final byteData = await request.finalize().toBytes();
        final payload = jsonDecode(utf8.decode(byteData));
        expect(payload['status'], 'in progress');

        final responseBody = jsonEncode({
          'id': 'REP-101',
          'status': 'in progress',
        });
        return http.StreamedResponse(
          Stream.value(utf8.encode(responseBody)),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ApiService(baseUrl: 'http://localhost:8000', client: mockClient);
      final result = await service.patch(
        '/fault-reports/REP-101/status',
        queryParameters: {'changedBy': 'Maintenance User'},
        body: {'status': 'in progress'},
      );

      expect(patchCalled, isTrue);
      expect(result['status'], 'in progress');
    });

    test('performs successful DELETE request', () async {
      bool deleteCalled = false;
      final mockClient = MockHttpClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path, '/fault-reports/REP-101');
        deleteCalled = true;

        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({'message': 'deleted'}))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ApiService(baseUrl: 'http://localhost:8000', client: mockClient);
      final result = await service.delete('/fault-reports/REP-101');

      expect(deleteCalled, isTrue);
      expect(result['message'], 'deleted');
    });

    test('performs successful PUT request', () async {
      bool putCalled = false;
      final mockClient = MockHttpClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.path, '/fault-reports/REP-101');
        putCalled = true;

        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({'id': 'REP-101', 'title': 'Updated Title'}))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ApiService(baseUrl: 'http://localhost:8000', client: mockClient);
      final result = await service.put('/fault-reports/REP-101', body: {'title': 'Updated Title'});

      expect(putCalled, isTrue);
      expect(result['title'], 'Updated Title');
    });
  });
}
