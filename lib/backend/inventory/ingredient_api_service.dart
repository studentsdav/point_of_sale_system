import 'dart:convert';

import 'package:http/http.dart' as http;
import '../api_config.dart';

class IngredientApiService {
  final String baseUrl = '$apiBaseUrl/ingredients';

  // Get all ingredients
  Future<List<dynamic>> getAllIngredients() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch ingredients");
    }
  }

  // Get a single ingredient by ID
  Future<Map<String, dynamic>> getIngredientById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Ingredient not found");
    } else {
      throw Exception("Failed to fetch ingredient");
    }
  }

  // Create a new ingredient
  Future<Map<String, dynamic>> addIngredient(
      Map<String, dynamic> ingredientData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(ingredientData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create ingredient: ${response.body}");
    }
  }

  // Update an existing ingredient
  Future<Map<String, dynamic>> updateIngredient(
      String id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Ingredient not found");
    } else {
      throw Exception("Failed to update ingredient");
    }
  }

  // Delete an ingredient
  Future<void> deleteIngredient(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete ingredient");
    }
  }
}
