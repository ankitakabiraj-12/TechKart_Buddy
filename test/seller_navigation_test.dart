import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techkart_buddy/seller/bottom_navigation.dart';
import 'package:techkart_buddy/seller/seller_dashboard.dart';
import 'package:techkart_buddy/seller/seller_top_bar.dart';

void main() {
  testWidgets('SellerMinimalHomeBar renders 4 tabs and switches correctly', (WidgetTester tester) async {
    int selectedIndex = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: SellerMinimalHomeBar(
            currentIndex: selectedIndex,
            onTabSelected: (index) {
              selectedIndex = index;
            },
          ),
        ),
      ),
    );

    expect(find.byType(SellerMinimalHomeBar), findsOneWidget);

    // Active Home icon (house)
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);

    // Inactive icons for Products (package), Order (receipt_long), Account (person)
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);

    // Tap Products tab (index 1)
    await tester.tap(find.byIcon(Icons.inventory_2_outlined));
    await tester.pumpAndSettle();
    expect(selectedIndex, 1);
  });

  testWidgets('SellerBottomNav renders SellerHomeTab on index 0', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: SellerBottomNav(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SellerHomeTab), findsOneWidget);
    expect(find.byType(SellerMinimalHomeBar), findsOneWidget);
  });

  testWidgets('Seller top bar displays logo only on Home, screen title on other tabs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: SellerBottomNav(),
      ),
    );
    await tester.pumpAndSettle();

    // On Home: SellerTopBar is rendered with isHome == true
    final homeTopBarFinder = find.byType(SellerTopBar);
    expect(homeTopBarFinder, findsOneWidget);
    final SellerTopBar homeTopBar = tester.widget(homeTopBarFinder);
    expect(homeTopBar.isHome, true);

    // Switch to Products tab (index 1)
    await tester.tap(find.descendant(
      of: find.byType(SellerMinimalHomeBar),
      matching: find.byIcon(Icons.inventory_2_outlined),
    ));
    await tester.pumpAndSettle();

    // On Products: Screen title is visible
    expect(find.text('My Products'), findsOneWidget);

    // Switch to Orders tab (index 2)
    await tester.tap(find.descendant(
      of: find.byType(SellerMinimalHomeBar),
      matching: find.byIcon(Icons.receipt_long_outlined),
    ));
    await tester.pumpAndSettle();

    // On Orders: Screen title is visible
    expect(find.text('Orders'), findsOneWidget);

    // Switch to Account / Notifications tab (index 3)
    await tester.tap(find.descendant(
      of: find.byType(SellerMinimalHomeBar),
      matching: find.byIcon(Icons.person_outline_rounded),
    ));
    await tester.pumpAndSettle();

    // On Account: Screen title is visible
    expect(find.text('Account'), findsOneWidget);
  });
}
