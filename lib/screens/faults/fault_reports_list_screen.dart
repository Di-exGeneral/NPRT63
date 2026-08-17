import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/index.dart';
import '../../providers/app_providers.dart';

class FaultReportsListScreen extends StatefulWidget {
  const FaultReportsListScreen({Key? key}) : super(key: key);

  @override
  State<FaultReportsListScreen> createState() =>
      _FaultReportsListScreenState();
}

class _FaultReportsListScreenState extends State<FaultReportsListScreen> {
  ReportStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FaultReportProvider>().fetchReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fault Reports'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilters(),
            const SizedBox(height: AppSpacing.lg),
            Expanded(child: _buildReportsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: AppSpacing.sm,
      children: ReportStatus.values
          .map((status) => FilterChip(
                selected: _selectedStatus == status,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus =
                        selected ? status : null;
                  });
                  context.read<FaultReportProvider>().fetchReports(
                        status: _selectedStatus,
                      );
                },
                label: Text(status.toString().split('.').last),
              ))
          .toList(),
    );
  }

  Widget _buildReportsList() {
    return Consumer<FaultReportProvider>(
      builder: (context, reportProvider, _) {
        if (reportProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredReports = _selectedStatus != null
            ? reportProvider.reports
                .where((r) => r.status == _selectedStatus)
                .toList()
            : reportProvider.reports;

        if (filteredReports.isEmpty) {
          return Center(
            child: Text(
              'No fault reports found',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.separated(
          itemCount: filteredReports.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final report = filteredReports[index];
            return _FaultReportCard(
              report: report,
              onTap: () => Navigator.pushNamed(
                context,
                '/report-review/${report.id}',
                arguments: report,
              ),
            );
          },
        );
      },
    );
  }
}

class _FaultReportCard extends StatelessWidget {
  final FaultReport report;
  final VoidCallback onTap;

  const _FaultReportCard({
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
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
                Expanded(
                  child: Text(
                    report.description,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(report.priority)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    'P${report.priority}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _getPriorityColor(report.priority),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  report.address,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  DateFormat('MMM dd, HH:mm').format(report.reportedAt),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(report.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Text(
                report.status.toString().split('.').last.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _getStatusColor(report.status),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    if (priority == 1) return AppColors.critical;
    if (priority == 2) return AppColors.high;
    if (priority == 3) return AppColors.medium;
    return AppColors.low;
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.submitted:
        return AppColors.info;
      case ReportStatus.reviewed:
        return AppColors.warning;
      case ReportStatus.assigned:
        return AppColors.warning;
      case ReportStatus.inProgress:
        return AppColors.warning;
      case ReportStatus.resolved:
        return AppColors.success;
      case ReportStatus.closed:
        return AppColors.success;
    }
  }
}
