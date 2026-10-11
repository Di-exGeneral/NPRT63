import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';

void openReport(BuildContext context, String reportID) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ReportReviewScreen(reportID: reportID)),
  );
}

Future<bool> showAssignTeamDialog(BuildContext context, FaultReport report) async {
  final admin = context.read<AdminProvider>();
  String? teamID;
  final assigned = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Assign ${report.displayTitle}'),
        content: SizedBox(
          width: 400,
          child: admin.teams.isEmpty
              ? const Text('No maintenance teams are registered yet.')
              : ListView(
                  shrinkWrap: true,
                  children: [
                    for (final t in admin.teams)
                      ListTile(
                        selected: teamID == t.teamID,
                        leading: Icon(teamID == t.teamID
                            ? Icons.check_circle
                            : Icons.groups_outlined),
                        title: Text(t.name),
                        subtitle: Text(
                            '${t.activeAssignments} active job(s) · ${t.phoneNumber}'),
                        onTap: () => setState(() => teamID = t.teamID),
                      ),
                  ],
                ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: teamID == null
                ? null
                : () async {
                    try {
                      await admin.assignTeam(report.reportID, teamID!);
                      if (context.mounted) Navigator.pop(context, true);
                    } catch (e) {
                      if (context.mounted) showSnack(context, '$e', error: true);
                    }
                  },
            child: const Text('Assign team'),
          ),
        ],
      ),
    ),
  );
  return assigned ?? false;
}

class ReportReviewScreen extends StatefulWidget {
  const ReportReviewScreen({super.key, required this.reportID});
  final String reportID;

  @override
  State<ReportReviewScreen> createState() => _ReportReviewScreenState();
}

class _ReportReviewScreenState extends State<ReportReviewScreen> {
  FaultReport? _report;
  List<ReportHistoryEntry> _history = [];
  Assignment? _assignment;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = context.read<AdminProvider>().api;
    try {
      final results = await Future.wait([
        api.getReport(widget.reportID),
        api.getReportHistory(widget.reportID),
        api.getReportAssignment(widget.reportID),
      ]);
      if (!mounted) return;
      setState(() {
        _report = results[0] as FaultReport;
        _history = results[1] as List<ReportHistoryEntry>;
        _assignment = results[2] as Assignment?;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  Future<void> _setStatus(String status) async {
    final userID = context.read<AuthProvider>().currentUser!.userID;
    setState(() => _busy = true);
    try {
      await context
          .read<AdminProvider>()
          .updateReportStatus(widget.reportID, status, userID);
      await _load();
      if (mounted) showSnack(context, 'Status updated to $status');
    } catch (e) {
      if (mounted) showSnack(context, '$e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final r = _report;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Report Review')),
      body: r == null
          ? (_error != null
              ? MessageView(
                  icon: Icons.error_outline, message: _error!, onRetry: _load)
              : const Center(child: CircularProgressIndicator()))
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                SectionCard(
                  title: r.displayTitle,
                  subtitle: 'Reported ${formatDateTime(r.timestamp)}',
                  trailing: StatusBadge(r.status),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Field('Location', r.location, Icons.place_outlined),
                      _Field('Area', r.areaName ?? admin.areaName(r.areaID),
                          Icons.map_outlined),
                      _Field('Reported by', r.residentName ?? r.residentID,
                          Icons.person_outline),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Description', style: text.titleMedium),
                      Text(r.description),
                      if (r.photos.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text('Photos', style: text.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            for (final url in r.photos)
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                                child: Image.network(url,
                                    width: 140,
                                    height: 140,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const SizedBox(
                                        width: 140,
                                        height: 140,
                                        child: Icon(Icons.broken_image))),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SectionCard(
                  title: 'Review actions',
                  subtitle: _assignment == null
                      ? 'No maintenance team assigned yet'
                      : 'Assigned to ${admin.teamById(_assignment!.teamID)?.name ?? 'a maintenance team'} on ${formatDateTime(_assignment!.assignedAt)}',
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      if (r.status == ReportStatus.submitted)
                        OutlinedButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _setStatus(ReportStatus.underReview),
                          icon: const Icon(Icons.rate_review_outlined),
                          label: const Text('Mark under review'),
                        ),
                      FilledButton.icon(
                        onPressed: _busy
                            ? null
                            : () async {
                                if (await showAssignTeamDialog(context, r)) {
                                  await _load();
                                }
                              },
                        icon: const Icon(Icons.groups),
                        label: Text(_assignment == null
                            ? 'Approve & assign'
                            : 'Reassign team'),
                      ),
                      PopupMenuButton<String>(
                        enabled: !_busy,
                        onSelected: _setStatus,
                        itemBuilder: (_) => [
                          for (final s in ReportStatus.all)
                            if (s != r.status)
                              PopupMenuItem(value: s, child: Text(s)),
                        ],
                        child: const Chip(
                          avatar: Icon(Icons.swap_horiz, size: 18),
                          label: Text('Change status'),
                        ),
                      ),
                      if (r.status != ReportStatus.rejected)
                        TextButton.icon(
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.error),
                          onPressed: _busy
                              ? null
                              : () async {
                                  if (await confirm(context, 'Reject report?',
                                      'The resident will be notified that this report was rejected.')) {
                                    await _setStatus(ReportStatus.rejected);
                                  }
                                },
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('Reject report'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SectionCard(
                  title: 'Status history',
                  child: _history.isEmpty
                      ? const Text('No status changes yet.')
                      : Column(
                          children: [
                            for (final h in _history)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.history),
                                title: Text(
                                    '${h.previousStatus ?? '-'} → ${h.newStatus}'),
                                subtitle: Text(formatDateTime(h.changedAt)),
                              ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Text('$label: ', style: Theme.of(context).textTheme.titleSmall),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
