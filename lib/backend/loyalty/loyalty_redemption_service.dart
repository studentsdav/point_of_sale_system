import 'dart:convert';

import 'package:http/http.dart' as http;
import '../api_config.dart';

class LoyaltyRedemptionService {
  final String baseUrl = '$apiBaseUrl/redemption-limits';

  // Create a new redemption limit
  Future<Map<String, dynamic>> createRedemptionLimit(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create redemption limit: ${response.body}");
    }
  }

  // Get all redemption limits
  Future<List<dynamic>> getAllRedemptionLimits() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch redemption limits");
    }
  }

  // Get redemption limit by program ID
  Future<Map<String, dynamic>> getRedemptionLimitByProgram(
      String programId) async {
    final response = await http.get(Uri.parse("$baseUrl/program/$programId"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("No redemption limits found for this program");
    } else {
      throw Exception("Failed to fetch redemption limit");
    }
  }

  // Update a redemption limit by ID
  Future<Map<String, dynamic>> updateRedemptionLimit(
      String limitId, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$limitId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Redemption limit not found");
    } else {
      throw Exception("Failed to update redemption limit");
    }
  }

  // Delete a redemption limit by ID
  Future<void> deleteRedemptionLimit(String limitId) async {
    final response = await http.delete(Uri.parse("$baseUrl/$limitId"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete redemption limit");
    }
  }
}
