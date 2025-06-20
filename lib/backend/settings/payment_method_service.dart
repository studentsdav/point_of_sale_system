import 'dart:convert';

import 'package:http/http.dart' as http;
import '../api_config.dart';

class PaymentMethodService {
  final String baseUrl = '$apiBaseUrl/payment-methods';

  Future<Map<String, dynamic>?> addPaymentMethod(
      String methodName, String description) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'method_name': methodName,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      print("Error adding payment method: ${response.body}");
      return null;
    }
  }

  Future<List<dynamic>?> getAllPaymentMethods() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error fetching payment methods: ${response.body}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPaymentMethodById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error fetching payment method: ${response.body}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> updatePaymentMethod(
      String id, String methodName, String description) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'method_name': methodName,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error updating payment method: ${response.body}");
      return null;
    }
  }

  Future<bool> deletePaymentMethod(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));
    if (response.statusCode == 200) {
      return true;
    } else {
      print("Error deleting payment method: ${response.body}");
      return false;
    }
  }
}
