import 'dart:convert';

import 'package:http/http.dart' as http;

class LoyaltyProgramApiService {
  final String baseUrl =
      "http://your-api-url.com/loyalty-programs"; // Replace with your actual API URL

  // Get all loyalty programs
  Future<List<dynamic>> getAllLoyaltyPrograms() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch loyalty programs");
    }
  }

  // Get a single loyalty program by ID
  Future<Map<String, dynamic>> getLoyaltyProgramById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Loyalty program not found");
    } else {
      throw Exception("Failed to fetch loyalty program");
    }
  }

  // Create a new loyalty program
  Future<Map<String, dynamic>> createLoyaltyProgram(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create loyalty program: ${response.body}");
    }
  }

  // Search loyalty programs by name or tier
  Future<List<dynamic>> searchLoyaltyPrograms(String query) async {
    final response = await http.post(
      Uri.parse("$baseUrl/search"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"query": query}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("No loyalty programs found");
    } else {
      throw Exception("Failed to search loyalty programs");
    }
  }

  // Update an existing loyalty program
  Future<Map<String, dynamic>> updateLoyaltyProgram(
      String id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Loyalty program not found");
    } else {
      throw Exception("Failed to update loyalty program");
    }
  }

  // Delete a loyalty program
  Future<void> deleteLoyaltyProgram(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete loyalty program");
    }
  }
}
