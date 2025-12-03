import 'package:flutter/material.dart';
import '../widgets/curved_bottom_nav_bar.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override  State<HomeScreen> createState() => _HomeScreenState();
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. Invisible placeholder to balance the row
                  const SizedBox(width: 48),

                  // 2. Centered Text
                  const Text(
                    'Welcome, Admin!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  // 3. Logout Button on the right
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Logout',
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                            (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      ),
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
