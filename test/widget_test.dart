// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:techkart_buddy/main.dart';

void main() {
  testWidgets('App renders SplashScreen and navigates to WelcomeScreen', (WidgetTester tester) async {
    // Build our app and trigger initial frame.
    await tester.pumpWidget(const MyApp());

    // Verify TechKart Buddy branding is present on initial splash frame
    expect(find.text('TechKart Buddy'), findsOneWidget);
    expect(find.text('Your Business. Your Growth.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // Advance time - verify SplashScreen does NOT auto-navigate
    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pumpAndSettle();
    expect(find.text('Get Started'), findsOneWidget);

    // Tap Get Started
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify WelcomeScreen loaded
    expect(find.text('Start Selling on\nTechKart'), findsOneWidget);
    expect(find.text('Create Seller Account'), findsOneWidget);
  });
}
