import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class InventoryApiService {
  final String baseUrl;

  InventoryApiService({String? baseUrl}) : baseUrl = baseUrl ?? apiBaseUrl;

  // 1. Create a new inventory transaction
  Future<Map<String, dynamic>> createInventoryTransaction(Map<String, dynamic> inventoryData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/inventory'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(inventoryData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body); // Returning the newly created inventory transaction
    } else {
      throw Exception('Failed to create inventory transaction: ${response.body}');
    }
  }

  // 2. Get all inventory transactions
  Future<List<Map<String, dynamic>>> getInventoryTransactions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/inventory'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data); // Returning all inventory transactions as a list
    } else {
      throw Exception('Failed to fetch inventory transactions: ${response.body}');
    }
  }

  // 3. Get inventory transaction by ID
  Future<Map<String, dynamic>> getInventoryTransactionById(String transactionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/inventory/$transactionId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the inventory transaction by ID
    } else if (response.statusCode == 404) {
      throw Exception('Inventory transaction not found');
    } else {
      throw Exception('Failed to fetch inventory transaction: ${response.body}');
    }
  }

  // 4. Update inventory transaction by ID
  Future<Map<String, dynamic>> updateInventoryTransaction(String transactionId, Map<String, dynamic> inventoryData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/inventory/$transactionId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(inventoryData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the updated inventory transaction data
    } else if (response.statusCode == 404) {
      throw Exception('Inventory transaction not found');
    } else {
      throw Exception('Failed to update inventory transaction: ${response.body}');
    }
  }

  // 5. Delete inventory transaction by ID
  Future<void> deleteInventoryTransaction(String transactionId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/inventory/$transactionId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 204) {
      // Successfully deleted, no content returned
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Inventory transaction not found');
    } else {
      throw Exception('Failed to delete inventory transaction: ${response.body}');
    }
  }
}
