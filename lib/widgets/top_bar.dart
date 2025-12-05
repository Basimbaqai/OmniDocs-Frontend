import 'package:flutter/material.dart';

import '../constants.dart';

class TopBar extends StatelessWidget {
  final int currentIndex;

  const TopBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    List<String> titles = ['Profile', 'QR Codes', 'Scan QR'];

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            titles[currentIndex],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
