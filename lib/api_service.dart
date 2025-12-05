import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://67.202.55.228:8000';

  static Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // ---------------- LOGIN ----------------
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? 'Login failed');
    }
  }

  // ---------------- SIGN UP ----------------
  static Future<Map<String, dynamic>> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/users');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? 'Sign Up failed');
    }
  }

  // ---------------- GET CURRENT USER ----------------
  static Future<Map<String, dynamic>> getCurrentUser(String token) async {
    final url = Uri.parse('$baseUrl/users');
    final headers = _headers(token);

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Token may be invalid or expired.');
    } else {
      throw Exception('Failed to load user: ${response.statusCode}');
    }
  }

  // ---------------- DELETE ACCOUNT ----------------
  static Future<void> deleteUser(String token) async {
    final url = Uri.parse('$baseUrl/users');
    final headers = _headers(token);

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Success - user deleted
        print('Account deleted successfully');
        return;
      } else if (response.statusCode == 401) {
        // Try to extract error message
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            final errorMessage =
                errorData['detail'] ?? 'Token validation failed';
            throw Exception(errorMessage);
          } catch (e) {
            throw Exception('Unauthorized: Token may be invalid or expired.');
          }
        } else {
          throw Exception('Unauthorized: Token may be invalid or expired.');
        }
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        // Try to extract error message
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            final errorMessage =
                errorData['detail'] ??
                errorData['message'] ??
                'Failed to delete account';
            throw Exception(errorMessage);
          } catch (e) {
            throw Exception(response.body);
          }
        } else {
          throw Exception('Failed to delete account: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // ---------------- UPLOAD DOCUMENT ----------------
  static Future<Map<String, dynamic>> uploadDocument({
    required String token,
    required String title,
    required List<http.MultipartFile> images,
  }) async {
    final url = Uri.parse('$baseUrl/documents/upload-document/');

    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['title'] = title
      ..files.addAll(images);

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseData);
    } else {
      throw Exception(
        jsonDecode(responseData)['detail'] ?? 'Document upload failed',
      );
    }
  }

  // ---------------- GET USER DOCUMENTS ----------------
  static Future<List<dynamic>> getMyDocuments(String token) async {
    final url = Uri.parse('$baseUrl/documents/my-documents/');
    final response = await http.get(url, headers: _headers(token));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['documents'] ?? [];
    } else {
      throw Exception('Failed to load documents');
    }
  }

  // ---------------- GET DOCUMENT BY QR ----------------
  static Future<Map<String, dynamic>> getDocumentFromQr(
    String token,
    int documentId,
  ) async {
    final url = Uri.parse('$baseUrl/documents/download/$documentId');
    final response = await http.get(url, headers: _headers(token));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Document not found');
    }
  }
}
