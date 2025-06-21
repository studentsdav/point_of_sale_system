import 'dart:convert';

import 'package:http/http.dart' as http;
import '../api_config.dart';

class StockMovementService {
  final String baseUrl;

  StockMovementService({String? baseUrl}) : baseUrl = baseUrl ?? apiBaseUrl;

  // Get all stock movements
  Future<List<dynamic>> getAllStockMovements() async {
    final response = await http.get(Uri.parse('$baseUrl/stock-movements'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load stock movements');
    }
  }

  // Get a single stock movement by ID
  Future<Map<String, dynamic>> getStockMovementById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/stock-movements/$id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Stock movement not found');
    }
  }

  // Get stock movements for a specific ingredient
  Future<List<dynamic>> getStockMovementsByIngredient(
      String ingredientId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/stock-movements/ingredient/$ingredientId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('No stock movements found for this ingredient');
    }
  }

  // Record a new stock movement
  Future<Map<String, dynamic>> addStockMovement(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/stock-movements'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error recording stock movement');
    }
  }

  // Delete a stock movement
  Future<void> deleteStockMovement(String id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/stock-movements/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error deleting stock movement');
    }
  }
}
