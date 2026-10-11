import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/app_providers.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  static const alertTypes = [
    'Water Contamination',
    'Pipe Burst',
    'Unplanned Outage',
    'Low Pressure',
    'Boil Water Advisory',
    'Other',
  ];
  final _formKey = GlobalKey<FormState>();
  final _duration = TextEditingController();
  final _message = TextEditingController();
  String? _type;
  String? _areaID;
  bool _push = true;
  bool _sms = true;
  bool _sending = false;

  @override
  void dispose() {
    _duration.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_push && !_sms) {
      showSnack(context, 'Choose at least one channel.', error: true);
      return;
    }
    if (!await confirm(context, 'Send emergency alert?',
        'All residents in ${context.read<AdminProvider>().areaName(_areaID!)} will be notified immediately.')) {
      return;
    }
    if (!mounted) return;
    setState(() => _sending = true);
    try {
      final alert = await context.read<AdminProvider>().sendAlert(
            areaID: _areaID!,
            alertType: _type!,
            message: _message.text.trim(),
            estimatedDuration: _duration.text.trim(),
            channels: [if (_push) 'push', if (_sms) 'sms'],
          );
      if (!mounted) return;
      _message.clear();
      _duration.clear();
      showSnack(context, 'Alert sent to ${alert.recipientCount} resident(s).');
    } catch (e) {
      if (mounted) showSnack(context, '$e', error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Text(
            'Use this only for urgent situations that need immediate public notification. All alerts are logged and audited.',
            style: TextStyle(color: AppColors.critical),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          title: 'Create emergency alert',
          subtitle: 'Compose and send emergency notifications to affected areas',
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Alert type *'),
                  items: [
                    for (final t in alertTypes)
                      DropdownMenuItem(value: t, child: Text(t)),
                  ],
                  onChanged: (v) => setState(() => _type = v),
                  validator: (v) => v == null ? 'Select an alert type' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: _areaID,
                  decoration:
                      const InputDecoration(labelText: 'Affected area *'),
                  items: [
                    for (final a in admin.areas)
                      DropdownMenuItem(value: a.areaID, child: Text(a.label)),
                  ],
                  onChanged: (v) => setState(() => _areaID = v),
                  validator: (v) => v == null ? 'Select an area' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _duration,
                  decoration: const InputDecoration(
                      labelText: 'Estimated duration',
                      hintText: 'e.g. 2-4 hours, until further notice'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _message,
                  maxLines: 4,
                  maxLength: 500,
                  onChanged: (_) => setState(() {}),
                  decoration:
                      const InputDecoration(labelText: 'Alert message *'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter the alert message'
                      : null,
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _push,
                  onChanged: (v) => setState(() => _push = v ?? false),
                  title: const Text('In-app / push notification'),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _sms,
                  onChanged: (v) => setState(() => _sms = v ?? false),
                  title: const Text('SMS text message'),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.error),
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.send),
                    label: Text(_sending ? 'Sending…' : 'Send emergency alert'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          title: 'Preview',
          subtitle: 'How residents will see the alert',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.warning_amber, color: AppColors.error),
            title: Text('Emergency: ${_type ?? 'Alert type'}'),
            subtitle: Text(
              '${_message.text.isEmpty ? 'Your emergency message will appear here…' : _message.text}'
              '${_duration.text.isNotEmpty ? ' (Estimated duration: ${_duration.text})' : ''}',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          title: 'Recent alerts',
          subtitle: 'Previously sent emergency alerts',
          child: admin.alerts.isEmpty
              ? const Text('No alerts sent yet.')
              : Column(
                  children: [
                    for (final a in admin.alerts)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(a.alertType),
                        subtitle: Text(
                            '${a.areaName ?? admin.areaName(a.areaID)} · ${formatDateTime(a.createdAt)}\n${a.message}'),
                        isThreeLine: true,
                        trailing: Text('${a.recipientCount} sent'),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
