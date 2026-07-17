import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_provider.dart';
import '../auth/login_screen.dart';
import '../auth/area_selection_screen.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import 'bug_report_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                      child: const Icon(Icons.person, color: AppColors.primary, size: 40),
                    ),
                    Text(
                      authProvider.user?.username ?? 'Resident',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authProvider.user?.email ?? '',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        authProvider.user?.role ?? 'Resident',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  _ProfileTile(icon: Icons.person_outline, label: 'Edit Profile', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                  }),

                  const Divider(height: 1),
                  _ProfileTile(icon: Icons.location_on_outlined, label: 'Change Area', onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AreaSelectionScreen()),
                    );
                  }),

                  const Divider(height: 1),
                  _ProfileTile(icon: Icons.notifications_outlined, label: 'Notification Settings', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()));
                  }),

                  const Divider(height: 1),
                  _ProfileTile(icon: Icons.bug_report_outlined, label: 'Report a Bug', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BugReportScreen()));
                  }),

                  const Divider(height: 1),
                  _ProfileTile(
                    icon: Icons.logout,
                    label: 'Logout',
                    color: AppColors.error,
                    onTap: () async {
                      await authProvider.logout();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary),
      title: Text(label, style: TextStyle(color: color ?? AppColors.textPrimary)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}