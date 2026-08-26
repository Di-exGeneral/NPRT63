import 'package:flutter/foundation.dart';
import 'package:hydroalert_reports/data/repositories/fault_report_repository.dart';
import 'package:hydroalert_reports/domain/models/fault_report.dart';

enum AppScreen {
  dashboard,
  allReports,
}

enum SortOption {
  defaultOrder('Default Order'),
  dueDateAsc('Due Date (Earliest)'),
  dueDateDesc('Due Date (Latest)'),
  titleAsc('Title (A-Z)'),
  priorityDesc('Priority (High to Low)');

  final String label;
  const SortOption(this.label);
}

class ReportsViewModel extends ChangeNotifier {
  final FaultReportRepository _repository;

  ReportsViewModel({required FaultReportRepository repository})
      // ignore: prefer_initializing_formals
      : _repository = repository {
    _loadReports();
  }

  AppScreen _currentScreen = AppScreen.allReports;
  List<FaultReport> _allReports = [];
  String _searchQuery = '';
  ReportStatus? _selectedStatusFilter;
  ReportPriority? _selectedPriorityFilter;
  SortOption _sortOption = SortOption.defaultOrder;
  FaultReport? _selectedReport;

  AppScreen get currentScreen => _currentScreen;
  List<FaultReport> get allReports => _allReports;
  String get searchQuery => _searchQuery;
  ReportStatus? get selectedStatusFilter => _selectedStatusFilter;
  ReportPriority? get selectedPriorityFilter => _selectedPriorityFilter;
  SortOption get sortOption => _sortOption;
  FaultReport? get selectedReport => _selectedReport;

  int get totalCount => _allReports.length;

  int get activeFilterCount {
    int count = 0;
    if (_selectedStatusFilter != null) count++;
    if (_selectedPriorityFilter != null) count++;
    if (_searchQuery.trim().isNotEmpty) count++;
    if (_sortOption != SortOption.defaultOrder) count++;
    return count;
  }

  void _loadReports() {
    _allReports = _repository.getReports();
    if (_selectedReport != null) {
      _selectedReport = _repository.getReportById(_selectedReport!.id);
    }
    notifyListeners();
  }

  void navigateToScreen(AppScreen screen) {
    _currentScreen = screen;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(ReportStatus? status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  void setPriorityFilter(ReportPriority? priority) {
    _selectedPriorityFilter = priority;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedStatusFilter = null;
    _selectedPriorityFilter = null;
    _sortOption = SortOption.defaultOrder;
    notifyListeners();
  }

  void selectReport(FaultReport? report) {
    _selectedReport = report;
    notifyListeners();
  }

  void updateReportStatus(String id, ReportStatus newStatus) {
    _repository.updateReportStatus(id, newStatus);
    _loadReports();
  }

  void verifyReport(String id) {
    _repository.verifyReport(id);
    _loadReports();
  }

  void addNewReport({
    required String title,
    required String location,
    required String description,
    required String reportedBy,
    required String reportedDate,
    required String dueDate,
    required ReportStatus status,
    required ReportPriority priority,
  }) {
    final newId = 'REP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final report = FaultReport(
      id: newId,
      title: title,
      location: location,
      description: description,
      reportedBy: reportedBy,
      reportedDate: reportedDate,
      dueDate: dueDate,
      status: status,
      priority: priority,
    );
    _repository.addReport(report);
    _loadReports();
  }

  void deleteReport(String id) {
    if (_selectedReport?.id == id) {
      _selectedReport = null;
    }
    _repository.deleteReport(id);
    _loadReports();
  }

  List<FaultReport> get filteredReports {
    final list = _allReports.where((report) {
      final query = _searchQuery.trim().toLowerCase();
      if (query.isNotEmpty) {
        final matchesTitle = report.title.toLowerCase().contains(query);
        final matchesLoc = report.location.toLowerCase().contains(query);
        final matchesDesc = report.description.toLowerCase().contains(query);
        final matchesReporter = report.reportedBy.toLowerCase().contains(query);
        if (!matchesTitle && !matchesLoc && !matchesDesc && !matchesReporter) {
          return false;
        }
      }

      if (_selectedStatusFilter != null && report.status != _selectedStatusFilter) {
        return false;
      }

      if (_selectedPriorityFilter != null && report.priority != _selectedPriorityFilter) {
        return false;
      }

      return true;
    }).toList();

    switch (_sortOption) {
      case SortOption.defaultOrder:
        break;
      case SortOption.dueDateAsc:
        list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case SortOption.dueDateDesc:
        list.sort((a, b) => b.dueDate.compareTo(a.dueDate));
        break;
      case SortOption.titleAsc:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.priorityDesc:
        const rank = {
          ReportPriority.urgent: 4,
          ReportPriority.high: 3,
          ReportPriority.medium: 2,
          ReportPriority.low: 1,
        };
        list.sort((a, b) => (rank[b.priority] ?? 0).compareTo(rank[a.priority] ?? 0));
        break;
    }

    return list;
  }
}
