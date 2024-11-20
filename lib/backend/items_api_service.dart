import 'dart:convert';
import 'package:http/http.dart' as http;

class ItemsApiService {
  final String baseUrl; // Replace with your server URL
  ItemsApiService({required this.baseUrl});
  // Fetch all items
  Future<List<dynamic>> fetchAllItems() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/items"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch items: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching items: $e");
    }
  }

  // Fetch item by ID
  Future<Map<String, dynamic>> fetchItemById(String id) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/items/$id"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch item: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching item by ID: $e");
    }
  }

  // Create a new item
  Future<Map<String, dynamic>> createItem(Map<String, dynamic> itemData) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/items"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(itemData),
      );
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to create item: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error creating item: $e");
    }
  }

  // Update an item by ID
  Future<Map<String, dynamic>> updateItem(String id, Map<String, dynamic> itemData) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/items/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(itemData),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to update item: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error updating item: $e");
    }
  }

  // Delete an item by ID
  Future<void> deleteItem(String id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/items/$id"));
      if (response.statusCode != 204) {
        throw Exception("Failed to delete item: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error deleting item: $e");
    }
  }
}
