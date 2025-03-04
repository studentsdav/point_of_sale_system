import 'dart:convert';

import 'package:http/http.dart' as http;

class PackingChargeApiService {
  final String baseUrl;

  PackingChargeApiService({required this.baseUrl});

  // 1. Get all Packing Charge configurations
  Future<List<Map<String, dynamic>>> getPackingChargeConfigurations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/packingcharge'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception(
          'Failed to retrieve Packing Charge configurations: ${response.body}');
    }
  }

  // 2. Get Packing Charge configuration by ID
  Future<Map<String, dynamic>> getPackingChargeConfigurationById(
      String configId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/packingcharge/$configId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json
          .decode(response.body); // Returning the Packing Charge configuration
    } else if (response.statusCode == 404) {
      throw Exception('Packing Charge configuration not found');
    } else {
      throw Exception(
          'Failed to retrieve Packing Charge configuration: ${response.body}');
    }
  }

  // 3. Create a new Packing Charge configuration
  Future<Map<String, dynamic>> createPackingChargeConfiguration(
      Map<String, dynamic> configData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/packingcharge'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(configData),
    );

    if (response.statusCode == 201) {
      return json.decode(response
          .body); // Returning the response with Packing Charge config ID
    } else {
      throw Exception(
          'Failed to create Packing Charge configuration: ${response.body}');
    }
  }

  // 4. Update Packing Charge configuration by ID
  Future<Map<String, dynamic>> updatePackingChargeConfiguration(
      String configId, Map<String, dynamic> configData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/packingcharge/$configId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(configData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the success message
    } else if (response.statusCode == 404) {
      throw Exception('Packing Charge configuration not found');
    } else {
      throw Exception(
          'Failed to update Packing Charge configuration: ${response.body}');
    }
  }

  // 5. Delete Packing Charge configuration by ID
  Future<void> deletePackingChargeConfiguration(String configId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/packingcharge/$configId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Successfully deleted
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Packing Charge configuration not found');
    } else {
      throw Exception(
          'Failed to delete Packing Charge configuration: ${response.body}');
    }
  }
}
