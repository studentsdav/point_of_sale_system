import 'dart:convert';

import 'package:http/http.dart' as http;
import '../api_config.dart';

class VendorService {
  final String baseUrl;

  VendorService({String? baseUrl}) : baseUrl = baseUrl ?? apiBaseUrl;

  Future<List<dynamic>> getAllVendors() async {
    final response = await http.get(Uri.parse('$baseUrl/vendors'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load vendors');
    }
  }

  Future<Map<String, dynamic>> getVendorById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/vendors/\$id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Vendor not found');
    }
  }

  Future<Map<String, dynamic>> createVendor(
      Map<String, dynamic> vendorData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/vendors'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(vendorData),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error creating vendor');
    }
  }

  Future<Map<String, dynamic>> updateVendor(
      int id, Map<String, dynamic> vendorData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/vendors/\$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(vendorData),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error updating vendor');
    }
  }

  Future<void> deleteVendor(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/vendors/\$id'));
    if (response.statusCode != 200) {
      throw Exception('Error deleting vendor');
    }
  }
}
