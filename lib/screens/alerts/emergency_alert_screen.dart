import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/index.dart';
import '../../providers/app_providers.dart';

class EmergencyAlertScreen extends StatefulWidget {
  const EmergencyAlertScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyAlertScreen> createState() => _EmergencyAlertScreenState();
}

class _EmergencyAlertScreenState extends State<EmergencyAlertScreen> {
  late TextEditingController _titleController;
  late TextEditingController _messageController;
  late TextEditingController _areasController;
  late TextEditingController _residentsController;
  AlertSeverity _selectedSeverity = AlertSeverity.high;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _messageController = TextEditingController();
    _areasController = TextEditingController();
    _residentsController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _areasController.dispose();
    _residentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Send Emergency Alert'),
        backgroundColor: AppColors.error,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAlertForm(),
            const SizedBox(height: AppSpacing.xl),
            _buildAlertHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertForm() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alert Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: AppColors.error,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'This will send an urgent SMS alert to all targeted residents',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Alert Title',
              hintText: 'e.g., Critical Water Outage',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _messageController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Alert Message',
              hintText: 'Compose the emergency message...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Severity Level',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: AlertSeverity.values
                .map((severity) => FilterChip(
                      selected: _selectedSeverity == severity,
                      onSelected: (selected) {
                        setState(() => _selectedSeverity = severity);
                      },
                      label: Text(
                        severity.toString().split('.').last.toUpperCase(),
                      ),
                      backgroundColor:
                          _getSeverityColor(severity).withOpacity(0.1),
                      selectedColor: _getSeverityColor(severity),
                      labelStyle: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(
                            color: _selectedSeverity == severity
                                ? Colors.white
                                : _getSeverityColor(severity),
                          ),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _areasController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Target Areas (comma separated)',
              hintText: 'e.g., Zone A, Zone B, Zone C',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _residentsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Estimated Affected Residents',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Consumer<EmergencyAlertProvider>(
            builder: (context, alertProvider, _) {
              return ElevatedButton(
                onPressed: _isSending
                    ? null
                    : () async {
                        if (_titleController.text.isEmpty ||
                            _messageController.text.isEmpty ||
                            _areasController.text.isEmpty ||
                            _residentsController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Please fill all required fields'),
                            ),
                          );
                          return;
                        }

                        setState(() => _isSending = true);
                        try {
                          await alertProvider.sendAlert(
                            title: _titleController.text,
                            message: _messageController.text,
                            severity: _selectedSeverity,
                            targetAreas: _areasController.text
                                .split(',')
                                .map((e) => e.trim())
                                .toList(),
                            estimatedAffectedResidents:
                                int.parse(_residentsController.text),
                          );
                          if (mounted) {
                            _clearForm();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Emergency alert sent successfully'),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        } finally {
                          setState(() => _isSending = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  minimumSize: const Size(double.infinity, AppSpacing.lg),
                ),
                child: _isSending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Send Emergency Alert'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlertHistory() {
    return Consumer<EmergencyAlertProvider>(
      builder: (context, alertProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alert History',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (alertProvider.alerts.isEmpty)
              Center(
                child: Text(
                  'No emergency alerts sent',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: alertProvider.alerts.take(5).length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final alert = alertProvider.alerts[index];
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              alert.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: _getSeverityColor(alert.severity)
                                    .withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xs),
                              ),
                              child: Text(
                                alert.severity
                                    .toString()
                                    .split('.')
                                    .last
                                    .toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color:
                                          _getSeverityColor(alert.severity),
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'SMS Sent: ${alert.smsSentCount} | Delivered: ${alert.smsDeliveredCount}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return AppColors.info;
      case AlertSeverity.medium:
        return AppColors.medium;
      case AlertSeverity.high:
        return AppColors.high;
      case AlertSeverity.critical:
        return AppColors.critical;
    }
  }

  void _clearForm() {
    _titleController.clear();
    _messageController.clear();
    _areasController.clear();
    _residentsController.clear();
    setState(() {
      _selectedSeverity = AlertSeverity.high;
    });
  }
}
