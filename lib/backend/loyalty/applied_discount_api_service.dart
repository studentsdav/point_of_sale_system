import 'dart:convert';

import 'package:http/http.dart' as http;

class AppliedDiscountApiService {
  final String baseUrl;

  AppliedDiscountApiService(this.baseUrl);

  // Fetch all applied discounts
  Future<List<dynamic>> fetchAppliedDiscounts() async {
    final response = await http.get(Uri.parse('$baseUrl/applied-discounts'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch applied discounts');
    }
  }

  // Fetch applied discount by ID
  Future<Map<String, dynamic>> fetchAppliedDiscountById(int id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/applied-discounts/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch applied discount');
    }
  }

  // Fetch applied discounts for a specific order
  Future<List<dynamic>> fetchAppliedDiscountsByOrder(int orderId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/applied-discounts/order/$orderId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch applied discounts for order');
    }
  }

  // Apply a discount (Create new applied discount)
  Future<Map<String, dynamic>> applyDiscount(
      Map<String, dynamic> discount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/applied-discounts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(discount),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to apply discount');
    }
  }

  // Delete an applied discount
  Future<void> deleteAppliedDiscount(int id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/applied-discounts/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete applied discount');
    }
  }
}
