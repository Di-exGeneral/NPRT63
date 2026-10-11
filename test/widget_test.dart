import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydro_alert/main.dart';

void main() {
  testWidgets('HydroAlert app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const HydroAlertApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
