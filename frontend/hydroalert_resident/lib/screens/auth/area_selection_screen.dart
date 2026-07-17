import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/area_model.dart';
import '../../services/area_provider.dart';
import '../resident/resident_dashboard.dart';
import '../../services/api_service.dart';
import '../../services/auth_provider.dart';

class AreaSelectionScreen extends StatefulWidget {
  const AreaSelectionScreen({super.key});

  @override
  State<AreaSelectionScreen> createState() => _AreaSelectionScreenState();
}

class _AreaSelectionScreenState extends State<AreaSelectionScreen> {
  AreaModel? _selectedArea;

  @override
  void initState() {
    super.initState();
    context.read<AreaProvider>().fetchAreas();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AreaProvider>();
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 36),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Select Your Area',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose your service area to receive relevant updates',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                if (provider.isLoading)
                  const CircularProgressIndicator(color: AppColors.primary)
                else if (provider.error != null)
                  Text(provider.error!, style: const TextStyle(color: AppColors.error))
                else if (provider.areas.isEmpty)
                    const Text('No areas available', style: TextStyle(color: AppColors.textSecondary))
                  else
                    ...provider.areas.map((area) => GestureDetector(
                      onTap: () => setState(() => _selectedArea = area),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedArea?.id == area.id ? AppColors.primary : AppColors.border,
                            width: _selectedArea?.id == area.id ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: _selectedArea?.id == area.id ? AppColors.primaryLight : Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(area.suburbName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            const SizedBox(height: 4),
                            Text(area.municipalityName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _selectedArea == null ? null : () async {
                      context.read<AreaProvider>().selectArea(_selectedArea!);
                      try {
                        final api = ApiService();
                        await api.patch('/areas/me/area', data: {'areaID': _selectedArea!.id});
                      } catch (e) {
                        print('Failed to save area: $e');
                      }
                      if (!mounted) return;
                      await context.read<AuthProvider>().refreshResident();
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const ResidentDashboard()),
                      );
                    },
                    child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ResidentDashboard()),
                  ),
                  child: const Text('Skip for now', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}