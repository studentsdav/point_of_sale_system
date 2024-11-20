import 'dart:convert';
import 'package:http/http.dart' as http;

class BillApiService {
  final String baseUrl;

  BillApiService({required this.baseUrl});

  // 1. GET: Fetch Bill Details by Order ID
  Future<Map<String, dynamic>> getBill(String orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$orderId/bill'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the response JSON as a Map
    } else if (response.statusCode == 404) {
      throw Exception('Order not found');
    } else {
      throw Exception('Failed to fetch bill: ${response.body}');
    }
  }

  // 2. PUT: Edit Bill (Update Bill Details)
  Future<Map<String, dynamic>> editBill(String orderId, Map<String, dynamic> billData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$orderId/edit-bill'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(billData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the success message
    } else if (response.statusCode == 404) {
      throw Exception('Order not found');
    } else {
      throw Exception('Failed to edit bill: ${response.body}');
    }
  }

  // 3. PUT: Generate Bill (Mark Order as Completed and Update Bill Number)
  Future<Map<String, dynamic>> generateBill(String orderId, String billNumber, String cashier) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$orderId/generate-bill'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'bill_number': billNumber,
        'cashier': cashier,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the success message
    } else if (response.statusCode == 404) {
      throw Exception('Order not found');
    } else {
      throw Exception('Failed to generate bill: ${response.body}');
    }
  }

  // 4. DELETE: Delete Bill (Delete Order and Associated Items)
  Future<Map<String, dynamic>> deleteBill(String orderId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$orderId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the success message
    } else if (response.statusCode == 404) {
      throw Exception('Order not found');
    } else {
      throw Exception('Failed to delete order and items: ${response.body}');
    }
  }
}
