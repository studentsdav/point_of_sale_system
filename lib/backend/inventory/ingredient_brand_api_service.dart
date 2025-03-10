import 'dart:convert';

import 'package:http/http.dart' as http;

class IngredientBrandApiService {
  final String baseUrl =
      "http://your-api-url.com/ingredient-brands"; // Replace with actual API URL

  // Get all ingredient brands
  Future<List<dynamic>> getAllBrands() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch ingredient brands");
    }
  }

  // Get a single ingredient brand by ID
  Future<Map<String, dynamic>> getBrandById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Brand not found");
    } else {
      throw Exception("Failed to fetch ingredient brand");
    }
  }

  // Create a new ingredient brand
  Future<Map<String, dynamic>> addBrand(Map<String, dynamic> brandData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(brandData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create ingredient brand: ${response.body}");
    }
  }

  // Update an existing ingredient brand
  Future<Map<String, dynamic>> updateBrand(
      String id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Brand not found");
    } else {
      throw Exception("Failed to update ingredient brand");
    }
  }

  // Delete an ingredient brand
  Future<void> deleteBrand(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete ingredient brand");
    }
  }
}
