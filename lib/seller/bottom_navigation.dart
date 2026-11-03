import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'seller_dashboard.dart';
import 'my_products.dart';
import 'orders_details.dart';
import 'notification.dart';
import 'app_exit.dart';

/// Root shell for the Seller experience.
/// Hosts the 4-tab floating minimalist bottom navigation:
/// Home | Products | Order | Account matching the reference homebar design.
class SellerBottomNav extends StatefulWidget {
  final int initialIndex;

  const SellerBottomNav({super.key, this.initialIndex = 0});

  @override
  State<SellerBottomNav> createState() => _SellerBottomNavState();
}

class _SellerBottomNavState extends State<SellerBottomNav> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }
        final shouldExit = await showExitConfirmationDialog(context);
        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F8FE),
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            SellerHomeTab(onNavigate: _onTabTapped),
            const MyProducts(),
            const OrdersDetails(),
            const SellerNotificationScreen(),
          ],
        ),
        bottomNavigationBar: SellerMinimalHomeBar(
          currentIndex: _currentIndex,
          onTabSelected: _onTabTapped,
        ),
      ),
    );
  }
}

/// Minimalist Modern Home Bar for Seller Portal matching the reference design:
/// - Black rounded capsule container
/// - 4 evenly spaced icons: Home, Products, Order, Account
/// - White circular active-tab highlight with inverted icon
class SellerMinimalHomeBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const SellerMinimalHomeBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 4 tabs: Home, Products, Order, Account
    final items = [
      {
        'icon': Icons.home_outlined,
        'selectedIcon': Icons.home_rounded,
        'label': 'Home',
      },
      {
        'icon': Icons.inventory_2_outlined,
        'selectedIcon': Icons.inventory_2_rounded,
        'label': 'Products',
      },
      {
        'icon': Icons.receipt_long_outlined,
        'selectedIcon': Icons.receipt_long_rounded,
        'label': 'Order',
      },
      {
        'icon': Icons.person_outline_rounded,
        'selectedIcon': Icons.person_rounded,
        'label': 'Account',
      },
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF16181A), // Sleek black rounded capsule
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (index) {
              final isSelected = currentIndex == index;
              final item = items[index];
              final IconData iconData = isSelected
                  ? item['selectedIcon'] as IconData
                  : item['icon'] as IconData;

              return Expanded(
                child: Center(
                  child: InkWell(
                    onTap: () => onTabSelected(index),
                    borderRadius: BorderRadius.circular(26),
                    splashColor: Colors.white24,
                    highlightColor: Colors.transparent,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          shape: BoxShape.circle,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          iconData,
                          size: 24,
                          color: isSelected
                              ? const Color(0xFF16181A)
                              : Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ),
        ),
      ),
    );
  }
}
