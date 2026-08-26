import 'package:flutter/material.dart';
import 'package:hydroalert_reports/domain/models/fault_report.dart';
import 'package:hydroalert_reports/ui/core/theme.dart';
import 'package:hydroalert_reports/ui/core/widgets/priority_badge.dart';
import 'package:hydroalert_reports/ui/core/widgets/status_badge.dart';

class FaultReportCard extends StatefulWidget {
  final FaultReport report;
  final VoidCallback onViewDetails;

  const FaultReportCard({
    super.key,
    required this.report,
    required this.onViewDetails,
  });

  @override
  State<FaultReportCard> createState() => _FaultReportCardState();
}

class _FaultReportCardState extends State<FaultReportCard> {
  bool _isHovered = false;

  Widget _buildStatusIcon(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return const Icon(
          Icons.error_outline_rounded,
          color: Color(0xFF9CA3AF),
          size: 22,
        );
      case ReportStatus.inProgress:
        return const Icon(
          Icons.access_time_rounded,
          color: Color(0xFF2563EB),
          size: 22,
        );
      case ReportStatus.completed:
        return const Icon(
          Icons.check_circle_outline_rounded,
          color: Color(0xFF16A34A),
          size: 22,
        );
      case ReportStatus.verified:
        return const Icon(
          Icons.verified_outlined,
          color: Color(0xFF059669),
          size: 22,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xFFF9FAFC) : Colors.white,
          border: const Border(
            bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status Indicator Icon
            Container(
              margin: const EdgeInsets.only(right: 18),
              alignment: Alignment.center,
              child: _buildStatusIcon(report.status),
            ),

            // Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.location,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      StatusBadge(status: report.status),
                      PriorityBadge(priority: report.priority),
                      Text(
                        'Due: ${report.dueDate}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // View Details Button
            ElevatedButton(
              onPressed: widget.onViewDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
