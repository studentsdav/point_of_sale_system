import 'dart:convert';

import 'package:http/http.dart' as http;
import '../api_config.dart';

class EarningService {
  final String baseUrl = '$apiBaseUrl/staff-earnings';

  // Add a new earning record
  Future<Map<String, dynamic>?> addEarning(
      int employeeId, String earningType, double amount, int orderId) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "employee_id": employeeId,
        "earning_type": earningType,
        "amount": amount,
        "order_id": orderId,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // Get all earnings
  Future<List<dynamic>?> getAllEarnings() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // Get earning record by ID
  Future<Map<String, dynamic>?> getEarningById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // Get earnings for a specific employee
  Future<List<dynamic>?> getEarningsByEmployee(int employeeId) async {
    final response = await http.get(Uri.parse("$baseUrl/employee/$employeeId"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // Update earning record
  Future<Map<String, dynamic>?> updateEarning(
      int id, String earningType, double amount, int orderId) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "earning_type": earningType,
        "amount": amount,
        "order_id": orderId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // Delete earning record
  Future<bool> deleteEarning(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));
    return response.statusCode == 200;
  }
}
