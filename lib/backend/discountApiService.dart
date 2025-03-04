import 'dart:convert';

import 'package:http/http.dart' as http;

class DiscountApiService {
  final String baseUrl;

  DiscountApiService({required this.baseUrl});

  // 1. Get all discount configurations
  Future<List<Map<String, dynamic>>> getDiscountConfigurations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/discounts'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception(
          'Failed to retrieve discount configurations: ${response.body}');
    }
  }

  // 2. Get discount configuration by ID
  Future<Map<String, dynamic>> getDiscountConfigurationById(
      String configId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/discounts/$configId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Discount configuration not found');
    } else {
      throw Exception(
          'Failed to retrieve discount configuration: ${response.body}');
    }
  }

  // 3. Create a new discount configuration
  Future<Map<String, dynamic>> createDiscountConfiguration(
      Map<String, dynamic> configData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/discounts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(configData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to create discount configuration: ${response.body}');
    }
  }

  // 4. Update discount configuration by ID
  Future<Map<String, dynamic>> updateDiscountConfiguration(
      String configId, Map<String, dynamic> configData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/discounts/$configId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(configData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Discount configuration not found');
    } else {
      throw Exception(
          'Failed to update discount configuration: ${response.body}');
    }
  }

  // 5. Delete discount configuration by ID
  Future<void> deleteDiscountConfiguration(String configId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/discounts/$configId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Discount configuration not found');
    } else {
      throw Exception(
          'Failed to delete discount configuration: ${response.body}');
    }
  }
}
