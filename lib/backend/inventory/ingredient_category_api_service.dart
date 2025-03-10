import 'dart:convert';

import 'package:http/http.dart' as http;

class IngredientCategoryApiService {
  final String baseUrl =
      "http://your-api-url.com/ingredient-categories"; // Replace with actual API URL

  // Get all ingredient categories
  Future<List<dynamic>> getAllCategories() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch ingredient categories");
    }
  }

  // Get a single ingredient category by ID
  Future<Map<String, dynamic>> getCategoryById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Category not found");
    } else {
      throw Exception("Failed to fetch ingredient category");
    }
  }

  // Create a new ingredient category
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
      throw Exception("Failed to create ingredient category: ${response.body}");
    }
  }

  // Update an existing ingredient category
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
      throw Exception("Category not found");
    } else {
      throw Exception("Failed to update ingredient category");
    }
  }

  // Delete an ingredient category
  Future<void> deleteCategory(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete ingredient category");
    }
  }
}
