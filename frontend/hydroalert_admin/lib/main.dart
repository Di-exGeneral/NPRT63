import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'providers/app_providers.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(HydroAlertAdminApp(api: ApiService()));
}

class HydroAlertAdminApp extends StatelessWidget {
  const HydroAlertAdminApp({super.key, required this.api});
  final ApiService api;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider(api)..restoreSession()),
        ChangeNotifierProvider(create: (_) => AdminProvider(api)),
      ],
      child: MaterialApp(
        title: 'HydroAlert Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          textTheme: AppTypography.getTextTheme(),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isRestoring) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            return auth.isAuthenticated
                ? const HomeShell()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}
