import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../services/fault_report_provider.dart';
import '../../services/auth_provider.dart';
import 'report_detail_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  @override
  void initState() {
    super.initState();
    final resident = context.read<AuthProvider>().resident;
    if (resident != null) {
      context.read<FaultReportProvider>().fetchMyReports(resident.residentID);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in progress':
        return AppColors.primary;
      case 'resolved':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FaultReportProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('My Reports', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : provider.reports.isEmpty
          ? const Center(child: Text('No reports submitted yet', style: TextStyle(color: AppColors.textSecondary)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.reports.length,
        itemBuilder: (context, index) {
          final report = provider.reports[index];
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(report.location, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(report.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report.status,
                      style: TextStyle(color: _statusColor(report.status), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ReportDetailScreen(reportId: report.id)),
              ),
            ),
          );
        },
      ),
    );
  }
}