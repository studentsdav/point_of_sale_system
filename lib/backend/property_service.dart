import 'dart:convert';
import 'package:http/http.dart' as http;

class PropertyService {
  final String _baseUrl = "http://localhost:3000/api";

  Future<Map<String, dynamic>> createProperty({
    required int propertyId,
    required String propertyName,
    required String address,
    required String contactNumber,
    required String email,
    required String businessHours,
    required String taxRegNo,
    required String state,
    required String district,
    required String country,
    required String currency,
    required bool is_saved,
  }) async {
    final url = Uri.parse("$_baseUrl/properties");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "property_id": propertyId,
          "property_name": propertyName,
          "address": address,
          "contact_number": contactNumber,
          "email": email,
          "business_hours": businessHours,
          "tax_reg_no": taxRegNo,
          "state": state,
          "district": district,
          "country": country,
          "currency": currency,
          "is_saved": is_saved,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to create property: ${response.body}");
      }
    } catch (error) {
      throw Exception("Error creating property: $error");
    }
  }

  Future<List<dynamic>> getAllProperties() async {
    final url = Uri.parse("$_baseUrl/properties.json");

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

  Future<Map<String, dynamic>> getPropertyById(int propertyId) async {
    final url = Uri.parse("$_baseUrl/properties/$propertyId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch property: ${response.body}");
      }
    } catch (error) {
      throw Exception("Error fetching property: $error");
    }
  }

  Future<void> updateProperty({
    required int propertyId,
    required String propertyName,
    required String address,
    required String contactNumber,
    required String email,
    required String businessHours,
    required String taxRegNo,
    required String state,
    required String district,
    required String country,
    required String currency,
  }) async {
    final url = Uri.parse("$_baseUrl/properties/$propertyId");

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "property_name": propertyName,
          "address": address,
          "contact_number": contactNumber,
          "email": email,
          "business_hours": businessHours,
          "tax_reg_no": taxRegNo,
          "state": state,
          "district": district,
          "country": country,
          "currency": currency,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update property: ${response.body}");
      }
    } catch (error) {
      throw Exception("Error updating property: $error");
    }
  }

  Future<void> deleteProperty(int propertyId) async {
    final url = Uri.parse("$_baseUrl/properties/$propertyId");

    try {
      final response = await http.delete(url);

      if (response.statusCode != 204) {
        throw Exception("Failed to delete property: ${response.body}");
      }
    } catch (error) {
      throw Exception("Error deleting property: $error");
    }
  }
}
