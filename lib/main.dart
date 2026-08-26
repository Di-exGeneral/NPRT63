import 'package:flutter/material.dart';
import 'package:hydroalert_reports/data/repositories/fault_report_repository.dart';
import 'package:hydroalert_reports/ui/core/theme.dart';
import 'package:hydroalert_reports/ui/features/dashboard/views/main_dashboard_view.dart';
import 'package:hydroalert_reports/ui/features/reports/view_models/reports_view_model.dart';
import 'package:hydroalert_reports/ui/features/reports/views/reports_dashboard_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final repository = InMemoryFaultReportRepository();
  final viewModel = ReportsViewModel(repository: repository);

  runApp(HydroAlertApp(viewModel: viewModel));
}

class HydroAlertApp extends StatelessWidget {
  final ReportsViewModel viewModel;

  const HydroAlertApp({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HydroAlert - Maintenance Reports',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          switch (viewModel.currentScreen) {
            case AppScreen.dashboard:
              return MainDashboardView(
                viewModel: viewModel,
                onNavigateToReports: () {
                  viewModel.navigateToScreen(AppScreen.allReports);
                },
              );
            case AppScreen.allReports:
              return ReportsDashboardView(viewModel: viewModel);
          }
        },
      ),
    );
  }
}
