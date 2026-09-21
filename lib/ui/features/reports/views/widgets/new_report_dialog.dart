import 'package:flutter/material.dart';
import 'package:hydroalert_reports/domain/models/fault_report.dart';
import 'package:hydroalert_reports/ui/core/theme.dart';
import 'package:hydroalert_reports/ui/features/reports/view_models/reports_view_model.dart';

class NewReportDialog extends StatefulWidget {
  final ReportsViewModel viewModel;

  const NewReportDialog({super.key, required this.viewModel});

  static Future<void> show(BuildContext context, ReportsViewModel viewModel) {
    if (!viewModel.canCreateFaultReport) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.isAdmin
                ? 'Admin users are not permitted to create fault reports.'
                : 'Only Resident users are permitted to create fault reports.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return Future.value();
    }
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => NewReportDialog(viewModel: viewModel),
    );
  }

  @override
  State<NewReportDialog> createState() => _NewReportDialogState();
}

class _NewReportDialogState extends State<NewReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final TextEditingController _reporterController;
  final _dueDateController = TextEditingController(
    text: DateTime.now().add(const Duration(days: 2)).toString().split(' ').first,
  );

  ReportPriority _selectedPriority = ReportPriority.medium;
  final ReportStatus _selectedStatus = ReportStatus.pending;

  @override
  void initState() {
    super.initState();
    _reporterController = TextEditingController(text: widget.viewModel.currentUserRole.label);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _reporterController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!widget.viewModel.canCreateFaultReport) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.viewModel.isAdmin
                ? 'Admin users cannot submit fault reports.'
                : 'Only Resident users can submit fault reports.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      widget.viewModel.addNewReport(
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        reportedBy: _reporterController.text.trim(),
        reportedDate: DateTime.now().toString().split(' ').first,
        dueDate: _dueDateController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
      );
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New fault report created successfully!'),
          backgroundColor: AppColors.primaryBlue,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          width: 320,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Create Fault Report',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: AppColors.textLight, size: 22),
                        splashRadius: 18,
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.borderSubtle),

                  if (!widget.viewModel.canCreateFaultReport) ...[
                    Container(
                      key: const ValueKey('admin_restriction_banner'),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.viewModel.isAdmin
                                  ? 'Access Restricted: Admin users are not permitted to create fault reports.'
                                  : 'Access Restricted: Only Resident users are permitted to create fault reports.',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Title
                  const Text('Report Title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'e.g. Main Pump Pressure Sensor Failure'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),

                  // Location
                  const Text('Location', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(hintText: 'e.g. Sector A - Building 4'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a location' : null,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text('Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'Detailed description of the fault or maintenance task...'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a description' : null,
                  ),
                  const SizedBox(height: 16),

                  // Priority and Due Date in 2 columns
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Priority', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<ReportPriority>(
                              initialValue: _selectedPriority,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                              items: ReportPriority.values.map((p) {
                                return DropdownMenuItem(value: p, child: Text(p.label));
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedPriority = v);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Due Date (YYYY-MM-DD)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _dueDateController,
                              decoration: const InputDecoration(hintText: '2026-05-12'),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter due date' : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        key: const ValueKey('save_report_button'),
                        onPressed: !widget.viewModel.canCreateFaultReport ? null : _submit,
                        style: !widget.viewModel.canCreateFaultReport
                            ? ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                foregroundColor: Colors.grey.shade600,
                              )
                            : null,
                        child: Text(!widget.viewModel.canCreateFaultReport ? 'Creation Restricted' : 'Save Report'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
