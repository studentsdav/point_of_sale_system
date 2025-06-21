import 'dart:convert';

import 'package:http/http.dart' as http;
import '../api_config.dart';

class OrderApiService {
  final String baseUrl;

  OrderApiService({String? baseUrl}) : baseUrl = baseUrl ?? apiBaseUrl;

  // 1. Create Order
  Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> orderData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(orderData),
    );

    if (response.statusCode == 201) {
      return json
          .decode(response.body); // Returning the response with order details
    } else {
      throw Exception('Failed to create order: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getMaxOrderNo(outlet) async {
    final response =
        await http.get(Uri.parse('$baseUrl/orders/max-order-number/$outlet'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch configurations');
    }
  }

  // 2. Update Order
  Future<Map<dynamic, dynamic>> updateOrder(
      String orderId, Map<String, dynamic> orderData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$orderId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(orderData),
    );

    if (response.statusCode == 200) {
      return json.decode(
          response.body); // Returning the response indicating update success
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

// Fetch orders by table number and status
  Future<List<Map<String, dynamic>>> getOrdersByTableAndStatus(
      String tableNo, String status) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/$tableNo/$status'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> ordersJson =
          json.decode(response.body); // Assuming response is an array
      return List<Map<String, dynamic>>.from(
          ordersJson); // Convert to List<Map<String, dynamic>>
    } else if (response.statusCode == 404) {
      throw Exception('No orders found for the specified table and status');
    } else {
      throw Exception('Failed to fetch orders: ${response.body}');
    }
  }

  // Fetch orders by table number and status
  Future<List<Map<String, dynamic>>> getOrdersByStatus(String status) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/table/$status'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> ordersJson =
          json.decode(response.body); // Assuming response is an array
      return List<Map<String, dynamic>>.from(
          ordersJson); // Convert to List<Map<String, dynamic>>
    } else if (response.statusCode == 404) {
      throw Exception('No orders found for the specified table and status');
    } else {
      throw Exception('Failed to fetch orders: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getOrdersBybillid(String billid) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/bills/$billid'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> ordersJson =
          json.decode(response.body); // Assuming response is an array
      return List<Map<String, dynamic>>.from(
          ordersJson); // Convert to List<Map<String, dynamic>>
    } else if (response.statusCode == 404) {
      throw Exception('No orders found for the specified table and status');
    } else {
      throw Exception('Failed to fetch orders: ${response.body}');
    }
  }

// Fetch order items by order IDs
  Future<List<Map<String, dynamic>>> getOrderItemsByIds(
      List<String> orderIds) async {
    // Join the list of orderIds into a comma-separated string
    final orderIdsString = orderIds.join(',');

    final response = await http.get(
      Uri.parse('$baseUrl/orders/orderitem?orderIds=$orderIdsString'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Assuming the response body is a list of order items
      List<dynamic> itemsJson = json.decode(response.body);

      return List<Map<String, dynamic>>.from(
          itemsJson); // Convert to List<Map<String, dynamic>>
    } else if (response.statusCode == 404) {
      throw Exception('No items found for the specified order IDs');
    } else {
      throw Exception('Failed to fetch order items: ${response.body}');
    }
  }
}
