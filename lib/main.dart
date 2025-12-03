import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Corrected import

void main() {
  runApp(const OmniDocs());
}

class OmniDocs extends StatelessWidget {
  const OmniDocs({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniDocs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 5, 70, 114),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
