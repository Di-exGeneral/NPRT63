import 'package:flutter_test/flutter_test.dart';
import 'package:hydroalert_reports/data/repositories/fault_report_repository.dart';
import 'package:hydroalert_reports/domain/models/fault_report.dart';
import 'package:hydroalert_reports/domain/models/user_role.dart';
import 'package:hydroalert_reports/ui/features/reports/view_models/reports_view_model.dart';

void main() {
  group('UserRole & Admin Check Unit Tests', () {
    test('UserRole properties correctly distinguish admin and non-admin', () {
      expect(UserRole.admin.isAdmin, isTrue);
      expect(UserRole.admin.canCreateFaultReport, isFalse);

      expect(UserRole.maintenance.isAdmin, isFalse);
      expect(UserRole.maintenance.canCreateFaultReport, isTrue);

      expect(UserRole.resident.isAdmin, isFalse);
      expect(UserRole.resident.canCreateFaultReport, isTrue);

      expect(UserRole.fromString('MunicipalAdmin'), UserRole.admin);
      expect(UserRole.fromString('Administrator'), UserRole.admin);
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('MaintenanceTeam'), UserRole.maintenance);
    });

    test('ReportsViewModel allows report creation for maintenance users', () {
      final repository = InMemoryFaultReportRepository();
      final viewModel = ReportsViewModel(
        repository: repository,
        userRole: UserRole.maintenance,
      );

      final initialCount = viewModel.totalCount;

      viewModel.addNewReport(
        title: 'Maintenance Found Leak',
        location: 'Sector A - Valve 1',
        description: 'Minor joint leak',
        reportedBy: 'Maintenance User',
        reportedDate: '2026-05-09',
        dueDate: '2026-05-11',
        status: ReportStatus.pending,
        priority: ReportPriority.medium,
      );

      expect(viewModel.totalCount, initialCount + 1);
      expect(viewModel.allReports.first.title, 'Maintenance Found Leak');
    });

    test('ReportsViewModel throws StateError when Admin attempts to addNewReport', () {
      final repository = InMemoryFaultReportRepository();
      final viewModel = ReportsViewModel(
        repository: repository,
        userRole: UserRole.admin,
      );

      expect(viewModel.isAdmin, isTrue);
      expect(viewModel.canCreateFaultReport, isFalse);

      final initialCount = viewModel.totalCount;

      expect(
        () => viewModel.addNewReport(
          title: 'Admin Trying To Create Report',
          location: 'Sector Z',
          description: 'Should fail',
          reportedBy: 'Admin User',
          reportedDate: '2026-05-09',
          dueDate: '2026-05-11',
          status: ReportStatus.pending,
          priority: ReportPriority.high,
        ),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Admin users are not permitted to create fault reports'),
        )),
      );

      expect(viewModel.totalCount, initialCount);
    });

    test('ReportsViewModel respects role change from maintenance to admin', () {
      final repository = InMemoryFaultReportRepository();
      final viewModel = ReportsViewModel(repository: repository);

      expect(viewModel.isAdmin, isFalse);

      viewModel.setUserRole(UserRole.admin);
      expect(viewModel.isAdmin, isTrue);

      expect(
        () => viewModel.addNewReport(
          title: 'Blocked Report',
          location: 'Sector Z',
          description: 'Should fail',
          reportedBy: 'Admin',
          reportedDate: '2026-05-09',
          dueDate: '2026-05-11',
          status: ReportStatus.pending,
          priority: ReportPriority.high,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('ReportsViewModel manages loading state and syncs with API', () async {
      final repository = InMemoryFaultReportRepository();
      final viewModel = ReportsViewModel(repository: repository);

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);

      final future = viewModel.fetchReportsFromApi();
      expect(viewModel.isLoading, isTrue);
      await future;
      expect(viewModel.isLoading, isFalse);
    });

    test('ReportsViewModel updateReportStatusOnApi updates report status and reloads', () async {
      final repository = InMemoryFaultReportRepository();
      final viewModel = ReportsViewModel(repository: repository);

      await viewModel.updateReportStatusOnApi('REP-101', ReportStatus.inProgress);
      final report = viewModel.allReports.firstWhere((r) => r.id == 'REP-101');
      expect(report.status, ReportStatus.inProgress);
    });
  });
}
