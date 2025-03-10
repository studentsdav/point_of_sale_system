import 'dart:convert';

import 'package:http/http.dart' as http;

class PurchaseItemService {
  final String baseUrl;

  PurchaseItemService(this.baseUrl);

  Future<List<dynamic>> getAllPurchaseItems() async {
    final response = await http.get(Uri.parse('$baseUrl/purchase-items'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load purchase items');
    }
  }

  Future<Map<String, dynamic>> getPurchaseItemById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/purchase-items/$id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Purchase item not found');
    }
  }

  Future<List<dynamic>> getPurchaseItemsByPurchaseId(String purchaseId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/purchase-items/purchase/$purchaseId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('No items found for this purchase');
    }
  }

  Future<Map<String, dynamic>> createPurchaseItem(
      Map<String, dynamic> itemData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/purchase-items'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(itemData),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error creating purchase item');
    }
  }

  Future<Map<String, dynamic>> updatePurchaseItem(
      String id, Map<String, dynamic> itemData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/purchase-items/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(itemData),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error updating purchase item');
    }
  }

  Future<void> deletePurchaseItem(String id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/purchase-items/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error deleting purchase item');
    }
  }
}
