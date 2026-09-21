import 'package:flutter/foundation.dart';
import 'package:hydroalert_reports/data/repositories/fault_report_repository.dart';
import 'package:hydroalert_reports/domain/models/fault_report.dart';
import 'package:hydroalert_reports/domain/models/user_role.dart';

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
  final FaultReportRepository repository;
  UserRole _currentUserRole;

  ReportsViewModel({
    required this.repository,
    UserRole userRole = UserRole.maintenance,
  })  : _currentUserRole = userRole {
    _loadReports();
  }

  AppScreen _currentScreen = AppScreen.allReports;
  List<FaultReport> _allReports = [];
  String _searchQuery = '';
  ReportStatus? _selectedStatusFilter;
  ReportPriority? _selectedPriorityFilter;
  SortOption _sortOption = SortOption.defaultOrder;
  FaultReport? _selectedReport;
  bool _isLoading = false;
  String? _errorMessage;

  UserRole get currentUserRole => _currentUserRole;
  bool get isAdmin => _currentUserRole.isAdmin;
  bool get canCreateFaultReport => _currentUserRole.canCreateFaultReport;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AppScreen get currentScreen => _currentScreen;
  List<FaultReport> get allReports => _allReports;
  String get searchQuery => _searchQuery;
  ReportStatus? get selectedStatusFilter => _selectedStatusFilter;
  ReportPriority? get selectedPriorityFilter => _selectedPriorityFilter;
  SortOption get sortOption => _sortOption;
  FaultReport? get selectedReport => _selectedReport;

  void setUserRole(UserRole role) {
    _currentUserRole = role;
    notifyListeners();
  }

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
    _allReports = repository.getReports();
    if (_selectedReport != null) {
      _selectedReport = repository.getReportById(_selectedReport!.id);
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
    repository.updateReportStatus(id, newStatus);
    _loadReports();
  }

  Future<void> updateReportStatusOnApi(String id, ReportStatus newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await repository.updateReportStatusOnApi(
        id,
        newStatus,
        changedBy: _currentUserRole.label,
      );
      _loadReports();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReportsFromApi() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await repository.fetchReportsFromApi();
      _loadReports();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void verifyReport(String id) {
    repository.verifyReport(id);
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
    if (!canCreateFaultReport) {
      if (isAdmin) {
        throw StateError('Admin users are not permitted to create fault reports.');
      }
      throw StateError('Only Resident users are permitted to create fault reports.');
    }
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
    repository.addReport(report);
    _loadReports();
  }

  Future<FaultReport> createReportOnApi({
    required String title,
    required String location,
    required String description,
    required String reportedBy,
    required String reportedDate,
    required String dueDate,
    required ReportStatus status,
    required ReportPriority priority,
  }) async {
    if (!canCreateFaultReport) {
      if (isAdmin) {
        throw StateError('Admin users are not permitted to create fault reports.');
      }
      throw StateError('Only Resident users are permitted to create fault reports.');
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
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
      final created = await repository.createReportOnApi(report, userRole: _currentUserRole);
      _loadReports();
      return created;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void deleteReport(String id) {
    if (_selectedReport?.id == id) {
      _selectedReport = null;
    }
    repository.deleteReport(id);
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
