import 'dart:convert';

import 'package:http/http.dart' as http;
import '../api_config.dart';

class PromoService {
  static const String baseUrl = '$apiBaseUrl/promo-codes';

  // Create a new promo code
  static Future<Map<String, dynamic>?> createPromoCode(
      Map<String, dynamic> promoData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(promoData),
    );
    return _handleResponse(response);
  }

  // Get all promo codes
  static Future<List<dynamic>?> getAllPromoCodes() async {
    final response = await http.get(Uri.parse(baseUrl));
    return _handleResponse(response);
  }

  // Get promo code by ID
  static Future<Map<String, dynamic>?> getPromoCodeById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));
    return _handleResponse(response);
  }

  // Get promo code by code
  static Future<Map<String, dynamic>?> getPromoCodeByCode(String code) async {
    final response = await http.get(Uri.parse("$baseUrl/code/$code"));
    return _handleResponse(response);
  }

  // Update a promo code
  static Future<Map<String, dynamic>?> updatePromoCode(
      String id, Map<String, dynamic> promoData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(promoData),
    );
    return _handleResponse(response);
  }

  // Delete a promo code
  static Future<Map<String, dynamic>?> deletePromoCode(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));
    return _handleResponse(response);
  }

  // Apply a promo code
  static Future<Map<String, dynamic>?> applyPromoCode(
      String userId, String code) async {
    final response = await http.post(
      Uri.parse("$baseUrl/apply"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'code': code}),
    );
    return _handleResponse(response);
  }

  // Handle API response
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {'error': jsonDecode(response.body)['error'] ?? 'Unknown error'};
    }
  }
}
