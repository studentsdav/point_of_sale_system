import 'dart:convert';

import 'package:http/http.dart' as http;
import '../api_config.dart';

class ExpenseSubcategoryApiService {
  final String baseUrl = '$apiBaseUrl/expense-subcategories';

  // Add a new expense subcategory
  Future<Map<String, dynamic>> addSubcategory(
      Map<String, dynamic> subcategoryData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(subcategoryData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to add expense subcategory: ${response.body}");
    }
  }

  // Get all expense subcategories
  Future<List<dynamic>> getAllSubcategories() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch expense subcategories");
    }
  }

  // Get subcategories by category ID
  Future<List<dynamic>> getSubcategoriesByCategory(String categoryId) async {
    final response = await http.get(Uri.parse("$baseUrl/category/$categoryId"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch subcategories for category $categoryId");
    }
  }

  // Get expense subcategory by ID
  Future<Map<String, dynamic>> getSubcategoryById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Subcategory not found");
    } else {
      throw Exception("Failed to fetch expense subcategory");
    }
  }

  // Update an expense subcategory
  Future<Map<String, dynamic>> updateSubcategory(
      String id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Subcategory not found");
    } else {
      throw Exception("Failed to update expense subcategory");
    }
  }

  // Delete an expense subcategory
  Future<void> deleteSubcategory(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete expense subcategory");
    }
  }
}
