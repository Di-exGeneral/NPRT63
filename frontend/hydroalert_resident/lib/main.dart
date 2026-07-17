import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'services/auth_provider.dart';
import 'services/fault_report_provider.dart';
import 'services/area_provider.dart';
import 'services/outage_provider.dart';
import 'services/notification_provider.dart';
import 'screens/auth/splash_screen.dart';

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
        ChangeNotifierProvider(create: (_) => FaultReportProvider()),
        ChangeNotifierProvider(create: (_) => AreaProvider()),
        ChangeNotifierProvider(create: (_) => OutageProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'HydroAlert',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const SplashScreen(),
      ),
    );
  }
}