import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentApiService {
  final String baseUrl;

  PaymentApiService({required this.baseUrl});

  // 1. Get all payments
  Future<List<Map<String, dynamic>>> getPayments() async {
    final response = await http.get(
      Uri.parse('$baseUrl/payment'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception('Failed to retrieve payments: ${response.body}');
    }
  }

  // 2. Get payment by ID
  Future<Map<String, dynamic>> getPaymentById(String paymentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/payment/$paymentId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the payment details
    } else if (response.statusCode == 404) {
      throw Exception('Payment not found');
    } else {
      throw Exception('Failed to retrieve payment: ${response.body}');
    }
  }

  // 3. Create new payment
  Future<Map<String, dynamic>> createPayment(Map<String, dynamic> paymentData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payment'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(paymentData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body); // Returning the response with payment ID
    } else {
      throw Exception('Failed to create payment: ${response.body}');
    }
  }

  // 4. Update payment by ID
  Future<Map<String, dynamic>> updatePayment(String paymentId, Map<String, dynamic> paymentData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/payment/$paymentId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(paymentData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the success message
    } else if (response.statusCode == 404) {
      throw Exception('Payment not found');
    } else {
      throw Exception('Failed to update payment: ${response.body}');
    }
  }

  // 5. Delete payment by ID
  Future<void> deletePayment(String paymentId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/payment/$paymentId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Successfully deleted
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Payment not found');
    } else {
      throw Exception('Failed to delete payment: ${response.body}');
    }
  }
}
