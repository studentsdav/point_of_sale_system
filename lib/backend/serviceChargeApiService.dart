import 'dart:convert';
import 'package:http/http.dart' as http;

class ServiceChargeApiService {
  final String baseUrl;

  ServiceChargeApiService({required this.baseUrl});

  // 1. Get all service charge configurations
  Future<List<Map<String, dynamic>>> getServiceChargeConfigurations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/servicecharge'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception('Failed to retrieve service charge configurations: ${response.body}');
    }
  }

  // 2. Get service charge configuration by ID
  Future<Map<String, dynamic>> getServiceChargeConfigurationById(String configId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/servicecharge/$configId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the service charge configuration
    } else if (response.statusCode == 404) {
      throw Exception('Service charge configuration not found');
    } else {
      throw Exception('Failed to retrieve service charge configuration: ${response.body}');
    }
  }

  // 3. Create a new service charge configuration
  Future<Map<String, dynamic>> createServiceChargeConfiguration(Map<String, dynamic> configData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/servicecharge'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(configData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body); // Returning the response with service charge config ID
    } else {
      throw Exception('Failed to create service charge configuration: ${response.body}');
    }
  }

  // 4. Update service charge configuration by ID
  Future<Map<String, dynamic>> updateServiceChargeConfiguration(String configId, Map<String, dynamic> configData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/servicecharge/$configId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(configData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the success message
    } else if (response.statusCode == 404) {
      throw Exception('Service charge configuration not found');
    } else {
      throw Exception('Failed to update service charge configuration: ${response.body}');
    }
  }

  // 5. Delete service charge configuration by ID
  Future<void> deleteServiceChargeConfiguration(String configId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/servicecharge/$configId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Successfully deleted
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Service charge configuration not found');
    } else {
      throw Exception('Failed to delete service charge configuration: ${response.body}');
    }
  }
}
