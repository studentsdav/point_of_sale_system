import 'dart:convert';

import 'package:http/http.dart' as http;

class ClosingBalanceApiService {
  final String baseUrl;

  ClosingBalanceApiService(this.baseUrl);

  // Fetch closing balance for all ingredients
  Future<List<dynamic>> fetchAllClosingBalances() async {
    final response = await http.get(Uri.parse('$baseUrl/closing-balance'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch closing balance data');
    }
  }

  // Fetch closing balance for a specific ingredient
  Future<Map<String, dynamic>> fetchClosingBalanceById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/closing-balance/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Ingredient not found');
    } else {
      throw Exception('Failed to fetch closing balance data');
    }
  }
}
