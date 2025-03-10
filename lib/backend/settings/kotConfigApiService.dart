import 'dart:convert';
import 'package:http/http.dart' as http;

class KOTConfigApiService {
  final String baseUrl;

  KOTConfigApiService({required this.baseUrl});

  // 1. Create a new KOT configuration
  Future<Map<String, dynamic>> createKOTConfig(
      Map<String, dynamic> kotConfigData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/kotconfigs'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(kotConfigData),
    );

    if (response.statusCode == 201) {
      return json.decode(
          response.body); // Returning the newly created KOT configuration
    } else {
      throw Exception('Failed to create KOT configuration: ${response.body}');
    }
  }

  // 2. Get all KOT configurations
  Future<List<Map<String, dynamic>>> getKOTConfigs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/kotconfigs'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(
          data); // Returning all KOT configurations as a list
    } else {
      throw Exception('Failed to fetch KOT configurations: ${response.body}');
    }
  }

  // 3. Get KOT configuration by ID
  Future<Map<String, dynamic>> getKOTConfigById(String kotConfigId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/kotconfigs/$kotConfigId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json
          .decode(response.body); // Returning the KOT configuration by ID
    } else if (response.statusCode == 404) {
      throw Exception('KOT configuration not found');
    } else {
      throw Exception('Failed to fetch KOT configuration: ${response.body}');
    }
  }

  // 4. Update KOT configuration by ID
  Future<Map<String, dynamic>> updateKOTConfig(
      String kotConfigId, Map<String, dynamic> kotConfigData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/kotconfigs/$kotConfigId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(kotConfigData),
    );

    if (response.statusCode == 200) {
      return json.decode(
          response.body); // Returning the updated KOT configuration data
    } else if (response.statusCode == 404) {
      throw Exception('KOT configuration not found');
    } else {
      throw Exception('Failed to update KOT configuration: ${response.body}');
    }
  }

  // 5. Delete KOT configuration by ID
  Future<void> deleteKOTConfig(String kotConfigId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/kotconfigs/$kotConfigId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 204) {
      // Successfully deleted, no content returned
      return;
    } else if (response.statusCode == 404) {
      throw Exception('KOT configuration not found');
    } else {
      throw Exception('Failed to delete KOT configuration: ${response.body}');
    }
  }
}
