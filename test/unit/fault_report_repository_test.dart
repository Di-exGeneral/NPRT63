import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:hydroalert_reports/data/repositories/fault_report_repository.dart';
import 'package:hydroalert_reports/domain/models/fault_report.dart';
import 'package:hydroalert_reports/services/api_service.dart';

class MockHttpClient extends http.BaseClient {
  final Future<http.StreamedResponse> Function(http.BaseRequest request) _handler;

  MockHttpClient(this._handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => _handler(request);
}

void main() {
  group('FaultReportRepository & ApiService Integration Tests', () {
    test('InMemoryFaultReportRepository exposes and utilizes ApiService', () {
      final customApiService = ApiService(baseUrl: 'http://custom-api:9000');
      final repository = InMemoryFaultReportRepository(apiService: customApiService);

      expect(repository.apiService, same(customApiService));
      expect(repository.apiService.baseUrl, 'http://custom-api:9000');
    });

    test('createReportOnApi posts report to ApiService and adds to repository', () async {
      bool postCalled = false;
      final mockClient = MockHttpClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/fault-reports/');
        postCalled = true;

        final byteData = await request.finalize().toBytes();
        final json = jsonDecode(utf8.decode(byteData));

        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'id': json['id'],
            'title': json['title'],
            'location': json['location'],
            'description': json['description'],
            'status': 'pending',
            'priority': 'high',
          }))),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiService = ApiService(client: mockClient);
      final repository = InMemoryFaultReportRepository(apiService: apiService);

      const report = FaultReport(
        id: 'REP-777',
        title: 'Broken Main Hydrant',
        location: 'Sector K',
        description: 'Hydrant burst',
        reportedBy: 'Inspector',
        reportedDate: '2026-05-09',
        dueDate: '2026-05-11',
        status: ReportStatus.pending,
        priority: ReportPriority.high,
      );

      final created = await repository.createReportOnApi(report);
      expect(postCalled, isTrue);
      expect(created.id, 'REP-777');
      expect(repository.getReportById('REP-777'), isNotNull);
    });

    test('fetchReportsFromApi retrieves reports from ApiService and updates cache', () async {
      bool getCalled = false;
      final mockClient = MockHttpClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/fault-reports/');
        getCalled = true;

        final reportsJson = [
          {
            'id': 'REP-API-1',
            'title': 'Remote Pump Failure',
            'location': 'Sector D',
            'description': 'Overheating',
            'status': 'pending',
            'priority': 'urgent',
          }
        ];

        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode(reportsJson))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiService = ApiService(client: mockClient);
      final repository = InMemoryFaultReportRepository(apiService: apiService);

      final fetched = await repository.fetchReportsFromApi();
      expect(getCalled, isTrue);
      expect(fetched.length, 1);
      expect(fetched.first.id, 'REP-API-1');
      expect(fetched.first.title, 'Remote Pump Failure');
    });

    test('updateReportStatusOnApi sends PATCH to ApiService and updates local repository', () async {
      bool patchCalled = false;
      final mockClient = MockHttpClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, '/fault-reports/REP-101/status');
        expect(request.url.queryParameters['changedBy'], 'Maintenance User');
        patchCalled = true;

        final byteData = await request.finalize().toBytes();
        final json = jsonDecode(utf8.decode(byteData));
        expect(json['status'], 'In Progress');

        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'id': 'REP-101',
            'title': 'Water Pump Inspection',
            'location': 'Sector A - Building 3',
            'description': 'Routine inspection',
            'status': 'in progress',
            'priority': 'high',
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiService = ApiService(client: mockClient);
      final repository = InMemoryFaultReportRepository(apiService: apiService);

      final updated = await repository.updateReportStatusOnApi(
        'REP-101',
        ReportStatus.inProgress,
        changedBy: 'Maintenance User',
      );

      expect(patchCalled, isTrue);
      expect(updated, isNotNull);
      expect(updated!.status, ReportStatus.inProgress);
      expect(repository.getReportById('REP-101')?.status, ReportStatus.inProgress);
    });

    test('ApiFaultReportRepository updates cached reports via updateReportStatusOnApi', () async {
      bool patchCalled = false;
      final mockClient = MockHttpClient((request) async {
        expect(request.method, 'PATCH');
        patchCalled = true;

        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'id': 'REP-API-1',
            'title': 'Remote Pump Failure',
            'location': 'Sector D',
            'description': 'Overheating',
            'status': 'completed',
            'priority': 'urgent',
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiService = ApiService(client: mockClient);
      final repository = ApiFaultReportRepository(apiService: apiService);

      repository.addReport(const FaultReport(
        id: 'REP-API-1',
        title: 'Remote Pump Failure',
        location: 'Sector D',
        description: 'Overheating',
        reportedBy: 'Inspector',
        reportedDate: '2026-05-09',
        dueDate: '2026-05-11',
        status: ReportStatus.inProgress,
        priority: ReportPriority.urgent,
      ));

      final updated = await repository.updateReportStatusOnApi(
        'REP-API-1',
        ReportStatus.completed,
        changedBy: 'Maintenance User',
      );

      expect(patchCalled, isTrue);
      expect(updated?.status, ReportStatus.completed);
      expect(repository.getReportById('REP-API-1')?.status, ReportStatus.completed);
    });
  });
}
