import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:escra/main.dart';
import 'package:escra/dependency_injection.dart';

void main() {
  testWidgets('ESCRA app smoke test', (WidgetTester tester) async {
    // Initialize dependency injection service locator for testing
    setupDependencies();

    await tester.pumpWidget(const EscraApp());
    // The app should build without throwing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
