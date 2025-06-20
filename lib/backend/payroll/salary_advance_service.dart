import 'dart:convert';

import 'package:http/http.dart' as http;
import '../api_config.dart';

class SalaryAdvanceService {
  final String baseUrl = '$apiBaseUrl/salary-advances';

  Future<Map<String, dynamic>?> addSalaryAdvance(
      {required int employeeId,
      required double amount,
      required int paymentMethodId,
      required String advanceDate,
      required bool repaid}) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "employee_id": employeeId,
          "amount": amount,
          "payment_method_id": paymentMethodId,
          "advance_date": advanceDate,
          "repaid": repaid
        }),
      );
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Error adding salary advance: $e");
    }
    return null;
  }

  Future<List<dynamic>?> getAllSalaryAdvances() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Error fetching salary advances: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> getSalaryAdvanceById(int id) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/$id"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Error fetching salary advance: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateSalaryAdvance(
      {required int id,
      required double amount,
      required int paymentMethodId,
      required String advanceDate,
      required bool repaid}) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "amount": amount,
          "payment_method_id": paymentMethodId,
          "advance_date": advanceDate,
          "repaid": repaid
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Error updating salary advance: $e");
    }
    return null;
  }

  Future<bool> deleteSalaryAdvance(int id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/$id"));
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print("Error deleting salary advance: $e");
    }
    return false;
  }
}
