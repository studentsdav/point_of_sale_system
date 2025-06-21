import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class HappyHourApiService {
  final String baseUrl;

  HappyHourApiService({String? baseUrl}) : baseUrl = baseUrl ?? apiBaseUrl;

  // 1. Create a new happy hour configuration
  Future<Map<String, dynamic>> createHappyHourConfig(Map<String, dynamic> happyHourData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/happy-hour-config'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(happyHourData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body); // Returning the newly created happy hour config
    } else {
      throw Exception('Failed to create happy hour config: ${response.body}');
    }
  }

  // 2. Get all happy hour configurations
  Future<List<Map<String, dynamic>>> getHappyHourConfigs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/happy-hour-config'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data); // Returning all happy hour configs as a list
    } else {
      throw Exception('Failed to fetch happy hour configs: ${response.body}');
    }
  }

  // 3. Get happy hour configuration by ID
  Future<Map<String, dynamic>> getHappyHourConfigById(String configId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/happy-hour-config/$configId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the happy hour config by ID
    } else if (response.statusCode == 404) {
      throw Exception('Happy hour config not found');
    } else {
      throw Exception('Failed to fetch happy hour config: ${response.body}');
    }
  }

  // 4. Update happy hour configuration by ID
  Future<Map<String, dynamic>> updateHappyHourConfig(String configId, Map<String, dynamic> happyHourData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/happy-hour-config/$configId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(happyHourData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the updated happy hour config data
    } else if (response.statusCode == 404) {
      throw Exception('Happy hour config not found');
    } else {
      throw Exception('Failed to update happy hour config: ${response.body}');
    }
  }

  // 5. Delete happy hour configuration by ID
  Future<void> deleteHappyHourConfig(String configId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/happy-hour-config/$configId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 204) {
      // Successfully deleted, no content returned
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Happy hour config not found');
    } else {
      throw Exception('Failed to delete happy hour config: ${response.body}');
    }
  }
}
