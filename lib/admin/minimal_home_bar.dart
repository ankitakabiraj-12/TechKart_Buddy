import 'package:flutter/material.dart';

class MinimalHomeBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const MinimalHomeBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 4 tabs: Home (house), Sellers (users-round), Products (package), Orders (shopping-bag)
    final items = [
      {'icon': Icons.home_outlined, 'selectedIcon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.group_outlined, 'selectedIcon': Icons.group_rounded, 'label': 'Sellers'},
      {'icon': Icons.inventory_2_outlined, 'selectedIcon': Icons.inventory_2_rounded, 'label': 'Products'},
      {'icon': Icons.shopping_bag_outlined, 'selectedIcon': Icons.shopping_bag_rounded, 'label': 'Orders'},
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF16181A), // deep dark pill
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
