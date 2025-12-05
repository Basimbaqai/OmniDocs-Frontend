import 'package:flutter/material.dart';

import '../constants.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onLogout;
  final String title;

  const TopBar({super.key, required this.onLogout, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            color: Theme.of(context).primaryColor,
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}
