import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class BillingApiService {
  final String baseUrl;

  BillingApiService({String? baseUrl})
      : baseUrl = baseUrl ?? apiBaseUrl;

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

  Future<Map<String, dynamic>> getMaxBillNo(outlet) async {
    final response =
        await http.get(Uri.parse('$baseUrl/bill/next-bill-number/$outlet'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch configurations');
    }
  }

  Future<List<Map<String, dynamic>>> getbillByStatus(
      {String? status, String? billno}) async {
    if (status == null && billno == null) {
      throw Exception('Either status or billno must be provided');
    }

    final uri = Uri.parse('$baseUrl/bill').replace(
      queryParameters: {
        if (status != null) 'status': status,
        if (billno != null) 'billno': billno,
      },
    );

    final response =
        await http.get(uri, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      List<dynamic> billJson = json.decode(response.body);
      return List<Map<String, dynamic>>.from(billJson);
    } else if (response.statusCode == 404) {
      throw Exception('No bills found');
    } else {
      throw Exception('Failed to fetch bills: ${response.body}');
    }
  }

  // Fetch orders by table number and status
  // Future<List<Map<String, dynamic>>> getbillByStatus(String status) async {
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/bill/$status'),
  //     headers: {'Content-Type': 'application/json'},
  //   );
  //   if (response.statusCode == 200) {
  //     List<dynamic> billJson =
  //         json.decode(response.body); // Assuming response is an array
  //     return List<Map<String, dynamic>>.from(
  //         billJson); // Convert to List<Map<String, dynamic>>
  //   } else if (response.statusCode == 404) {
  //     throw Exception('No bill found for the specified table and status');
  //   } else {
  //     throw Exception('Failed to fetch bill: ${response.body}');
  //   }
  // }

  Future<Map<String, dynamic>> getDashboardStatus() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bill/dashboard/today-stats'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('No bill found for the specified table and status');
    } else {
      throw Exception('Failed to fetch bill: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getAdminDashboardStatus() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bill/dashboard/summary'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('No bill found for the specified table and status');
    } else {
      throw Exception('Failed to fetch bill: ${response.body}');
    }
  }

  // 2. PUT: Edit Bill (Update Bill Details)
  Future<Map<String, dynamic>> editBill(
      String orderId, Map<String, dynamic> billData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/bill/$orderId'),
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
  Future<Map<String, dynamic>> generateBill(
      Map<String, dynamic> billData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bill'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(billData),
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
