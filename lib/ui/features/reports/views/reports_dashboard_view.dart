import 'package:flutter/material.dart';
import 'package:hydroalert_reports/domain/models/fault_report.dart';
import 'package:hydroalert_reports/domain/models/user_role.dart';
import 'package:hydroalert_reports/ui/core/theme.dart';
import 'package:hydroalert_reports/ui/features/reports/view_models/reports_view_model.dart';
import 'package:hydroalert_reports/ui/features/reports/views/widgets/fault_report_card.dart';
import 'package:hydroalert_reports/ui/features/reports/views/widgets/fault_report_details_dialog.dart';
import 'package:hydroalert_reports/ui/features/reports/views/widgets/filter_dialog.dart';
import 'package:hydroalert_reports/ui/features/reports/views/widgets/new_report_dialog.dart';

class ReportsDashboardView extends StatefulWidget {
  final ReportsViewModel viewModel;

  const ReportsDashboardView({super.key, required this.viewModel});

  @override
  State<ReportsDashboardView> createState() => _ReportsDashboardViewState();
}

class _ReportsDashboardViewState extends State<ReportsDashboardView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      widget.viewModel.setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.help_outline_rounded, color: AppColors.primaryBlue),
            SizedBox(width: 8),
            Text('HydroAlert Help & Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HydroAlert Maintenance Reports System',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '• Click "View Details" on any report to inspect full metadata, verify the ticket, or update its status (Pending, In Progress, Completed, Verified).\n'
              '• Use the search bar to filter tickets by title, sector, description, or reporter.\n'
              '• Click "Filters" to apply status, priority, or sorting filters.'
              '${widget.viewModel.isAdmin ? '' : '\n• Click "+ New Report" to log a new maintenance ticket.'}',
              style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final reports = widget.viewModel.filteredReports;
        final totalCount = widget.viewModel.totalCount;
        final count = reports.length;
        final activeFilters = widget.viewModel.activeFilterCount;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              Column(
                children: [
                  // Top Navigation Header
                  _buildHeader(context),

                  // Main Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1040),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Search and Filter Bar Row
                              _buildSearchAndFilterBar(context, activeFilters),
                              const SizedBox(height: 12),

                              // Showing counter
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Text(
                                  count > 0
                                      ? 'Showing 1-$count of $totalCount reports'
                                      : 'Showing 0 of $totalCount reports',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Fault Reports Main Card
                              _buildReportsCard(context, reports),
                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Floating Help Button bottom right
              Positioned(
                bottom: 24,
                right: 24,
                child: Material(
                  color: Colors.white,
                  elevation: 4,
                  shape: const CircleBorder(
                    side: BorderSide(color: AppColors.border, width: 1),
                  ),
                  child: InkWell(
                    onTap: _showHelpDialog,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: const Text(
                        '?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
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
              // Left "<- Dashboard" button
              InkWell(
                onTap: () {
                  widget.viewModel.navigateToScreen(AppScreen.dashboard);
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.textPrimary),
                      SizedBox(width: 6),
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: isCompact ? 12 : 20),

              // App Logo Droplet & Title
              Row(
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'All Reports',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (!isCompact)
                        const Text(
                          'HydroAlert - Maintenance Reports',
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

              // Right Profile Card
              if (!isCompact) ...[
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    final nextRole = widget.viewModel.isAdmin ? UserRole.maintenance : UserRole.admin;
                    widget.viewModel.setUserRole(nextRole);
                  },
                  child: Tooltip(
                    message: 'Click to switch role (${widget.viewModel.isAdmin ? "Switch to Maintenance" : "Switch to Administrator"})',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.viewModel.currentUserRole.label,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Text(
                                'user@example.com',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.swap_horiz_rounded, size: 16, color: AppColors.textLight),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
              ],

              // Logout Button
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out of HydroAlert'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      width: 250,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.logout_rounded, size: 18, color: AppColors.textSecondary),
                      if (!isCompact) ...[
                        const SizedBox(width: 6),
                        const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilterBar(BuildContext context, int activeFilters) {
    return Row(
      children: [
        // Search text field
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.textLight,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by title, location, or description...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      filled: false,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: AppColors.textLight),
                    onPressed: () {
                      _searchController.clear();
                      widget.viewModel.setSearchQuery('');
                    },
                    splashRadius: 16,
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Filters Button
        OutlinedButton.icon(
          onPressed: () => FilterDialog.show(context, widget.viewModel),
          icon: Badge(
            isLabelVisible: activeFilters > 0,
            label: Text('$activeFilters'),
            backgroundColor: AppColors.primaryBlue,
            child: const Icon(Icons.filter_alt_outlined, size: 18),
          ),
          label: const Text('Filters'),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        // Add Report Button - Only available to Resident role
        if (widget.viewModel.canCreateFaultReport) ...[
          const SizedBox(width: 12),
          ElevatedButton.icon(
            key: const ValueKey('new_report_button'),
            onPressed: () => NewReportDialog.show(context, widget.viewModel),
            icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
            label: const Text('New Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReportsCard(BuildContext context, List<FaultReport> reports) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Fault Reports',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (widget.viewModel.activeFilterCount > 0)
                  TextButton.icon(
                    onPressed: () => widget.viewModel.resetFilters(),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Clear Filters', style: TextStyle(fontSize: 12.5)),
                  ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.borderSubtle),

          // Items List
          if (reports.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'No matching fault reports found',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Try adjusting your search query or clear your filter criteria.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      _searchController.clear();
                      widget.viewModel.resetFilters();
                    },
                    child: const Text('Reset All Filters'),
                  ),
                ],
              ),
            )
          else
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Column(
                children: [
                  for (final report in reports)
                    FaultReportCard(
                      report: report,
                      onViewDetails: () {
                        FaultReportDetailsDialog.show(context, report, widget.viewModel);
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
