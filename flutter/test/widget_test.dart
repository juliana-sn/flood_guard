// This is a basic Flutter widget test for Flood Guard.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flood_guard/main.dart';

void main() {
  testWidgets('Flood Guard app starts and shows LoginScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FloodGuardApp());

    // Verify that the app title is displayed.
    expect(find.text('Flood Guard'), findsWidgets);
    
    // Verify that we're on the login screen.
    expect(find.text('Acesse sua conta'), findsOneWidget);
  });
}
