import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../services/outage_provider.dart';

class OutageScheduleScreen extends StatefulWidget {
  const OutageScheduleScreen({super.key});

  @override
  State<OutageScheduleScreen> createState() => _OutageScheduleScreenState();
}

class _OutageScheduleScreenState extends State<OutageScheduleScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OutageProvider>().fetchOutages();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.error;
      case 'scheduled':
        return AppColors.primary;
      case 'completed':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OutageProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Outage Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : provider.outages.isEmpty
          ? const Center(child: Text('No scheduled outages', style: TextStyle(color: AppColors.textSecondary)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.outages.length,
        itemBuilder: (context, index) {
          final outage = provider.outages[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(outage.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(outage.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(outage.status, style: TextStyle(color: _statusColor(outage.status), fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(outage.areaName, style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${outage.startTime.toString().substring(0, 16)} - ${outage.endTime.toString().substring(11, 16)}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(outage.description, style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}