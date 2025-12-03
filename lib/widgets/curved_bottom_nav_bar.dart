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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navBarHeight =
        MediaQuery.of(context).size.height * 0.11; // 8% of screen height
    final indicatorHeight = navBarHeight * 0.08; // 8% of nav bar height

    return Container(
      height: navBarHeight + bottomPadding,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: navBarHeight * 0.3,
            offset: Offset(0, -navBarHeight * 0.07),
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
              height: indicatorHeight,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 5, 70, 114),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(indicatorHeight * 2.5),
                  topRight: Radius.circular(indicatorHeight * 2.5),
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
                navBarHeight: navBarHeight,
              ),
              _buildNavItem(
                icon: Icons.qr_code_2_outlined,
                selectedIcon: Icons.qr_code_2,
                label: 'My QR',
                index: 1,
                width: itemWidth,
                navBarHeight: navBarHeight,
              ),
              _buildNavItem(
                icon: Icons.qr_code_scanner_outlined,
                selectedIcon: Icons.qr_code_scanner,
                label: 'Scan QR',
                index: 2,
                width: itemWidth,
                navBarHeight: navBarHeight,
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
    required double navBarHeight,
  }) {
    final isSelected = selectedIndex == index;
    final iconSize = navBarHeight * 0.3;
    final labelFontSize = navBarHeight * 0.2;
    final padding = navBarHeight * 0.08;
    final borderRadius = navBarHeight * 0.12;

    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () => onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(
                isSelected ? padding * 1.2 : padding * 0.6,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromARGB(255, 5, 70, 114).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Icon(
                isSelected ? selectedIcon : icon,
                size: iconSize,
                color: isSelected
                    ? const Color.fromARGB(255, 5, 70, 114)
                    : Colors.grey[600],
              ),
            ),
            SizedBox(height: navBarHeight * 0.06),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: labelFontSize,
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
