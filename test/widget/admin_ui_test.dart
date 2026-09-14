import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydroalert_reports/data/repositories/fault_report_repository.dart';
import 'package:hydroalert_reports/domain/models/user_role.dart';
import 'package:hydroalert_reports/ui/features/dashboard/views/main_dashboard_view.dart';
import 'package:hydroalert_reports/ui/features/reports/view_models/reports_view_model.dart';
import 'package:hydroalert_reports/ui/features/reports/views/reports_dashboard_view.dart';
import 'package:hydroalert_reports/ui/features/reports/views/widgets/new_report_dialog.dart';

void main() {
  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
  }

  group('Admin Interface Restrictions Tests', () {
    testWidgets('ReportsDashboardView hides New Report button when user is Admin', (WidgetTester tester) async {
      setDesktopSize(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = InMemoryFaultReportRepository();
      final viewModel = ReportsViewModel(
        repository: repository,
        userRole: UserRole.admin,
      );

      await tester.pumpWidget(MaterialApp(
        home: ReportsDashboardView(viewModel: viewModel),
      ));
      await tester.pumpAndSettle();

      // Admin role is displayed in header
      expect(find.text('Administrator'), findsOneWidget);

      // New Report button is NOT present in the admin interface
      expect(find.byKey(const ValueKey('new_report_button')), findsNothing);
      expect(find.text('New Report'), findsNothing);
    });

    testWidgets('ReportsDashboardView shows New Report button when user is Maintenance', (WidgetTester tester) async {
      setDesktopSize(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = InMemoryFaultReportRepository();
      final viewModel = ReportsViewModel(
        repository: repository,
        userRole: UserRole.maintenance,
      );

      await tester.pumpWidget(MaterialApp(
        home: ReportsDashboardView(viewModel: viewModel),
      ));
      await tester.pumpAndSettle();

      // Maintenance role is displayed in header
      expect(find.text('Maintenance User'), findsOneWidget);

      // New Report button IS present in the maintenance interface
      expect(find.byKey(const ValueKey('new_report_button')), findsOneWidget);
      expect(find.text('New Report'), findsOneWidget);
    });

    testWidgets('MainDashboardView hides Log New Fault Ticket button when user is Admin', (WidgetTester tester) async {
      setDesktopSize(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = InMemoryFaultReportRepository();
      final viewModel = ReportsViewModel(
        repository: repository,
        userRole: UserRole.admin,
      );

      await tester.pumpWidget(MaterialApp(
        home: MainDashboardView(
          viewModel: viewModel,
          onNavigateToReports: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Quick action button to log fault ticket is removed/hidden for admin
      expect(find.byKey(const ValueKey('quick_action_log_fault_button')), findsNothing);
      expect(find.text('Log New Fault Ticket'), findsNothing);
      // But other non-creation quick actions (like Search & Filter) remain
      expect(find.text('Search & Filter Reports'), findsOneWidget);
    });

    testWidgets('MainDashboardView shows Log New Fault Ticket button when user is Maintenance', (WidgetTester tester) async {
      setDesktopSize(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = InMemoryFaultReportRepository();
      final viewModel = ReportsViewModel(
        repository: repository,
        userRole: UserRole.maintenance,
      );

      await tester.pumpWidget(MaterialApp(
        home: MainDashboardView(
          viewModel: viewModel,
          onNavigateToReports: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Quick action button to log fault ticket IS visible for maintenance
      expect(find.byKey(const ValueKey('quick_action_log_fault_button')), findsOneWidget);
      expect(find.text('Log New Fault Ticket'), findsOneWidget);
    });

    testWidgets('NewReportDialog blocks admin users and shows restriction banner', (WidgetTester tester) async {
      setDesktopSize(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = InMemoryFaultReportRepository();
      final viewModel = ReportsViewModel(
        repository: repository,
        userRole: UserRole.admin,
      );

      final initialCount = viewModel.totalCount;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: NewReportDialog(viewModel: viewModel),
        ),
      ));
      await tester.pumpAndSettle();

      // Verify restriction banner is shown
      expect(find.byKey(const ValueKey('admin_restriction_banner')), findsOneWidget);
      expect(find.textContaining('Admin users are not permitted to create fault reports'), findsOneWidget);

      // Verify save button is disabled / shows restricted state
      final saveButtonFinder = find.byKey(const ValueKey('save_report_button'));
      expect(saveButtonFinder, findsOneWidget);
      expect(find.text('Creation Restricted'), findsOneWidget);

      final ElevatedButton buttonWidget = tester.widget<ElevatedButton>(saveButtonFinder);
      expect(buttonWidget.onPressed, isNull);

      // Try tapping anyway
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      // No new report was added
      expect(viewModel.totalCount, initialCount);
    });
  });
}
