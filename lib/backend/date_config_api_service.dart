import 'dart:convert';
import 'package:http/http.dart' as http;

class DateConfigApiService {
  final String baseUrl;

  DateConfigApiService({required this.baseUrl});

  // 1. Create a new date configuration
  Future<Map<String, dynamic>> createDateConfig(Map<String, dynamic> dateConfigData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/date_config'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(dateConfigData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body); // Returning the newly created date config
    } else {
      throw Exception('Failed to create date configuration: ${response.body}');
    }
  }

  // 2. Get all date configurations
  Future<List<Map<String, dynamic>>> getDateConfigs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/date_config'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data); // Returning all date configurations as a list
    } else {
      throw Exception('Failed to fetch date configurations: ${response.body}');
    }
  }

  // 3. Get date configuration by ID
  Future<Map<String, dynamic>> getDateConfigById(String dateConfigId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/date_config/$dateConfigId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the date configuration data by ID
    } else if (response.statusCode == 404) {
      throw Exception('Date configuration not found');
    } else {
      throw Exception('Failed to fetch date configuration: ${response.body}');
    }
  }

  // 4. Update date configuration by ID
  Future<Map<String, dynamic>> updateDateConfig(String dateConfigId, Map<String, dynamic> dateConfigData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/date_config/$dateConfigId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(dateConfigData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the updated date configuration data
    } else if (response.statusCode == 404) {
      throw Exception('Date configuration not found');
    } else {
      throw Exception('Failed to update date configuration: ${response.body}');
    }
  }

  // 5. Delete date configuration by ID
  Future<void> deleteDateConfig(String dateConfigId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/date_config/$dateConfigId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 204) {
      // Successfully deleted, no content returned
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Date configuration not found');
    } else {
      throw Exception('Failed to delete date configuration: ${response.body}');
    }
  }
}
