import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderApiService {
  final String baseUrl;

  OrderApiService({required this.baseUrl});

  // 1. Create Order
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(orderData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body); // Returning the response with order details
    } else {
      throw Exception('Failed to create order: ${response.body}');
    }
  }

  // 2. Update Order
  Future<Map<String, dynamic>> updateOrder(String orderId, Map<String, dynamic> orderData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$orderId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(orderData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the response indicating update success
    } else if (response.statusCode == 404) {
      throw Exception('Order not found');
    } else {
      throw Exception('Failed to update order: ${response.body}');
    }
  }

  // 3. Delete Order
  Future<void> deleteOrder(String orderId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/orders/$orderId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Successfully deleted
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Order not found');
    } else {
      throw Exception('Failed to delete order: ${response.body}');
    }
  }

  // 4. Get Order by ID
  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/$orderId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the order and its items
    } else if (response.statusCode == 404) {
      throw Exception('Order not found');
    } else {
      throw Exception('Failed to fetch order: ${response.body}');
    }
  }
}
