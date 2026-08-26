import 'package:flutter/material.dart';
import 'package:hydroalert_reports/domain/models/fault_report.dart';
import 'package:hydroalert_reports/ui/core/theme.dart';

class PriorityBadge extends StatelessWidget {
  final ReportPriority priority;

  const PriorityBadge({
    super.key,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (priority) {
      case ReportPriority.urgent:
        bg = AppColors.priorityUrgentBg;
        fg = AppColors.priorityUrgentText;
        break;
      case ReportPriority.high:
        bg = AppColors.priorityHighBg;
        fg = AppColors.priorityHighText;
        break;
      case ReportPriority.medium:
        bg = AppColors.priorityMediumBg;
        fg = AppColors.priorityMediumText;
        break;
      case ReportPriority.low:
        bg = AppColors.priorityLowBg;
        fg = AppColors.priorityLowText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        priority.key,
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
