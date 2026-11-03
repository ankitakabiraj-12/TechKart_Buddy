import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techkart_buddy/admin/admin_bottom_nav.dart';
import 'package:techkart_buddy/admin/minimal_home_bar.dart';
import 'package:techkart_buddy/admin/admin_top_bar.dart';
import 'package:techkart_buddy/seller/splash_screen.dart';
import 'package:techkart_buddy/admin/admin_login.dart';
import 'package:techkart_buddy/admin/admin_auth_service.dart';

void main() {
  testWidgets('MinimalHomeBar renders 4 items and switches tabs', (WidgetTester tester) async {
    int selectedIndex = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: MinimalHomeBar(
            currentIndex: selectedIndex,
            onTabSelected: (index) {
              selectedIndex = index;
            },
          ),
        ),
      ),
    );

    expect(find.byType(MinimalHomeBar), findsOneWidget);
    // Index 0 is selected, so selectedIcon Icons.home_rounded is active (house)
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    // Other unselected icons: Sellers (users-round), Products (package), Orders (shopping-bag)
    expect(find.byIcon(Icons.group_outlined), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);

    // Tap Sellers tab (index 1)
    await tester.tap(find.byIcon(Icons.group_outlined));
    await tester.pumpAndSettle();
    expect(selectedIndex, 1);
  });

  testWidgets('AdminBottomNav renders Home with AdminTopBar and branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AdminBottomNav(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify AdminTopBar exists on Home and is in home mode
    final topBarFinder = find.byType(AdminTopBar);
    expect(topBarFinder, findsOneWidget);
    final AdminTopBar topBar = tester.widget(topBarFinder);
    expect(topBar.isHome, true);
  });

  testWidgets('Seller SplashScreen can configure destination for Admin', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(
          nextScreen: AdminLogin(),
          portalBadgeText: 'ADMIN CONSOLE',
        ),
      ),
    );

    expect(find.text('ADMIN CONSOLE'), findsOneWidget);
    expect(find.text('TechKart Buddy'), findsOneWidget);
  });

  testWidgets('AdminLogin displays validation, toggles password, and authenticates', (WidgetTester tester) async {
    // Provide a taller surface size so the entire scrollable screen fits into view
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: AdminLogin(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify UI Elements
    expect(find.text('Administrator Access'), findsOneWidget);
    expect(find.text('Authenticate Operator'), findsOneWidget);
    expect(find.text('Authorized Operations Only'), findsOneWidget);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    // Toggle password visibility
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    // Ensure button is visible in scroll view and tap Authenticate Operator
    final authBtn = find.text('Authenticate Operator');
    await tester.ensureVisible(authBtn);
    await tester.tap(authBtn);
    await tester.pump(); // Triggers loading state

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete mock network delay (900ms) and transition animations
    await tester.pumpAndSettle(const Duration(milliseconds: 1200));

    // Verify navigation landed on AdminBottomNav / Home
    expect(find.byType(AdminBottomNav), findsOneWidget);
  });

  test('AdminAuthService mock rejects invalid credentials correctly', () async {
    final result = await AdminAuthService.login(
      emailOrId: 'invalid-operator',
      password: 'wrongpassword',
    );
    expect(result.success, false);
    expect(result.errorMessage, contains('Invalid operator credentials'));
  });
}
