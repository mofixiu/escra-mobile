import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:escra/main.dart';

void main() {
  testWidgets('ESCRA app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EscraApp());
    // The app should build without throwing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
