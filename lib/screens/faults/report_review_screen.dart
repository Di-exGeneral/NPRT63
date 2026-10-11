import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/index.dart';
import '../../providers/app_providers.dart';

class ReportReviewScreen extends StatefulWidget {
  final String reportId;
  final FaultReport? initialReport;

  const ReportReviewScreen({
    Key? key,
    required this.reportId,
    this.initialReport,
  }) : super(key: key);

  @override
  State<ReportReviewScreen> createState() => _ReportReviewScreenState();
}

class _ReportReviewScreenState extends State<ReportReviewScreen> {
  late TextEditingController _reviewNotesController;
  int _selectedPriority = 3;
  bool _isReviewing = false;

  @override
  void initState() {
    super.initState();
    _reviewNotesController = TextEditingController();
  }

  @override
  void dispose() {
    _reviewNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Review Fault Report'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportDetails(),
            const SizedBox(height: AppSpacing.xl),
            _buildReviewForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportDetails() {
    final report = widget.initialReport;
    if (report == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
            'Report Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildDetailRow('Reporter', report.reporterName),
          _buildDetailRow('Phone', report.reporterPhone),
          _buildDetailRow('Address', report.address),
          _buildDetailRow('Area', report.area),
          _buildDetailRow('Fault Type',
              report.faultType.toString().split('.').last),
          _buildDetailRow('Reported At',
              DateFormat('MMM dd, yyyy HH:mm').format(report.reportedAt)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            report.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewForm() {
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
            'Review & Assessment',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Priority Level',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: List.generate(5, (index) {
              final priority = index + 1;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedPriority = priority),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _selectedPriority == priority
                          ? _getPriorityColor(priority)
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: _selectedPriority == priority
                            ? _getPriorityColor(priority)
                            : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'P$priority',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: _selectedPriority == priority
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _reviewNotesController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Review Notes',
              hintText: 'Add your assessment and recommendations...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Consumer<FaultReportProvider>(
            builder: (context, reportProvider, _) {
              return ElevatedButton(
                onPressed: _isReviewing
                    ? null
                    : () async {
                        if (_reviewNotesController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please add review notes',
                              ),
                            ),
                          );
                          return;
                        }

                        setState(() => _isReviewing = true);
                        try {
                          await reportProvider.reviewReport(
                            id: widget.reportId,
                            reviewNotes: _reviewNotesController.text,
                            priority: _selectedPriority,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Report reviewed successfully'),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        } finally {
                          setState(() => _isReviewing = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  minimumSize: const Size(double.infinity, AppSpacing.lg),
                ),
                child: _isReviewing
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
                    : const Text('Submit Review'),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    if (priority == 1) return AppColors.critical;
    if (priority == 2) return AppColors.high;
    if (priority == 3) return AppColors.medium;
    return AppColors.low;
  }
}
