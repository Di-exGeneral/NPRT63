import 'package:flutter/material.dart';
import 'package:hydroalert_reports/domain/models/fault_report.dart';
import 'package:hydroalert_reports/ui/core/theme.dart';

class StatusBadge extends StatelessWidget {
  final ReportStatus status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case ReportStatus.pending:
        bg = AppColors.statusPendingBg;
        fg = AppColors.statusPendingText;
        break;
      case ReportStatus.inProgress:
        bg = AppColors.statusInProgressBg;
        fg = AppColors.statusInProgressText;
        break;
      case ReportStatus.completed:
        bg = AppColors.statusCompletedBg;
        fg = AppColors.statusCompletedText;
        break;
      case ReportStatus.verified:
        bg = AppColors.statusVerifiedBg;
        fg = AppColors.statusVerifiedText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.key,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
