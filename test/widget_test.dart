import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydroalert_reports/data/repositories/fault_report_repository.dart';
import 'package:hydroalert_reports/domain/models/fault_report.dart';
import 'package:hydroalert_reports/main.dart';
import 'package:hydroalert_reports/ui/features/reports/view_models/reports_view_model.dart';

void main() {
  late InMemoryFaultReportRepository repository;
  late ReportsViewModel viewModel;

  setUp(() {
    repository = InMemoryFaultReportRepository();
    viewModel = ReportsViewModel(repository: repository);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
  }

  testWidgets('Renders HydroAlert dashboard and default fault reports', (WidgetTester tester) async {
    setDesktopSize(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(HydroAlertApp(viewModel: viewModel));
    await tester.pumpAndSettle();

    // Verify Header
    expect(find.text('All Reports'), findsOneWidget);
    expect(find.text('HydroAlert - Maintenance Reports'), findsOneWidget);
    expect(find.text('Maintenance User'), findsOneWidget);

    // Verify Default Reports
    expect(find.text('Water Pump Inspection'), findsOneWidget);
    expect(find.text('Sector A - Building 3'), findsOneWidget);
    expect(find.text('Pipe Leak Repair'), findsOneWidget);
    expect(find.text('Filter Replacement'), findsOneWidget);
    expect(find.text('Pressure Valve Check'), findsOneWidget);

    // Verify Report count text
    expect(find.text('Showing 1-4 of 4 reports'), findsOneWidget);
  });

  testWidgets('Navigates between All Reports and Main Dashboard', (WidgetTester tester) async {
    setDesktopSize(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(HydroAlertApp(viewModel: viewModel));
    await tester.pumpAndSettle();

    // Tap Dashboard back button
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();

    // Verify we are on Dashboard
    expect(find.text('HydroAlert Dashboard'), findsOneWidget);
    expect(find.text('Total Reports'), findsOneWidget);
    expect(find.text('Recent Fault Reports'), findsOneWidget);

    // Tap View All Reports to return
    await tester.tap(find.text('View All Reports').first);
    await tester.pumpAndSettle();

    // Verify we returned to All Reports view
    expect(find.text('All Reports'), findsOneWidget);
  });

  testWidgets('Opens Fault Report Details dialog and verifies report', (WidgetTester tester) async {
    setDesktopSize(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(HydroAlertApp(viewModel: viewModel));
    await tester.pumpAndSettle();

    // Tap first 'View Details' button
    final viewDetailsButtons = find.text('View Details');
    expect(viewDetailsButtons, findsWidgets);
    await tester.tap(viewDetailsButtons.first);
    await tester.pumpAndSettle();

    // Verify dialog content
    expect(find.text('Fault Report Details'), findsOneWidget);
    expect(find.text('Sector A - Building 3'), findsWidgets);
    expect(find.text('Routine inspection of water pump to ensure proper functioning. Check for unusual noises, vibrations, and leaks.'), findsOneWidget);
    expect(find.text('System Administrator'), findsOneWidget);
    expect(find.text('2026-05-06'), findsOneWidget);
    expect(find.text('2026-05-08'), findsOneWidget);

    // Tap Verify Fault Report
    await tester.tap(find.text('Verify Fault Report'));
    await tester.pumpAndSettle();

    // Verify status was changed to verified in viewModel
    final report = viewModel.allReports.firstWhere((r) => r.id == 'REP-101');
    expect(report.status, ReportStatus.verified);
  });

  testWidgets('Searches fault reports by query', (WidgetTester tester) async {
    setDesktopSize(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(HydroAlertApp(viewModel: viewModel));
    await tester.pumpAndSettle();

    // Enter search query
    await tester.enterText(find.byType(TextField).first, 'Pipe Leak');
    await tester.pumpAndSettle();

    expect(find.text('Pipe Leak Repair'), findsOneWidget);
    expect(find.text('Water Pump Inspection'), findsNothing);
    expect(find.text('Showing 1-1 of 4 reports'), findsOneWidget);
  });

  testWidgets('Updates status using status matrix in details dialog', (WidgetTester tester) async {
    setDesktopSize(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(HydroAlertApp(viewModel: viewModel));
    await tester.pumpAndSettle();

    await tester.tap(find.text('View Details').first);
    await tester.pumpAndSettle();

    // Tap 'In Progress' status button inside dialog
    await tester.tap(find.text('In Progress').last);
    await tester.pumpAndSettle();

    final report = viewModel.allReports.firstWhere((r) => r.id == 'REP-101');
    expect(report.status, ReportStatus.inProgress);
  });
}
