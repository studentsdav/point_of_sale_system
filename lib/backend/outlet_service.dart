import 'dart:convert';
import 'package:http/http.dart' as http;

class OutletApiService {
  final String baseUrl;

  OutletApiService({required this.baseUrl});

  Future<List<dynamic>> getAllProperties() async {
    final url = Uri.parse("$baseUrl/properties");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch properties: ${response.body}");
      }
    } catch (error) {
      throw Exception("Error fetching properties: $error");
    }
  }


  Future<List<dynamic>> fetchOutletConfigurations() async {
    final response = await http.get(Uri.parse('$baseUrl/outlets'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch outlet configurations');
    }
  }

  Future<dynamic> createOutletConfiguration(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/outlet'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create outlet configuration');
    }
  }

  Future<void> updateOutletConfiguration(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/outlet/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update outlet configuration');
    }
  }

  Future<void> deleteOutletConfiguration(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/outlet/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete outlet configuration');
    }
  }
}
