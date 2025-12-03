import 'package:flutter/material.dart';
import 'package:omnidocs_frontend/widgets/curved_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const Center(child: Text('Profile Screen', style: TextStyle(fontSize: 24))),
    const Center(child: Text('My QR Screen', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Scan QR Screen', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _screens[_selectedIndex],
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
