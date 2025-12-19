// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rotiku/main.dart';

void main() {
  testWidgets('App loads without error', (WidgetTester tester) async {
    // Build our app with Firebase initialized
    await tester.pumpWidget(const MyApp(
      firebaseInitialized: true,
      firebaseError: null,
    ));

    // Verify that app loads (we should see either login screen or auth wrapper)
    await tester.pumpAndSettle();
    
    // Test passes if app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
