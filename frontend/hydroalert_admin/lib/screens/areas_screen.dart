import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';
import '../widgets/common.dart';

class AreasScreen extends StatelessWidget {
  const AreasScreen({super.key});

  Future<void> _edit(BuildContext context, {Area? area}) async {
    final admin = context.read<AdminProvider>();
    final id = TextEditingController(text: area?.areaID);
    final suburb = TextEditingController(text: area?.suburbName);
    final municipality = TextEditingController(text: area?.municipalityName);
    final formKey = GlobalKey<FormState>();
    String? required(String? v) =>
        v == null || v.trim().isEmpty ? 'Required' : null;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(area == null ? 'Add area' : 'Edit area'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: id,
                enabled: area == null,
                decoration: const InputDecoration(
                    labelText: 'Area code', hintText: 'e.g. JHB-SOWETO'),
                validator: required,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: suburb,
                decoration: const InputDecoration(labelText: 'Suburb'),
                validator: required,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: municipality,
                decoration: const InputDecoration(labelText: 'Municipality'),
                validator: required,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                await admin.saveArea(
                  existingId: area?.areaID,
                  areaID: id.text.trim(),
                  suburb: suburb.text.trim(),
                  municipality: municipality.text.trim(),
                );
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) showSnack(context, '$e', error: true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add area'),
      ),
      body: admin.areas.isEmpty
          ? const MessageView(
              icon: Icons.map_outlined, message: 'No areas added yet.')
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
              children: [
                for (final a in admin.areas)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_city),
                      title: Text(a.suburbName),
                      subtitle: Text('${a.municipalityName} · ${a.areaID}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _edit(context, area: a),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
