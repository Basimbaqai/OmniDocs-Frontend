import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/curved_bottom_nav_bar.dart';
import '../widgets/top_bar.dart';
import 'documents_and_qr_screen.dart';
import 'profile_screen.dart';
import 'scan_qr_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token; // token passed from login

  const HomeScreen({super.key, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    // Initialize screens here since token is needed for all screens
    _screens = [
      ProfileScreen(token: widget.token),
      DocumentsAndQrScreen(token: widget.token),
      ScanQrScreen(token: widget.token),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Column(
          children: [
            TopBar(currentIndex: _selectedIndex),
            Expanded(child: _screens[_selectedIndex]),
          ],
        ),
      ),

      // ---------- Bottom Navigation ----------
      bottomNavigationBar: SafeArea(
        top: false,
        child: CurvedBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
