import 'package:flutter/material.dart';
import 'package:hydroalert_reports/domain/models/fault_report.dart';
import 'package:hydroalert_reports/ui/core/theme.dart';
import 'package:hydroalert_reports/ui/features/reports/view_models/reports_view_model.dart';

class FilterDialog extends StatefulWidget {
  final ReportsViewModel viewModel;

  const FilterDialog({super.key, required this.viewModel});

  static Future<void> show(BuildContext context, ReportsViewModel viewModel) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => FilterDialog(viewModel: viewModel),
    );
  }

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late ReportStatus? _tempStatus;
  late ReportPriority? _tempPriority;
  late SortOption _tempSort;

  @override
  void initState() {
    super.initState();
    _tempStatus = widget.viewModel.selectedStatusFilter;
    _tempPriority = widget.viewModel.selectedPriorityFilter;
    _tempSort = widget.viewModel.sortOption;
  }

  Widget _buildChip<T>({
    required String label,
    required T value,
    required T? selectedValue,
    required ValueChanged<T?> onSelected,
  }) {
    final isSelected = value == selectedValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        onSelected(selected ? value : null);
      },
      selectedColor: AppColors.primaryBlueLight,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primaryBlue : AppColors.border,
        width: isSelected ? 1.5 : 1,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.filter_alt_outlined, color: AppColors.primaryBlue, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Filter Reports',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20, color: AppColors.textLight),
                    splashRadius: 18,
                  ),
                ],
              ),
              const Divider(height: 24, color: AppColors.borderSubtle),

              // Status Filter
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All Statuses'),
                    selected: _tempStatus == null,
                    onSelected: (s) => setState(() => _tempStatus = null),
                    selectedColor: AppColors.primaryBlueLight,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: _tempStatus == null ? AppColors.primaryBlue : AppColors.border,
                      width: _tempStatus == null ? 1.5 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: _tempStatus == null ? AppColors.primaryBlue : AppColors.textPrimary,
                      fontWeight: _tempStatus == null ? FontWeight.w600 : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  ...ReportStatus.values.map((s) => _buildChip<ReportStatus>(
                        label: s.label,
                        value: s,
                        selectedValue: _tempStatus,
                        onSelected: (val) => setState(() => _tempStatus = val),
                      )),
                ],
              ),
              const SizedBox(height: 20),

              // Priority Filter
              const Text(
                'Priority',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All Priorities'),
                    selected: _tempPriority == null,
                    onSelected: (s) => setState(() => _tempPriority = null),
                    selectedColor: AppColors.primaryBlueLight,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: _tempPriority == null ? AppColors.primaryBlue : AppColors.border,
                      width: _tempPriority == null ? 1.5 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: _tempPriority == null ? AppColors.primaryBlue : AppColors.textPrimary,
                      fontWeight: _tempPriority == null ? FontWeight.w600 : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  ...ReportPriority.values.map((p) => _buildChip<ReportPriority>(
                        label: p.label,
                        value: p,
                        selectedValue: _tempPriority,
                        onSelected: (val) => setState(() => _tempPriority = val),
                      )),
                ],
              ),
              const SizedBox(height: 20),

              // Sort Option
              const Text(
                'Sort Order',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<SortOption>(
                    value: _tempSort,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
                    items: SortOption.values.map((opt) {
                      return DropdownMenuItem<SortOption>(
                        value: opt,
                        child: Text(opt.label, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _tempSort = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Buttons
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _tempStatus = null;
                        _tempPriority = null;
                        _tempSort = SortOption.defaultOrder;
                      });
                    },
                    child: const Text('Reset All'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      widget.viewModel.setStatusFilter(_tempStatus);
                      widget.viewModel.setPriorityFilter(_tempPriority);
                      widget.viewModel.setSortOption(_tempSort);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
