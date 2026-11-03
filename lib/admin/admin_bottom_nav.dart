import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'admin_dashboard.dart';
import 'seller_applications.dart';
import 'product_catalog.dart';
import 'marketplace_order_management.dart';
import 'minimal_home_bar.dart';

class AdminBottomNav extends StatefulWidget {
  final int initialIndex;

  const AdminBottomNav({super.key, this.initialIndex = 0});

  @override
  State<AdminBottomNav> createState() => _AdminBottomNavState();
}

class _AdminBottomNavState extends State<AdminBottomNav> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 3);
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index.clamp(0, 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 4 Primary tabs matching user instructions & screenshot:
    // Tab 0: Home (AdminDashboard)
    // Tab 1: Sellers (SellerApplicationsScreen)
    // Tab 2: Products (ProductCatalogScreen)
    // Tab 3: Orders (MarketplaceOrderManagementScreen)
    final List<Widget> pages = [
      AdminDashboard(onNavigateTab: _onTabTapped),
      SellerApplicationsScreen(onNavigateTab: _onTabTapped),
      ProductCatalogScreen(onNavigateTab: _onTabTapped),
      MarketplaceOrderManagementScreen(onNavigateTab: _onTabTapped),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return;
        }
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Admin Console?'),
            content: const Text('Are you sure you want to exit the application?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03253B),
                ),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: MinimalHomeBar(
          currentIndex: _currentIndex,
          onTabSelected: _onTabTapped,
        ),
      ),
    );
  }
}
