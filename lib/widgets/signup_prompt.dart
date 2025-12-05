import 'package:flutter/material.dart';

import '../constants.dart';

class SignUpPrompt extends StatelessWidget {
  final String promptText;
  final String actionText;
  final VoidCallback onTap;

  const SignUpPrompt({
    super.key,
    required this.promptText,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(promptText, style: const TextStyle(color: AppColors.textLight)),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
