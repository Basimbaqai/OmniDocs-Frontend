import 'package:flutter/material.dart';
import '../widgets/curved_bottom_nav_bar.dart';
import '../screens/profile_screen.dart';
import 'login_screen.dart';

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

    // Initialize screens here since token is needed for ProfileScreen
    _screens = [
      ProfileScreen(token: widget.token),
      const Center(child: Text('My QR Screen', style: TextStyle(fontSize: 24))),
      const Center(
        child: Text('Scan QR Screen', style: TextStyle(fontSize: 24)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SafeArea(
        child: Column(
          children: [
            // ---------- Top Bar ----------
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left placeholder (to center title)
                  const SizedBox(width: 48),

                  const Text(
                    'Welcome, Admin!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  // Logout Button
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Logout',
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),

            // ---------- Body ----------
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
