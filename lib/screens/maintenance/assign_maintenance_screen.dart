import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/index.dart';
import '../../providers/app_providers.dart';

class AssignMaintenanceTeamScreen extends StatefulWidget {
  final String? reportId;

  const AssignMaintenanceTeamScreen({Key? key, this.reportId})
      : super(key: key);

  @override
  State<AssignMaintenanceTeamScreen> createState() =>
      _AssignMaintenanceTeamScreenState();
}

class _AssignMaintenanceTeamScreenState
    extends State<AssignMaintenanceTeamScreen> {
  String? _selectedTeamId;
  String? _selectedReportId;

  @override
  void initState() {
    super.initState();
    _selectedReportId = widget.reportId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaintenanceTeamProvider>().fetchTeams();
      context.read<FaultReportProvider>().fetchReports(
            status: ReportStatus.reviewed,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Assign Maintenance Team'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedReportId == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Fault Report',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildReportSelection(),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            Text(
              'Select Maintenance Team',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildTeamSelection(),
            if (_selectedTeamId != null && _selectedReportId != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl),
                child: _buildAssignButton(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSelection() {
    return Consumer<FaultReportProvider>(
      builder: (context, reportProvider, _) {
        if (reportProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final availableReports = reportProvider.reports
            .where((r) => r.status == ReportStatus.reviewed)
            .toList();

        if (availableReports.isEmpty) {
          return Center(
            child: Text(
              'No reviewed reports available',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: availableReports.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final report = availableReports[index];
            return InkWell(
              onTap: () => setState(() => _selectedReportId = report.id),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: _selectedReportId == report.id
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: _selectedReportId == report.id
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.description,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      report.address,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTeamSelection() {
    return Consumer<MaintenanceTeamProvider>(
      builder: (context, teamProvider, _) {
        if (teamProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (teamProvider.teams.isEmpty) {
          return Center(
            child: Text(
              'No maintenance teams available',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: teamProvider.teams.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final team = teamProvider.teams[index];
            return InkWell(
              onTap: () => setState(() => _selectedTeamId = team.id),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: _selectedTeamId == team.id
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: _selectedTeamId == team.id
                        ? AppColors.success
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          team.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: team.status == TeamStatus.available
                                ? AppColors.success
                                : AppColors.warning,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Text(
                            team.status
                                .toString()
                                .split('.')
                                .last
                                .toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Lead: ${team.leadName}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      'Members: ${team.memberNames.length}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      'Active Tasks: ${team.activeTaskCount}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAssignButton() {
    return Consumer<FaultReportProvider>(
      builder: (context, reportProvider, _) {
        return ElevatedButton(
          onPressed: () async {
            try {
              await reportProvider.assignReport(
                reportId: _selectedReportId!,
                teamId: _selectedTeamId!,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Team assigned successfully'),
                  ),
                );
                Navigator.pop(context);
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, AppSpacing.lg),
          ),
          child: const Text('Assign Team'),
        );
      },
    );
  }
}
