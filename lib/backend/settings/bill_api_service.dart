import 'dart:convert';

import 'package:http/http.dart' as http;

class BillApiService {
  final String baseUrl;

  BillApiService(this.baseUrl);

  Future<List<dynamic>> fetchConfigurations() async {
    final response = await http.get(Uri.parse('$baseUrl/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch configurations');
    }
  }

  Future<Map<String, dynamic>> createConfiguration(
      Map<String, dynamic> config) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(config),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create configuration');
    }
  }

  Future<Map<String, dynamic>> updateConfiguration(
      int id, Map<String, dynamic> config) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(config),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update configuration');
    }
  }

  Future<void> deleteConfiguration(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete configuration');
    }
  }
}
