import 'dart:convert';

import 'package:http/http.dart' as http;
import '../api_config.dart';

class VendorPaymentService {
  final String baseUrl;

  VendorPaymentService({String? baseUrl}) : baseUrl = baseUrl ?? apiBaseUrl;

  // Get all vendor payments
  Future<List<dynamic>> getAllVendorPayments() async {
    final response = await http.get(Uri.parse('$baseUrl/vendor-payments'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load vendor payments');
    }
  }

  // Get a single vendor payment by ID
  Future<Map<String, dynamic>> getVendorPaymentById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/vendor-payments/$id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Vendor payment not found');
    }
  }

  // Create a new vendor payment
  Future<Map<String, dynamic>> createVendorPayment(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/vendor-payments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create vendor payment');
    }
  }

  // Update an existing vendor payment
  Future<Map<String, dynamic>> updateVendorPayment(
      String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/vendor-payments/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update vendor payment');
    }
  }

  // Delete a vendor payment
  Future<void> deleteVendorPayment(String id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/vendor-payments/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete vendor payment');
    }
  }
}
