import 'package:flutter/material.dart';


class UserInfoDisplay extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserInfoDisplay({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "First Name: ${userData['first_name']}",
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        Text(
          "Last Name: ${userData['last_name']}",
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        Text(
          "Email: ${userData['email']}",
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
