import 'package:flutter/material.dart';
import '../api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String token; // from login

  const ProfileScreen({super.key, required this.token});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    print('DEBUG: Token = "${widget.token}"'); // token
    try {
      final data = await ApiService.getCurrentUser(widget.token);
      print('DEBUG: User data received = $data'); // user data
      setState(() {
        userData = data;
        loading = false;
      });
    } catch (e, st) {
      print('DEBUG: Error loading user: $e');
      print('DEBUG: Stack trace: $st');
      setState(() => loading = false);
    }
  }

  Future<void> deleteAccount() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure? This action cannot be undone."),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.deleteUser(widget.token);

      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userData == null) {
      return const Center(child: Text("Failed to load profile"));
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "First Name: ${userData!['first_name']}",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            "Last Name: ${userData!['last_name']}",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            "Email: ${userData!['email']}",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),

          // Delete Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.all(12),
            ),
            onPressed: deleteAccount,
            child: const Text("Delete Account"),
          ),
        ],
      ),
    );
  }
}
