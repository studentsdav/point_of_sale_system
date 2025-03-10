import 'dart:convert';

import 'package:http/http.dart' as http;

class TaxService {
  final String baseUrl;

  TaxService(this.baseUrl);

  Future<List<Map<String, dynamic>>> getTaxes() async {
    final response = await http.get(Uri.parse('$baseUrl/taxes'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch taxes');
    }
  }

  Future<Map<String, dynamic>> getTaxById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/taxes/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch tax');
    }
  }

  Future<Map<String, dynamic>> createTax(
      String taxName, double taxRate, String applicableOn) async {
    final response = await http.post(
      Uri.parse('$baseUrl/taxes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'tax_name': taxName,
        'tax_rate': taxRate,
        'applicable_on': applicableOn,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create tax');
    }
  }

  Future<Map<String, dynamic>> updateTax(
      String id, String taxName, double taxRate, String applicableOn) async {
    final response = await http.put(
      Uri.parse('$baseUrl/taxes/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'tax_name': taxName,
        'tax_rate': taxRate,
        'applicable_on': applicableOn,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update tax');
    }
  }

  Future<void> deleteTax(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/taxes/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete tax');
    }
  }
}
