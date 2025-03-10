import 'dart:convert';

import 'package:http/http.dart' as http;

class PurchaseService {
  final String baseUrl =
      'http://your-api-url.com'; // Replace with your actual API URL

  Future<List<dynamic>> getAllPurchases() async {
    final response = await http.get(Uri.parse('$baseUrl/purchases'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load purchases');
    }
  }

  Future<Map<String, dynamic>> getPurchaseById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/purchases/$id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Purchase not found');
    }
  }

  Future<Map<String, dynamic>> createPurchase(
      Map<String, dynamic> purchaseData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/purchases'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(purchaseData),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error creating purchase');
    }
  }

  Future<Map<String, dynamic>> updatePurchase(
      int id, Map<String, dynamic> purchaseData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/purchases/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(purchaseData),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error updating purchase');
    }
  }

  Future<void> deletePurchase(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/purchases/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error deleting purchase');
    }
  }
}
