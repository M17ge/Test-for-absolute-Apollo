import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apollo_agro/main.dart';

void main() {
  testWidgets('App should start without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Login screen should have email and password fields', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Look for email and password fields
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
