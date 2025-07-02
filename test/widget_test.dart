// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:initiative_tracker/main.dart';

void main() {
  testWidgets('Check adding a new character', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const InitiativeTracker());
    await tester.tap(find.text("Add to Initiative"));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Add to Initiative"), findsAny);
  });
}
