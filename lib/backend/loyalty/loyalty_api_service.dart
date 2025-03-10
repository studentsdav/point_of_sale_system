import 'dart:convert';

import 'package:http/http.dart' as http;

class LoyaltyApiService {
  final String baseUrl;

  LoyaltyApiService(this.baseUrl);

  // Create or update customer loyalty points
  Future<Map<String, dynamic>> addOrUpdateLoyaltyPoints(
      int guestId, int programId, int points) async {
    final response = await http.post(
      Uri.parse('$baseUrl/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'guest_id': guestId, 'program_id': programId, 'points': points}),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update loyalty points');
    }
  }

  // Get all customer loyalty records
  Future<List<dynamic>> fetchAllLoyaltyRecords() async {
    final response = await http.get(Uri.parse('$baseUrl/'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch loyalty records');
    }
  }

  // Get customer loyalty record by Guest ID
  Future<Map<String, dynamic>> fetchLoyaltyByGuestId(int guestId) async {
    final response = await http.get(Uri.parse('$baseUrl/$guestId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Customer loyalty record not found');
    } else {
      throw Exception('Failed to fetch loyalty record');
    }
  }

  // Redeem loyalty points
  Future<Map<String, dynamic>> redeemLoyaltyPoints(
      int guestId, int pointsToRedeem) async {
    final response = await http.put(
      Uri.parse('$baseUrl/redeem/$guestId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'points_to_redeem': pointsToRedeem}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 400) {
      throw Exception('Insufficient points or invalid request');
    } else if (response.statusCode == 404) {
      throw Exception('Customer loyalty record not found');
    } else {
      throw Exception('Failed to redeem loyalty points');
    }
  }

  // Delete customer loyalty record
  Future<String> deleteLoyaltyRecord(int guestId) async {
    final response = await http.delete(Uri.parse('$baseUrl/$guestId'));

    if (response.statusCode == 200) {
      return 'Customer loyalty record deleted successfully';
    } else if (response.statusCode == 404) {
      throw Exception('Customer loyalty record not found');
    } else {
      throw Exception('Failed to delete loyalty record');
    }
  }
}
