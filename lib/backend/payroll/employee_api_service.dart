import 'dart:convert';

import 'package:http/http.dart' as http;

class EmployeeApiService {
  final String baseUrl =
      "http://your-api-url.com/employees"; // Replace with actual API URL

  // Create Employee
  Future<Map<String, dynamic>> createEmployee(
      Map<String, dynamic> employeeData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(employeeData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create employee: ${response.body}");
    }
  }

  // Get All Employees
  Future<List<dynamic>> getAllEmployees() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch employees");
    }
  }

  // Update Employee
  Future<Map<String, dynamic>> updateEmployee(
      String id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Employee not found");
    } else {
      throw Exception("Failed to update employee");
    }
  }

  // Delete Employee
  Future<void> deleteEmployee(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete employee");
    }
  }
}
