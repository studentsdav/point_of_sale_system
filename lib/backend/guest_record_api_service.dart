import 'dart:convert';
import 'package:http/http.dart' as http;

class GuestRecordApiService {
  final String baseUrl;

  GuestRecordApiService({required this.baseUrl});

  // 1. Create a new guest record
  Future<Map<String, dynamic>> createGuestRecord(
      Map<String, dynamic> guestData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/guest_record'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(guestData),
    );

    if (response.statusCode == 201) {
      return json
          .decode(response.body); // Returning the newly created guest record
    } else {
      throw Exception('Failed to create guest record: ${response.body}');
    }
  }

  // 2. Get all guest records
  Future<List<Map<String, dynamic>>> getGuestRecords() async {
    final response = await http.get(
      Uri.parse('$baseUrl/guest_record'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(
          data); // Returning all guest records as a list
    } else {
      throw Exception('Failed to fetch guest records: ${response.body}');
    }
  }

  // 3. Get guest record by ID
  Future<Map<String, dynamic>> getGuestRecordById(String guestId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/guest_record/$guestId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the guest record by ID
    } else if (response.statusCode == 404) {
      throw Exception('Guest record not found');
    } else {
      throw Exception('Failed to fetch guest record: ${response.body}');
    }
  }

  // 4. Update guest record by ID
  Future<Map<String, dynamic>> updateGuestRecord(
      String guestId, Map<String, dynamic> guestData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/guest_record/$guestId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(guestData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the updated guest record
    } else if (response.statusCode == 404) {
      throw Exception('Guest record not found');
    } else {
      throw Exception('Failed to update guest record: ${response.body}');
    }
  }

  // 5. Delete guest record by ID
  Future<void> deleteGuestRecord(String guestId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/guest_record/$guestId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Successfully deleted, return a success message
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Guest record not found');
    } else {
      throw Exception('Failed to delete guest record: ${response.body}');
    }
  }
}
