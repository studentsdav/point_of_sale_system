import 'dart:convert';

import 'package:http/http.dart' as http;

class RecipeService {
  static const String baseUrl = 'http://your-api-url.com';

  // Fetch all recipes
  static Future<List<dynamic>> getAllRecipes() async {
    final response = await http.get(Uri.parse('$baseUrl/recipes'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  // Fetch a single recipe by ID
  static Future<Map<String, dynamic>> getRecipeById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/recipes/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Recipe not found');
    }
  }

  // Fetch all recipes for a specific menu item
  static Future<List<dynamic>> getRecipesByMenuItem(String menuItemId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/recipes/menu-item/$menuItemId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('No recipes found for this menu item');
    }
  }

  // Create a new recipe
  static Future<Map<String, dynamic>> createRecipe(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/recipes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Error creating recipe');
    }
  }

  // Update an existing recipe
  static Future<Map<String, dynamic>> updateRecipe(
      String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/recipes/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error updating recipe');
    }
  }

  // Delete a recipe
  static Future<void> deleteRecipe(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/recipes/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error deleting recipe');
    }
  }
}
