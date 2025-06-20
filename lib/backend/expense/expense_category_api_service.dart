import 'dart:convert';

import 'package:http/http.dart' as http;
import '../api_config.dart';

class ExpenseCategoryApiService {
  final String baseUrl = '$apiBaseUrl/expense-categories';

  // Add a new expense category
  Future<Map<String, dynamic>> addCategory(
      Map<String, dynamic> categoryData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(categoryData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to add expense category: ${response.body}");
    }
  }

  // Get all expense categories
  Future<List<dynamic>> getAllCategories() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch expense categories");
    }
  }

  // Get category by ID
  Future<Map<String, dynamic>> getCategoryById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Expense category not found");
    } else {
      throw Exception("Failed to fetch expense category");
    }
  }

  // Update expense category
  Future<Map<String, dynamic>> updateCategory(
      String id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Expense category not found");
    } else {
      throw Exception("Failed to update expense category");
    }
  }

  // Delete an expense category
  Future<void> deleteCategory(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete expense category");
    }
  }
}
