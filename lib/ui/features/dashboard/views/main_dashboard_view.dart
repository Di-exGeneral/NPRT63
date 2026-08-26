import 'package:flutter/material.dart';
import 'package:hydroalert_reports/domain/models/fault_report.dart';
import 'package:hydroalert_reports/ui/core/theme.dart';
import 'package:hydroalert_reports/ui/core/widgets/priority_badge.dart';
import 'package:hydroalert_reports/ui/core/widgets/status_badge.dart';
import 'package:hydroalert_reports/ui/features/reports/view_models/reports_view_model.dart';
import 'package:hydroalert_reports/ui/features/reports/views/widgets/fault_report_details_dialog.dart';
import 'package:hydroalert_reports/ui/features/reports/views/widgets/new_report_dialog.dart';

class MainDashboardView extends StatelessWidget {
  final ReportsViewModel viewModel;
  final VoidCallback onNavigateToReports;

  const MainDashboardView({
    super.key,
    required this.viewModel,
    required this.onNavigateToReports,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final reports = viewModel.allReports;
        final pendingCount = reports.where((r) => r.status == ReportStatus.pending).length;
        final inProgressCount = reports.where((r) => r.status == ReportStatus.inProgress).length;
        final completedCount = reports.where((r) => r.status == ReportStatus.completed || r.status == ReportStatus.verified).length;
        final urgentCount = reports.where((r) => r.priority == ReportPriority.urgent || r.priority == ReportPriority.high).length;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // Top Navigation Header
              _buildHeader(context),

              // Main Dashboard Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome & Banner
                          _buildWelcomeBanner(context, urgentCount),
                          const SizedBox(height: 20),

                          // Summary Metric Cards (4 Cards)
                          _buildMetricCards(
                            context: context,
                            total: reports.length,
                            pending: pendingCount,
                            inProgress: inProgressCount,
                            completed: completedCount,
                          ),
                          const SizedBox(height: 24),

                          // Two Column Content: Recent Reports & System Overview
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth > 780) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: _buildRecentFaultsCard(context, reports),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          _buildSectorStatusCard(),
                                          const SizedBox(height: 20),
                                          _buildQuickActionsCard(context),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return Column(
                                  children: [
                                    _buildRecentFaultsCard(context, reports),
                                    const SizedBox(height: 20),
                                    _buildSectorStatusCard(),
                                    const SizedBox(height: 20),
                                    _buildQuickActionsCard(context),
                                  ],
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 750;

        return Container(
          height: 72,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 28),
          child: Row(
            children: [
              // Logo & Title
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HydroAlert Dashboard',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (!isCompact)
                        const Text(
                          'Facility Maintenance & Operations Center',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Go to All Reports Button
              ElevatedButton.icon(
                onPressed: onNavigateToReports,
                icon: const Icon(Icons.list_alt_rounded, size: 18),
                label: const Text('View All Reports'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

              if (!isCompact) ...[
                const SizedBox(width: 14),
                // User Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Maintenance User',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'user@example.com',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, int urgentCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D61E7), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Facility Maintenance System Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  urgentCount > 0
                      ? 'Attention: $urgentCount high/urgent priority maintenance ticket(s) require immediate inspection.'
                      : 'All systems running within standard operating limits.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onNavigateToReports,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryBlue,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Open Reports Queue', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCards({
    required BuildContext context,
    required int total,
    required int pending,
    required int inProgress,
    required int completed,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth - 48) / 4;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
              title: 'Total Reports',
              value: '$total',
              subtitle: 'Active maintenance records',
              icon: Icons.assignment_outlined,
              iconColor: AppColors.primaryBlue,
              iconBg: AppColors.primaryBlueLight,
              width: cardWidth > 200 ? cardWidth : double.infinity,
              onTap: onNavigateToReports,
            ),
            _buildStatCard(
              title: 'Pending Action',
              value: '$pending',
              subtitle: 'Awaiting technician review',
              icon: Icons.hourglass_top_rounded,
              iconColor: const Color(0xFFD97706),
              iconBg: const Color(0xFFFEF3C7),
              width: cardWidth > 200 ? cardWidth : double.infinity,
              onTap: () {
                viewModel.setStatusFilter(ReportStatus.pending);
                onNavigateToReports();
              },
            ),
            _buildStatCard(
              title: 'In Progress',
              value: '$inProgress',
              subtitle: 'Currently being repaired',
              icon: Icons.build_circle_outlined,
              iconColor: const Color(0xFF2563EB),
              iconBg: const Color(0xFFDBEAFE),
              width: cardWidth > 200 ? cardWidth : double.infinity,
              onTap: () {
                viewModel.setStatusFilter(ReportStatus.inProgress);
                onNavigateToReports();
              },
            ),
            _buildStatCard(
              title: 'Resolved & Verified',
              value: '$completed',
              subtitle: 'Completed repairs',
              icon: Icons.verified_outlined,
              iconColor: const Color(0xFF059669),
              iconBg: const Color(0xFFD1FAE5),
              width: cardWidth > 200 ? cardWidth : double.infinity,
              onTap: () {
                viewModel.setStatusFilter(ReportStatus.completed);
                onNavigateToReports();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required double width,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFaultsCard(BuildContext context, List<FaultReport> reports) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Fault Reports',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: onNavigateToReports,
                  child: const Text('View All →', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          for (final report in reports.take(4))
            InkWell(
              onTap: () {
                FaultReportDetailsDialog.show(context, report, viewModel);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.title,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${report.location} • Due ${report.dueDate}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    PriorityBadge(priority: report.priority),
                    const SizedBox(width: 8),
                    StatusBadge(status: report.status),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectorStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sector Health Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSectorRow('Sector A (Booster & Pumps)', '2 Active Tasks', Colors.amber),
          const SizedBox(height: 12),
          _buildSectorRow('Sector B (Pipe Network)', '1 Active Task', Colors.orange),
          const SizedBox(height: 12),
          _buildSectorRow('Sector C (Water Reservoirs)', '1 Routine Task', Colors.green),
        ],
      ),
    );
  }

  Widget _buildSectorRow(String name, String status, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          status,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildQuickActionsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => NewReportDialog.show(context, viewModel),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Log New Fault Ticket'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onNavigateToReports,
              icon: const Icon(Icons.search_rounded, size: 18),
              label: const Text('Search & Filter Reports'),
            ),
          ),
        ],
      ),
    );
  }
}
