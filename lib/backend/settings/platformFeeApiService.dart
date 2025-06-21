import 'dart:convert';

import 'package:http/http.dart' as http;
import '../api_config.dart';

class PlatformFeeApiService {
  final String baseUrl;

  PlatformFeeApiService({String? baseUrl}) : baseUrl = baseUrl ?? apiBaseUrl;

  // 1. Get all platform fee configurations
  Future<List<Map<String, dynamic>>> getPlatformFees() async {
    final response = await http.get(
      Uri.parse('$baseUrl/platformfees'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception(
          'Failed to retrieve platform fee configurations: ${response.body}');
    }
  }

  // 2. Get platform fee configuration by ID
  Future<Map<String, dynamic>> getPlatformFeeById(String feeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/platformfees/$feeId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Platform fee configuration not found');
    } else {
      throw Exception('Failed to retrieve platform fee: ${response.body}');
    }
  }

  // 3. Create a new platform fee configuration
  Future<Map<String, dynamic>> createPlatformFee(
      Map<String, dynamic> feeData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/platformfees'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(feeData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to create platform fee configuration: ${response.body}');
    }
  }

  // 4. Update platform fee configuration by ID
  Future<Map<String, dynamic>> updatePlatformFee(
      String feeId, Map<String, dynamic> feeData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/platformfees/$feeId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(feeData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Platform fee configuration not found');
    } else {
      throw Exception(
          'Failed to update platform fee configuration: ${response.body}');
    }
  }

  // 5. Delete platform fee configuration by ID
  Future<void> deletePlatformFee(String feeId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/platformfees/$feeId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Platform fee configuration not found');
    } else {
      throw Exception(
          'Failed to delete platform fee configuration: ${response.body}');
    }
  }
}
