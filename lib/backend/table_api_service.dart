import 'dart:convert';
import 'package:http/http.dart' as http;

class TableApiService {
  final String apiUrl;

  TableApiService({required this.apiUrl});

  // Get request: Fetch table configurations
  Future<List<Map<String, dynamic>>> getTableConfigs() async {
    final response = await http.get(Uri.parse('$apiUrl/table-config'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((table) => table as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load tables');
    }
  }

  // Post request: Save new table configuration
  Future<bool> createTableConfig(Map<String, dynamic> tableData) async {
    final response = await http.post(
      Uri.parse('$apiUrl/table-config'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(tableData),
    );

    if (response.statusCode == 201) {
      return true; // Table created successfully
    } else {
      throw Exception('Failed to create table');
    }
  }

  // Put request: Update table configuration
  Future<bool> updateTableConfig(int id, Map<String, dynamic> tableData) async {
    final response = await http.put(
      Uri.parse('$apiUrl/table-config/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(tableData),
    );

    if (response.statusCode == 200) {
      return true; // Table updated successfully
    } else {
      throw Exception('Failed to update table');
    }
  }

  Future<bool> cleartable(String id) async {
    final response = await http.put(
      Uri.parse('$apiUrl/table-config/clear/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return true; // Table updated successfully
    } else {
      throw Exception('Failed to update table');
    }
  }

  // Delete request: Delete table configuration
  Future<bool> deleteTableConfig(int id) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/table-config/$id'),
    );

    if (response.statusCode == 200) {
      return true; // Table deleted successfully
    } else {
      throw Exception('Failed to delete table');
    }
  }
}
