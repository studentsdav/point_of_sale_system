import 'dart:convert';
import 'package:http/http.dart' as http;

class TaxConfigApiService {
  final String baseUrl;

  TaxConfigApiService({required this.baseUrl});

  // 1. Get Tax Configuration by ID
  Future<Map<String, dynamic>> getTaxConfigById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/taxconfig/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the tax configuration data
    } else if (response.statusCode == 404) {
      throw Exception('Tax configuration not found');
    } else {
      throw Exception('Failed to retrieve tax configuration: ${response.body}');
    }
  }

  // 2. Get all Tax Configurations
  Future<List<Map<String, dynamic>>> getAllTaxConfigs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/taxconfig'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception('Failed to retrieve tax configurations: ${response.body}');
    }
  }

  // 3. Create a New Tax Configuration
  Future<Map<String, dynamic>> createTaxConfig(Map<String, dynamic> taxConfigData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/taxconfig'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(taxConfigData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body); // Returning the created tax configuration data
    } else {
      throw Exception('Failed to create tax configuration: ${response.body}');
    }
  }

  // 4. Update an Existing Tax Configuration
  Future<Map<String, dynamic>> updateTaxConfig(String id, Map<String, dynamic> taxConfigData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/taxconfig/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(taxConfigData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the updated tax configuration data
    } else if (response.statusCode == 404) {
      throw Exception('Tax configuration not found');
    } else {
      throw Exception('Failed to update tax configuration: ${response.body}');
    }
  }

  // 5. Delete a Tax Configuration by ID
  Future<void> deleteTaxConfig(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/taxconfig/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Successfully deleted
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Tax configuration not found');
    } else {
      throw Exception('Failed to delete tax configuration: ${response.body}');
    }
  }
}
