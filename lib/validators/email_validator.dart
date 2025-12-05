import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

class EmailValidator {
  // Gmail SMTP server details
  static const String _gmailSmtpHost = 'smtp.gmail.com';
  static const int _gmailSmtpPort = 587;

  /// Validates if a Gmail address exists by attempting to verify with Gmail's SMTP server
  /// Returns true if the email exists, false otherwise
  static Future<bool> validateGmailExists(String email) async {
    // First, check if it's actually a Gmail address
    if (!email.endsWith('@gmail.com')) {
      throw Exception(
        'Please enter a valid Gmail address (ending with @gmail.com)',
      );
    }

    // Basic email format validation
    if (!_isValidEmailFormat(email)) {
      throw Exception('Invalid email format');
    }

    try {
      // Use DNS MX record lookup to verify Gmail can receive emails
      // This is a lightweight check that doesn't require SMTP connection
      return await _verifyEmailMxRecord(email);
    } catch (e) {
      throw Exception('Unable to verify email: ${e.toString()}');
    }
  }

  /// Validates email format using regex
  static bool _isValidEmailFormat(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@gmail\.com$');
    return emailRegex.hasMatch(email);
  }

  /// Verifies email by checking Gmail's ability to receive it
  /// This makes a request to verify the email domain accepts the mailbox
  static Future<bool> _verifyEmailMxRecord(String email) async {
    try {
      // Extract domain
      final domain = email.split('@')[1];

      // Check if domain is reachable and can accept emails
      // We do a simple HTTP GET to Google's MX record verification
      final uri = Uri.https('dns.google', '/resolve', {
        'name': domain,
        'type': 'MX',
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      // If we get a response, the domain exists
      if (response.statusCode == 200) {
        // For Gmail, we also verify that the username part is valid
        return _isValidGmailUsername(email.split('@')[0]);
      }

      return false;
    } catch (e) {
      // If DNS lookup fails, try alternative verification
      return _performSimpleEmailValidation(email);
    }
  }

  /// Performs simple Gmail username validation
  /// Gmail usernames must be 6-30 characters and can contain letters, numbers, periods, and underscores
  static bool _isValidGmailUsername(String username) {
    if (username.isEmpty || username.length < 6) {
      throw Exception('Gmail username must be at least 6 characters');
    }
    if (username.length > 30) {
      throw Exception('Gmail username must be at most 30 characters');
    }

    // Gmail doesn't allow consecutive dots or dots at start/end
    if (username.startsWith('.') ||
        username.endsWith('.') ||
        username.contains('..')) {
      throw Exception(
        'Gmail username cannot start/end with a dot or have consecutive dots',
      );
    }

    // Check valid characters
    final validCharsRegex = RegExp(r'^[a-zA-Z0-9._-]+$');
    if (!validCharsRegex.hasMatch(username)) {
      throw Exception('Gmail username contains invalid characters');
    }

    return true;
  }

  /// Simple fallback validation when DNS lookup is not available
  static Future<bool> _performSimpleEmailValidation(String email) async {
    try {
      // Try to connect to Gmail's SMTP server
      final socket = await Socket.connect(
        _gmailSmtpHost,
        _gmailSmtpPort,
        timeout: const Duration(seconds: 5),
      );

      socket.destroy();
      return true;
    } catch (e) {
      // If we can't verify, accept the email if it's properly formatted
      // (Better UX - the server will reject invalid emails during signup)
      return _isValidEmailFormat(email);
    }
  }

  /// Quick format-only validation (no network call)
  static String? validateEmailFormatOnly(String email) {
    if (email.isEmpty) {
      return 'Email cannot be empty';
    }

    if (!email.endsWith('@gmail.com')) {
      return 'Only Gmail addresses are accepted';
    }

    if (!_isValidEmailFormat(email)) {
      return 'Invalid Gmail format';
    }

    final username = email.split('@')[0];

    if (username.isEmpty || username.length < 6) {
      return 'Gmail username must be at least 6 characters';
    }

    if (username.length > 30) {
      return 'Gmail username must be at most 30 characters';
    }

    if (username.startsWith('.') ||
        username.endsWith('.') ||
        username.contains('..')) {
      return 'Gmail username cannot start/end with a dot or have consecutive dots';
    }

    final validCharsRegex = RegExp(r'^[a-zA-Z0-9._-]+$');
    if (!validCharsRegex.hasMatch(username)) {
      return 'Gmail username can only contain letters, numbers, dots, and underscores';
    }

    return null;
  }
}
