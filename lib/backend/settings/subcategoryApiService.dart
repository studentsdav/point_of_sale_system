import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class SubcategoryApiService {
  final String baseUrl;

  SubcategoryApiService({String? baseUrl}) : baseUrl = baseUrl ?? apiBaseUrl;

  // 1. Get all subcategories
  Future<List<Map<String, dynamic>>> getSubcategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/subcategories'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception('Failed to retrieve subcategories: ${response.body}');
    }
  }

  // 2. Get subcategory by ID
  Future<Map<String, dynamic>> getSubcategoryById(String subCategoryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/subcategories/$subCategoryId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the subcategory data
    } else if (response.statusCode == 404) {
      throw Exception('Subcategory not found');
    } else {
      throw Exception('Failed to retrieve subcategory: ${response.body}');
    }
  }

  // 3. Create a new subcategory
  Future<Map<String, dynamic>> createSubcategory(
      Map<String, dynamic> subcategoryData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/subcategories'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(subcategoryData),
    );

    if (response.statusCode == 201) {
      return json
          .decode(response.body); // Returning the created subcategory data
    } else {
      throw Exception('Failed to create subcategory: ${response.body}');
    }
  }

  // 4. Update a subcategory by ID
  Future<Map<String, dynamic>> updateSubcategory(
      String subCategoryId, Map<String, dynamic> subcategoryData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/subcategories/$subCategoryId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(subcategoryData),
    );

    if (response.statusCode == 200) {
      return json
          .decode(response.body); // Returning the updated subcategory data
    } else if (response.statusCode == 404) {
      throw Exception('Subcategory not found');
    } else {
      throw Exception('Failed to update subcategory: ${response.body}');
    }
  }

  // 5. Delete a subcategory by ID
  Future<void> deleteSubcategory(String subCategoryId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/subcategories/$subCategoryId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 204) {
      // Successfully deleted
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Subcategory not found');
    } else {
      throw Exception('Failed to delete subcategory: ${response.body}');
    }
  }
}
