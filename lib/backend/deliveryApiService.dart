import 'dart:convert';

import 'package:http/http.dart' as http;

class DeliveryApiService {
  final String baseUrl;

  DeliveryApiService({required this.baseUrl});

  // 1. Get all delivery charge configurations
  Future<List<Map<String, dynamic>>> getDeliveryCharges() async {
    final response = await http.get(
      Uri.parse('$baseUrl/deliverycharges'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception('Failed to retrieve delivery charges: ${response.body}');
    }
  }

  // 2. Get delivery charge configuration by ID
  Future<Map<String, dynamic>> getDeliveryChargeById(String chargeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/deliverycharges/$chargeId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Delivery charge configuration not found');
    } else {
      throw Exception('Failed to retrieve delivery charge: ${response.body}');
    }
  }

  // 3. Create a new delivery charge configuration
  Future<Map<String, dynamic>> createDeliveryCharge(
      Map<String, dynamic> chargeData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/deliverycharges'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(chargeData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to create delivery charge configuration: ${response.body}');
    }
  }

  // 4. Update delivery charge configuration by ID
  Future<Map<String, dynamic>> updateDeliveryCharge(
      String chargeId, Map<String, dynamic> chargeData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/deliverycharges/$chargeId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(chargeData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Delivery charge configuration not found');
    } else {
      throw Exception(
          'Failed to update delivery charge configuration: ${response.body}');
    }
  }

  // 5. Delete delivery charge configuration by ID
  Future<void> deleteDeliveryCharge(String chargeId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/deliverycharges/$chargeId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Delivery charge configuration not found');
    } else {
      throw Exception(
          'Failed to delete delivery charge configuration: ${response.body}');
    }
  }
}
