import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';

class OutageScheduleScreen extends StatelessWidget {
  const OutageScheduleScreen({super.key});

  Future<void> _run(BuildContext context, Future<void> Function() action,
      String success) async {
    try {
      await action();
      if (context.mounted) showSnack(context, success);
    } catch (e) {
      if (context.mounted) showSnack(context, '$e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: admin.areas.isEmpty
            ? () => showSnack(context, 'Add an area first (Areas tab).',
                error: true)
            : () => showScheduleDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New schedule'),
      ),
      body: admin.schedules.isEmpty
          ? const MessageView(
              icon: Icons.event_busy, message: 'No outage schedules yet.')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
              itemCount: admin.schedules.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final o = admin.schedules[i];
                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(
                      o.isOngoing ? Icons.water_drop : Icons.event_note,
                      color: o.isOngoing ? AppColors.error : AppColors.primary,
                    ),
                    title: Text(admin.areaName(o.areaID)),
                    subtitle: Text(
                      '${formatDateTime(o.startTime)} → ${formatDateTime(o.endTime)}'
                      '${(o.description ?? '').isNotEmpty ? '\n${o.description}' : ''}',
                    ),
                    isThreeLine: (o.description ?? '').isNotEmpty,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusBadge(o.status),
                        PopupMenuButton<String>(
                          onSelected: (action) async {
                            if (action == 'edit') {
                              await showScheduleDialog(context, existing: o);
                            } else if (action == 'delete') {
                              if (await confirm(context, 'Delete schedule?',
                                      'This removes the outage schedule permanently.') &&
                                  context.mounted) {
                                await _run(
                                    context,
                                    () => admin.deleteSchedule(o.scheduleID),
                                    'Schedule deleted');
                              }
                            } else {
                              await _run(
                                  context,
                                  () => admin.setScheduleStatus(
                                      o.scheduleID, action),
                                  'Schedule marked $action. Residents notified.');
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                                value: 'edit', child: Text('Edit')),
                            for (final s in OutageStatus.all)
                              if (s != o.status)
                                PopupMenuItem(
                                    value: s, child: Text('Mark $s')),
                            const PopupMenuItem(
                                value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

Future<void> showScheduleDialog(BuildContext context,
    {OutageSchedule? existing}) async {
  final admin = context.read<AdminProvider>();
  final userID = context.read<AuthProvider>().currentUser!.userID;
  String? areaID = existing?.areaID ?? admin.areas.first.areaID;
  var start = existing?.startTime?.toLocal() ??
      DateTime.now().add(const Duration(days: 1));
  var end = existing?.endTime?.toLocal() ?? start.add(const Duration(hours: 4));
  final description = TextEditingController(text: existing?.description);
  bool saving = false;

  Future<DateTime?> pick(BuildContext context, DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null || !context.mounted) return null;
    final time = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(existing == null ? 'New outage schedule' : 'Edit schedule'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: areaID,
                decoration: const InputDecoration(labelText: 'Affected area'),
                items: [
                  for (final a in admin.areas)
                    DropdownMenuItem(value: a.areaID, child: Text(a.label)),
                ],
                onChanged: (v) => setState(() => areaID = v),
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.play_arrow_outlined),
                title: const Text('Starts'),
                subtitle: Text(formatDateTime(start)),
                onTap: () async {
                  final v = await pick(context, start);
                  if (v != null) setState(() => start = v);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.restore),
                title: const Text('Water restored by'),
                subtitle: Text(formatDateTime(end)),
                onTap: () async {
                  final v = await pick(context, end);
                  if (v != null) setState(() => end = v);
                },
              ),
              TextField(
                controller: description,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Description / reason (shown to residents)'),
              ),
              if (!end.isAfter(start))
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.sm),
                  child: Text('End time must be after start time.',
                      style: TextStyle(color: AppColors.error)),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: saving || areaID == null || !end.isAfter(start)
                ? null
                : () async {
                    setState(() => saving = true);
                    try {
                      if (existing == null) {
                        await admin.createSchedule(
                            areaID: areaID!,
                            start: start,
                            end: end,
                            createdBy: userID,
                            description: description.text.trim());
                      } else {
                        await admin.updateSchedule(existing.scheduleID,
                            areaID: areaID!,
                            start: start,
                            end: end,
                            description: description.text.trim());
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                        showSnack(context,
                            'Schedule published. Residents in the area were notified.');
                      }
                    } catch (e) {
                      setState(() => saving = false);
                      if (context.mounted) showSnack(context, '$e', error: true);
                    }
                  },
            child: Text(existing == null ? 'Publish' : 'Save'),
          ),
        ],
      ),
    ),
  );
}
