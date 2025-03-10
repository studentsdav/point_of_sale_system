import 'dart:convert';

import 'package:http/http.dart' as http;

class SalaryService {
  static const String baseUrl =
      'http://your-api-url.com/salaries'; // Replace with your API URL

  // Add a new salary record
  static Future<Map<String, dynamic>?> addSalary(
      Map<String, dynamic> salaryData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(salaryData),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // Get all salary records
  static Future<List<dynamic>> getAllSalaries() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  // Get salary record by ID
  static Future<Map<String, dynamic>?> getSalaryById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // Get salary records for a specific employee
  static Future<List<dynamic>> getSalariesByEmployeeId(
      String employeeId) async {
    final response = await http.get(Uri.parse('$baseUrl/employee/$employeeId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  // Update a salary record
  static Future<Map<String, dynamic>?> updateSalary(
      String id, Map<String, dynamic> salaryData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(salaryData),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // Delete a salary record
  static Future<bool> deleteSalary(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 200;
  }
}
