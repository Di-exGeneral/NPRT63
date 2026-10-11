import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/index.dart';
import '../../providers/app_providers.dart';

class OutageScheduleManagementScreen extends StatefulWidget {
  const OutageScheduleManagementScreen({Key? key}) : super(key: key);

  @override
  State<OutageScheduleManagementScreen> createState() =>
      _OutageScheduleManagementScreenState();
}

class _OutageScheduleManagementScreenState
    extends State<OutageScheduleManagementScreen> {
  late TextEditingController _areaController;
  late TextEditingController _reasonController;
  late TextEditingController _descriptionController;
  late TextEditingController _affectedAreasController;
  late TextEditingController _residentsController;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _areaController = TextEditingController();
    _reasonController = TextEditingController();
    _descriptionController = TextEditingController();
    _affectedAreasController = TextEditingController();
    _residentsController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OutageProvider>().fetchOutages();
    });
  }

  @override
  void dispose() {
    _areaController.dispose();
    _reasonController.dispose();
    _descriptionController.dispose();
    _affectedAreasController.dispose();
    _residentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Outage Schedule Management'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCreateOutageForm(),
            const SizedBox(height: AppSpacing.xl),
            _buildOutagesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateOutageForm() {
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
            'Schedule New Outage',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _areaController,
            decoration: InputDecoration(
              labelText: 'Area Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              labelText: 'Reason for Outage',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (date != null) {
                      setState(() => _selectedStartDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      _selectedStartDate == null
                          ? 'Select date'
                          : DateFormat('MMM dd, yyyy')
                              .format(_selectedStartDate!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate:
                          _selectedStartDate ?? DateTime.now(),
                      firstDate:
                          _selectedStartDate ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (date != null) {
                      setState(() => _selectedEndDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      _selectedEndDate == null
                          ? 'Select date'
                          : DateFormat('MMM dd, yyyy').format(_selectedEndDate!),
                    ),
                  ),
                ),
              ),
            ],
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
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _affectedAreasController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Affected Areas (comma separated)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Consumer<OutageProvider>(
            builder: (context, outageProvider, _) {
              return ElevatedButton(
                onPressed: () async {
                  if (_areaController.text.isEmpty ||
                      _selectedStartDate == null ||
                      _selectedEndDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill all required fields')),
                    );
                    return;
                  }

                  try {
                    await outageProvider.createOutage(
                      area: _areaController.text,
                      areaId: DateTime.now().millisecondsSinceEpoch
                          .toString(),
                      reason: _reasonController.text,
                      scheduledStartTime: _selectedStartDate!,
                      scheduledEndTime: _selectedEndDate!,
                      description: _descriptionController.text,
                      affectedAreas: _affectedAreasController.text
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
                            content: Text('Outage scheduled successfully')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize:
                      const Size(double.infinity, AppSpacing.lg),
                ),
                child: const Text('Schedule Outage'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOutagesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scheduled Outages',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Consumer<OutageProvider>(
          builder: (context, outageProvider, _) {
            if (outageProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (outageProvider.outages.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Text(
                    'No scheduled outages',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: outageProvider.outages.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final outage = outageProvider.outages[index];
                return _OutageCard(outage: outage);
              },
            );
          },
        ),
      ],
    );
  }

  void _clearForm() {
    _areaController.clear();
    _reasonController.clear();
    _descriptionController.clear();
    _affectedAreasController.clear();
    _residentsController.clear();
    setState(() {
      _selectedStartDate = null;
      _selectedEndDate = null;
    });
  }
}

class _OutageCard extends StatelessWidget {
  final WaterOutage outage;

  const _OutageCard({required this.outage});

  @override
  Widget build(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                outage.area,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(outage.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  outage.status.toString().split('.').last.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getStatusColor(outage.status),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            outage.reason,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${DateFormat('MMM dd, HH:mm').format(outage.scheduledStartTime)} - ${DateFormat('MMM dd, HH:mm').format(outage.scheduledEndTime)}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OutageStatus status) {
    switch (status) {
      case OutageStatus.planned:
        return AppColors.info;
      case OutageStatus.ongoing:
        return AppColors.warning;
      case OutageStatus.completed:
        return AppColors.success;
      case OutageStatus.cancelled:
        return AppColors.error;
    }
  }
}
