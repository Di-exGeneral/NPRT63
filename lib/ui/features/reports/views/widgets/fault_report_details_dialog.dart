import 'package:flutter/material.dart';
import 'package:hydroalert_reports/domain/models/fault_report.dart';
import 'package:hydroalert_reports/ui/core/theme.dart';
import 'package:hydroalert_reports/ui/features/reports/view_models/reports_view_model.dart';

class FaultReportDetailsDialog extends StatelessWidget {
  final FaultReport report;
  final ReportsViewModel viewModel;

  const FaultReportDetailsDialog({
    super.key,
    required this.report,
    required this.viewModel,
  });

  static Future<void> show(BuildContext context, FaultReport report, ReportsViewModel viewModel) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final updatedReport = viewModel.allReports.firstWhere(
            (r) => r.id == report.id,
            orElse: () => report,
          );
          return FaultReportDetailsDialog(
            report: updatedReport,
            viewModel: viewModel,
          );
        },
      ),
    );
  }

  Widget _buildField({required String label, required String value, CrossAxisAlignment align = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusOption({
    required BuildContext context,
    required ReportStatus status,
    required Color bg,
    required Color fg,
    required bool isCurrent,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          viewModel.updateReportStatus(report.id, status);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status updated to "${status.label}"'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              width: 320,
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: isCurrent
                ? Border.all(color: fg.withValues(alpha: 0.8), width: 2)
                : Border.all(color: Colors.transparent, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isCurrent) ...[
                Icon(Icons.check, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                status.label,
                style: TextStyle(
                  color: fg,
                  fontSize: 13.5,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 580,
          maxHeight: 720,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 16, top: 20, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fault Report Details',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textLight, size: 22),
                    splashRadius: 20,
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.borderSubtle),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location
                    _buildField(
                      label: 'Location',
                      value: report.location,
                    ),
                    const SizedBox(height: 20),

                    // Description
                    _buildField(
                      label: 'Description',
                      value: report.description,
                    ),
                    const SizedBox(height: 20),

                    // Reported By & Reported Date (2 Columns)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildField(
                            label: 'Reported By',
                            value: report.reportedBy,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildField(
                            label: 'Reported Date',
                            value: report.reportedDate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Due Date
                    _buildField(
                      label: 'Due Date',
                      value: report.dueDate,
                    ),
                    const SizedBox(height: 28),

                    // Actions Section
                    const Text(
                      'Actions',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Verify Fault Report Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          viewModel.verifyReport(report.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fault Report Verified successfully!'),
                              backgroundColor: Color(0xFF059669),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              width: 320,
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 20, color: Colors.white),
                        label: const Text(
                          'Verify Fault Report',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A651),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Update Status Section
                    const Text(
                      'Update Status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 2x2 Status Matrix
                    Column(
                      children: [
                        Row(
                          children: [
                            _buildStatusOption(
                              context: context,
                              status: ReportStatus.pending,
                              bg: const Color(0xFFF1F3F5),
                              fg: const Color(0xFF4B5563),
                              isCurrent: report.status == ReportStatus.pending,
                            ),
                            const SizedBox(width: 12),
                            _buildStatusOption(
                              context: context,
                              status: ReportStatus.inProgress,
                              bg: const Color(0xFFDBEAFE),
                              fg: const Color(0xFF1D4ED8),
                              isCurrent: report.status == ReportStatus.inProgress,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildStatusOption(
                              context: context,
                              status: ReportStatus.completed,
                              bg: const Color(0xFFDCFCE7),
                              fg: const Color(0xFF15803D),
                              isCurrent: report.status == ReportStatus.completed,
                            ),
                            const SizedBox(width: 12),
                            _buildStatusOption(
                              context: context,
                              status: ReportStatus.verified,
                              bg: const Color(0xFFD1FAE5),
                              fg: const Color(0xFF047857),
                              isCurrent: report.status == ReportStatus.verified,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
