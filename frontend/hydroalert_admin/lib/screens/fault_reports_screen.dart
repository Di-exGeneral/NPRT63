import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';
import 'report_review_screen.dart';

class FaultReportsScreen extends StatefulWidget {
  const FaultReportsScreen({super.key});

  @override
  State<FaultReportsScreen> createState() => _FaultReportsScreenState();
}

class _FaultReportsScreenState extends State<FaultReportsScreen> {
  String? _status;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final q = _query.toLowerCase();
    final reports = admin.reports.where((r) {
      if (_status != null && r.status != _status) return false;
      if (q.isEmpty) return true;
      return [r.displayTitle, r.location, r.description, r.areaName ?? '',
              r.residentName ?? '']
          .any((f) => f.toLowerCase().contains(q));
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search by title, location, area or resident',
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              for (final s in [null, ...ReportStatus.all])
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(s ?? 'All'),
                    selected: _status == s,
                    onSelected: (_) => setState(() => _status = s),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: admin.error != null && admin.reports.isEmpty
              ? MessageView(
                  icon: Icons.cloud_off,
                  message: admin.error!,
                  onRetry: admin.loadAll)
              : reports.isEmpty
                  ? const MessageView(
                      icon: Icons.inbox_outlined,
                      message: 'No fault reports match.')
                  : RefreshIndicator(
                      onRefresh: admin.loadAll,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        itemCount: reports.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, i) {
                          final r = reports[i];
                          return Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              title: Text(r.displayTitle),
                              subtitle: Text(
                                '${r.location} · ${r.areaName ?? admin.areaName(r.areaID)}\n'
                                'Reported ${formatDateTime(r.timestamp)}'
                                '${r.residentName != null ? ' by ${r.residentName}' : ''}',
                              ),
                              isThreeLine: true,
                              trailing: StatusBadge(r.status),
                              onTap: () => openReport(context, r.reportID),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
