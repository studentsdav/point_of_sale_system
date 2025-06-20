import 'dart:convert';

import 'package:http/http.dart' as http;
import '../api_config.dart';

class IngredientSubcategoryApiService {
  final String baseUrl = '$apiBaseUrl/ingredient-subcategories';

  // Get all ingredient subcategories
  Future<List<dynamic>> getAllSubcategories() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch ingredient subcategories");
    }
  }

  // Get a single ingredient subcategory by ID
  Future<Map<String, dynamic>> getSubcategoryById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Subcategory not found");
    } else {
      throw Exception("Failed to fetch ingredient subcategory");
    }
  }

  // Create a new ingredient subcategory
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
      throw Exception(
          "Failed to create ingredient subcategory: ${response.body}");
    }
  }

  // Update an existing ingredient subcategory
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
      throw Exception("Failed to update ingredient subcategory");
    }
  }

  // Delete an ingredient subcategory
  Future<void> deleteSubcategory(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete ingredient subcategory");
    }
  }
}
