import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _smsNotifications = true;
  bool _outageAlerts = true;
  bool _reportUpdates = true;
  bool _maintenanceAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Notification Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.sms_outlined,
                label: 'SMS Notifications',
                subtitle: 'Receive notifications via SMS',
                value: _smsNotifications,
                onChanged: (val) => setState(() => _smsNotifications = val),
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.water_outlined,
                label: 'Outage Alerts',
                subtitle: 'Get notified about water outages',
                value: _outageAlerts,
                onChanged: (val) => setState(() => _outageAlerts = val),
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.report_outlined,
                label: 'Report Updates',
                subtitle: 'Get notified when your report status changes',
                value: _reportUpdates,
                onChanged: (val) => setState(() => _reportUpdates = val),
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.build_outlined,
                label: 'Maintenance Alerts',
                subtitle: 'Get notified about maintenance assignments',
                value: _maintenanceAlerts,
                onChanged: (val) => setState(() => _maintenanceAlerts = val),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}