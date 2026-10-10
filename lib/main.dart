import 'package:flutter/material.dart';
import 'package:hydroalert_reports/ui/features/login_screen.dart';
import 'ui/core/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HydroAlertApp());
}

class HydroAlertApp extends StatelessWidget {
  const HydroAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HydroAlert - Maintenance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}