import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class WaiterApiService {
  final String baseUrl;

  WaiterApiService({String? baseUrl}) : baseUrl = baseUrl ?? apiBaseUrl;

  // 1. Create a new waiter
  Future<Map<String, dynamic>> createWaiter(
      Map<String, dynamic> waiterData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/waiters'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(waiterData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body); // Returning the created waiter data
    } else {
      throw Exception('Failed to create waiter: ${response.body}');
    }
  }

  // 2. Update an existing waiter
  Future<Map<String, dynamic>> updateWaiter(
      String waiterId, Map<String, dynamic> waiterData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/waiters/$waiterId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(waiterData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the updated waiter data
    } else if (response.statusCode == 404) {
      throw Exception('Waiter not found');
    } else {
      throw Exception('Failed to update waiter: ${response.body}');
    }
  }

  // 3. Delete a waiter
  Future<void> deleteWaiter(String waiterId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/waiters/$waiterId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 204) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Waiter not found');
    } else {
      throw Exception('Failed to delete waiter: ${response.body}');
    }
  }

  // 4. Fetch all waiters
  Future<List<Map<String, dynamic>>> getAllWaiters() async {
    final response = await http.get(
      Uri.parse('$baseUrl/waiters'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception('Failed to fetch waiters: ${response.body}');
    }
  }

  // 5. Fetch a waiter by ID
  Future<Map<String, dynamic>> getWaiterById(String waiterId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/waiters/$waiterId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the waiter data
    } else if (response.statusCode == 404) {
      throw Exception('Waiter not found');
    } else {
      throw Exception('Failed to fetch waiter: ${response.body}');
    }
  }
}
