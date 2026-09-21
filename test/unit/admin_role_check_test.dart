import 'package:flutter_test/flutter_test.dart';
import 'package:hydroalert_reports/data/repositories/fault_report_repository.dart';
import 'package:hydroalert_reports/domain/models/fault_report.dart';
import 'package:hydroalert_reports/domain/models/user_role.dart';
import 'package:hydroalert_reports/ui/features/reports/view_models/reports_view_model.dart';

void main() {
  group('UserRole & Role Restrictions Unit Tests', () {
    test('UserRole properties correctly enforce backend role permissions', () {
      expect(UserRole.admin.isAdmin, isTrue);
      expect(UserRole.admin.canCreateFaultReport, isFalse);
      expect(UserRole.admin.canManageReports, isTrue);
      expect(UserRole.admin.canUpdateStatus, isTrue);

      expect(UserRole.maintenance.isAdmin, isFalse);
      expect(UserRole.maintenance.canCreateFaultReport, isFalse);
      expect(UserRole.maintenance.canUpdateStatus, isTrue);

      expect(UserRole.resident.isAdmin, isFalse);
      expect(UserRole.resident.canCreateFaultReport, isTrue);
      expect(UserRole.resident.canUpdateStatus, isFalse);

      expect(UserRole.itStaff.isAdmin, isFalse);
      expect(UserRole.itStaff.canCreateFaultReport, isFalse);
      expect(UserRole.itStaff.canManageReports, isTrue);

      expect(UserRole.fromString('MunicipalAdmin'), UserRole.admin);
      expect(UserRole.fromString('Administrator'), UserRole.admin);
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('MaintenanceTeam'), UserRole.maintenance);
      expect(UserRole.fromString('Resident'), UserRole.resident);
      expect(UserRole.fromString('ITStaff'), UserRole.itStaff);
    });

    test('ReportsViewModel allows report creation for Resident users', () {
      final repository = InMemoryFaultReportRepository();
      final viewModel = ReportsViewModel(
        repository: repository,
        userRole: UserRole.resident,
      );

      final initialCount = viewModel.totalCount;

      viewModel.addNewReport(
        title: 'Resident Found Leak',
        location: 'Sector A - Valve 1',
        description: 'Water leaking in residential area',
        reportedBy: 'Resident User',
        reportedDate: '2026-05-09',
        dueDate: '2026-05-11',
        status: ReportStatus.pending,
        priority: ReportPriority.medium,
      );

      expect(viewModel.totalCount, initialCount + 1);
      expect(viewModel.allReports.first.title, 'Resident Found Leak');
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

    test('ReportsViewModel throws StateError when Maintenance attempts to addNewReport', () {
      final repository = InMemoryFaultReportRepository();
      final viewModel = ReportsViewModel(
        repository: repository,
        userRole: UserRole.maintenance,
      );

      expect(viewModel.canCreateFaultReport, isFalse);

      final initialCount = viewModel.totalCount;

      expect(
        () => viewModel.addNewReport(
          title: 'Maintenance Trying To Create Report',
          location: 'Sector B',
          description: 'Should fail',
          reportedBy: 'Maintenance User',
          reportedDate: '2026-05-09',
          dueDate: '2026-05-11',
          status: ReportStatus.pending,
          priority: ReportPriority.medium,
        ),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Only Resident users are permitted to create fault reports'),
        )),
      );

      expect(viewModel.totalCount, initialCount);
    });

    test('FaultReportRepository throws StateError when non-resident attempts createReportOnApi with userRole', () async {
      final repository = InMemoryFaultReportRepository();
      const report = FaultReport(
        id: 'REP-999',
        title: 'Unauthorized Report',
        location: 'Sector A',
        description: 'Test',
        reportedBy: 'Admin',
        reportedDate: '2026-05-09',
        dueDate: '2026-05-11',
        status: ReportStatus.pending,
        priority: ReportPriority.low,
      );

      expect(
        () => repository.createReportOnApi(report, userRole: UserRole.admin),
        throwsA(isA<StateError>()),
      );

      expect(
        () => repository.createReportOnApi(report, userRole: UserRole.maintenance),
        throwsA(isA<StateError>()),
      );
    });

    test('ReportsViewModel respects role change from resident to admin', () {
      final repository = InMemoryFaultReportRepository();
      final viewModel = ReportsViewModel(
        repository: repository,
        userRole: UserRole.resident,
      );

      expect(viewModel.canCreateFaultReport, isTrue);

      viewModel.setUserRole(UserRole.admin);
      expect(viewModel.isAdmin, isTrue);
      expect(viewModel.canCreateFaultReport, isFalse);

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
