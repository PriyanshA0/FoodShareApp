import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:fwm_sys/models/donation_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // FINAL PRODUCTION BASE URL (Updated from http://10.0.2.2:3000/api)
  static const String _baseUrl = "https://foodshareapp-6ham.onrender.com/api";

  // --- PRIVATE METHOD TO RETRIEVE JWT TOKEN AND BUILD HEADERS ---
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      // Throw an exception to force re-login if the token is missing
      throw Exception('Authentication token not found. Please log in.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Standard JWT header
    };
  }

  // ----------------------------------------------------
  // AUTHENTICATION & REGISTRATION
  // ----------------------------------------------------

  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String role,
    required String name,
    String? contact,
    String? address,
    String? license,
    String? registrationNo,
    int? volunteersCount,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'), // Node.js route
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'role': role,
        'name': name,
        'contact': contact,
        'address': address,
        'license': license,
        'registrationNo': registrationNo,
        'volunteersCount': volunteersCount,
      }),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'), // Node.js route
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['token'] != null) {
        final prefs = await SharedPreferences.getInstance();

        // Save the received JWT token
        await prefs.setString('auth_token', responseData['token']);
        // Save ID and Role for application logic
        await prefs.setString('user_id', responseData['user_id'].toString());
        await prefs.setString('user_role', responseData['role'].toString());
        await prefs.setBool('is_logged_in', true);
      }
      return responseData;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_role');
    await prefs.remove('is_logged_in');
  }

  // ----------------------------------------------------
  // DONATION POSTING & FETCHING
  // ----------------------------------------------------

  Future<Map<String, dynamic>> postDonation(
    String title,
    String category,
    String quantity,
    String expiryTime,
    String pickupLocation,
    File? image,
  ) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/donations/post'); // Node.js route

    var request = http.MultipartRequest('POST', uri)
      ..fields['title'] = title
      ..fields['category'] = category
      ..fields['quantity'] = quantity
      ..fields['expiry_time'] = expiryTime
      ..fields['pickup_location'] = pickupLocation
      // Add JWT header via the map
      ..headers.addAll({'Authorization': headers['Authorization']!});

    if (image != null) {
      // The name 'image' must match the key used by Multer on the backend
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return json.decode(response.body);
  }

  Future<List<Donation>> getAllDonations() async {
    final headers = await _getAuthHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/donations/get_all'), // Node.js route
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Donation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load donations: ${response.statusCode}');
    }
  }

  Future<List<Donation>> getMyDonations() async {
    final headers = await _getAuthHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/donations/get_by_restaurant'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Donation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load your donations: ${response.statusCode}');
    }
  }

  // ----------------------------------------------------
  // NGO-SPECIFIC ACTIONS
  // ----------------------------------------------------

  Future<Map<String, dynamic>> acceptDonation(String donationId) async {
    final headers = await _getAuthHeaders();

    final response = await http.post(
      Uri.parse('$_baseUrl/donations/accept'), // Node.js route
      headers: headers,
      body: json.encode({'donation_id': donationId}),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> markInTransit(String donationId) async {
    final headers = await _getAuthHeaders();

    final response = await http.post(
      Uri.parse('$_baseUrl/donations/in_transit'), // Node.js route
      headers: headers,
      body: json.encode({'donation_id': donationId}),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> completePickup(String donationId) async {
    final headers = await _getAuthHeaders();

    final response = await http.post(
      Uri.parse('$_baseUrl/donations/complete_pickup'), // Node.js route
      headers: headers,
      body: json.encode({'donation_id': donationId}),
    );
    return json.decode(response.body);
  }

  Future<List<Donation>> getAcceptedDonations() async {
    final headers = await _getAuthHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/donations/get_accepted'), // Node.js route
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Donation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load accepted orders: ${response.statusCode}');
    }
  }

  // ----------------------------------------------------
  // DASHBOARD ANALYTICS (Phase 2 Feature)
  // ----------------------------------------------------

  Future<Map<String, dynamic>> fetchDashboardStats() async {
    final headers = await _getAuthHeaders();

    final response = await http.get(
      // Calls the new route implemented in statsController.js
      Uri.parse('$_baseUrl/stats/dashboard'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // Handle 401/403 errors separately if needed
      throw Exception('Failed to load dashboard stats: ${response.statusCode}');
    }
  }

  // ----------------------------------------------------
  // PROFILE & UTILITY
  // ----------------------------------------------------

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String contactNumber,
    required String address,
  }) async {
    final headers = await _getAuthHeaders();

    final response = await http.post(
      Uri.parse('$_baseUrl/users/update_profile'), // Node.js route
      headers: headers,
      body: json.encode({
        'name': name,
        'contact_number': contactNumber,
        'address': address,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    final headers = await _getAuthHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/users/get_profile'), // Node.js route
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user data.');
    }
  }
}
