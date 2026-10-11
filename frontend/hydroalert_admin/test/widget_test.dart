import 'package:flutter_test/flutter_test.dart';
import 'package:hydro_alert/models/models.dart';
import 'package:hydro_alert/utils/formatters.dart';

void main() {
  test('parses naive API timestamps as UTC', () {
    final d = parseApiDateTime('2026-10-11T08:00:00');
    expect(d!.isUtc, isTrue);
    expect(toApiDateTime(d), '2026-10-11T08:00:00.000');
  });

  test('parses fault report payload from the API', () {
    final r = FaultReport.fromJson({
      'reportID': 'abcdef1234',
      'title': 'Untitled',
      'residentID': 'r1',
      'areaID': 'a1',
      'description': 'Burst pipe',
      'status': 'Submitted',
      'location': 'Main Rd',
      'timestamp': '2026-10-11T08:00:00',
      'photos': ['https://x/y.jpg'],
    });
    expect(r.displayTitle, 'Fault report ABCDEF12');
    expect(r.photos, hasLength(1));
  });

  test('dashboard summary sums report statuses', () {
    final s = DashboardSummary.fromJson({
      'reportsByStatus': {'Submitted': 2, 'Under Review': 1, 'Resolved': 4},
    });
    expect(s.reportsWith(ReportStatus.open), 3);
  });
}
