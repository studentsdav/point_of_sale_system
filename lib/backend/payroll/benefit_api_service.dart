import 'dart:convert';

import 'package:http/http.dart' as http;
import '../api_config.dart';

class BenefitApiService {
  final String baseUrl = '$apiBaseUrl/benefits';

  // Create a new benefit
  Future<Map<String, dynamic>> createBenefit(
      Map<String, dynamic> benefitData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(benefitData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create benefit: ${response.body}");
    }
  }

  // Get all benefits
  Future<List<dynamic>> getAllBenefits() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch benefits");
    }
  }

  // Get a specific benefit by ID
  Future<Map<String, dynamic>> getBenefitById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Benefit not found");
    } else {
      throw Exception("Failed to fetch benefit");
    }
  }

  // Get all benefits for a specific employee
  Future<List<dynamic>> getBenefitsByEmployee(String employeeId) async {
    final response = await http.get(Uri.parse("$baseUrl/employee/$employeeId"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("No benefits found for this employee");
    } else {
      throw Exception("Failed to fetch employee benefits");
    }
  }

  // Update a benefit
  Future<Map<String, dynamic>> updateBenefit(
      String id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Benefit not found");
    } else {
      throw Exception("Failed to update benefit");
    }
  }

  // Delete a benefit
  Future<void> deleteBenefit(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete benefit");
    }
  }
}
