import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class CategoryApiService {
  final String baseUrl;

  CategoryApiService({String? baseUrl}) : baseUrl = baseUrl ?? apiBaseUrl;

  // 1. Create a new category
  Future<Map<String, dynamic>> createCategory(
      Map<String, dynamic> categoryData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(categoryData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body); // Returning the newly created category
    } else {
      throw Exception('Failed to create category: ${response.body}');
    }
  }

  // 2. Get all categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(
          data); // Returning all categories as a list
    } else {
      throw Exception('Failed to fetch categories: ${response.body}');
    }
  }

  // 3. Get category by ID
  Future<Map<String, dynamic>> getCategoryById(String categoryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories/$categoryId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the category data by ID
    } else if (response.statusCode == 404) {
      throw Exception('Category not found');
    } else {
      throw Exception('Failed to fetch category: ${response.body}');
    }
  }

  // 4. Update category by ID
  Future<Map<String, dynamic>> updateCategory(
      String categoryId, Map<String, dynamic> categoryData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/categories/$categoryId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(categoryData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the updated category data
    } else if (response.statusCode == 404) {
      throw Exception('Category not found');
    } else {
      throw Exception('Failed to update category: ${response.body}');
    }
  }

  // 5. Delete category by ID
  Future<void> deleteCategory(String categoryId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/categories/$categoryId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 204) {
      // Successfully deleted, no content returned
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Category not found');
    } else {
      throw Exception('Failed to delete category: ${response.body}');
    }
  }
}
