import 'package:flutter/material.dart';

class CurvedBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CurvedBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemCount = 3;
    final itemWidth = screenWidth / itemCount;

    final bottomPadding = MediaQuery.of(context).padding.bottom; // Safe area

    return Container(
      height: 70 + bottomPadding, // Adjust height with safe area
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated curved indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: selectedIndex * itemWidth,
            bottom: 0,
            child: Container(
              width: itemWidth,
              height: 4,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 5, 70, 114),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
          ),

          // Navigation items
          Row(
            children: [
              _buildNavItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: 'Profile',
                index: 0,
                width: itemWidth,
              ),
              _buildNavItem(
                icon: Icons.qr_code_2_outlined,
                selectedIcon: Icons.qr_code_2,
                label: 'My QR',
                index: 1,
                width: itemWidth,
              ),
              _buildNavItem(
                icon: Icons.qr_code_scanner_outlined,
                selectedIcon: Icons.qr_code_scanner,
                label: 'Scan QR',
                index: 2,
                width: itemWidth,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required double width,
  }) {
    final isSelected = selectedIndex == index;

    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () => onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(isSelected ? 8 : 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromARGB(255, 5, 70, 114).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? selectedIcon : icon,
                size: isSelected ? 28 : 26,
                color: isSelected
                    ? const Color.fromARGB(255, 5, 70, 114)
                    : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: isSelected ? 13 : 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color.fromARGB(255, 5, 70, 114)
                    : Colors.grey[600],
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
