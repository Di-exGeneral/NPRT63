import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'providers/app_providers.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/admin_dashboard_screen.dart';
import 'screens/outages/outage_schedule_screen.dart';
import 'screens/faults/fault_reports_list_screen.dart';
import 'screens/faults/report_review_screen.dart';
import 'screens/maintenance/assign_maintenance_screen.dart';
import 'screens/alerts/emergency_alert_screen.dart';

void main() {
  runApp(const HydroAlertApp());
}

class HydroAlertApp extends StatelessWidget {
  const HydroAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OutageProvider()),
        ChangeNotifierProvider(create: (_) => FaultReportProvider()),
        ChangeNotifierProvider(create: (_) => MaintenanceTeamProvider()),
        ChangeNotifierProvider(create: (_) => EmergencyAlertProvider()),
      ],
      child: MaterialApp(
        title: 'HydroAlert',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          textTheme: AppTypography.getTextTheme(),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primary,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: AppTypography.getTextTheme().titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const AdminDashboardScreen(),
          '/outage-schedule': (context) => const OutageScheduleManagementScreen(),
          '/fault-reports': (context) => const FaultReportsListScreen(),
          '/assign-maintenance': (context) => const AssignMaintenanceTeamScreen(),
          '/emergency-alert': (context) => const EmergencyAlertScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name?.startsWith('/report-review/') ?? false) {
            final reportId = settings.name!.replaceFirst('/report-review/', '');
            final report = settings.arguments as dynamic;
            return MaterialPageRoute(
              builder: (context) => ReportReviewScreen(
                reportId: reportId,
                initialReport: report,
              ),
            );
          }
          return null;
        },
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return authProvider.isAuthenticated
                ? const AdminDashboardScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}
