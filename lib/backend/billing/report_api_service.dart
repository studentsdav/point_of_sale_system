import 'dart:convert';

import 'package:http/http.dart' as http;
import '../api_config.dart';

class ReportApiService {
  final String baseUrl;

  ReportApiService({String? baseUrl}) : baseUrl = baseUrl ?? apiBaseUrl;

  //  Get Daily Sales Summary
  Future<Map<String, dynamic>> getDailySales() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/daily-sales'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch daily sales: ${response.body}');
    }
  }

  // Get Hourly Sales Report
  Future<List<dynamic>> getHourlySales() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/hourly-sales'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch hourly sales: ${response.body}');
    }
  }

  //  Get Item-Wise Sales Report
  Future<List<dynamic>> getItemWiseSales() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/item-wise-sales'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch item-wise sales: ${response.body}');
    }
  }

  //  Get Category-Wise Sales Report
  Future<List<dynamic>> getCategoryWiseSales() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/category-wise-sales'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch category-wise sales: ${response.body}');
    }
  }

  // Get Payment Breakdown Report
  Future<List<dynamic>> getPaymentBreakdown() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/payment-breakdown'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch payment breakdown: ${response.body}');
    }
  }
}
