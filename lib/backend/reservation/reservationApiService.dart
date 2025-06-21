import 'dart:convert';

import 'package:http/http.dart' as http;
import '../api_config.dart';

class ReservationApiService {
  final String baseUrl;

  ReservationApiService({String? baseUrl}) : baseUrl = baseUrl ?? apiBaseUrl;

  // 1. Get all reservations
  Future<List<Map<String, dynamic>>> getReservations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reservation'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception('Failed to retrieve reservations: ${response.body}');
    }
  }

  // 2. Get reservation by ID
  Future<Map<String, dynamic>> getReservationById(String reservationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reservation/$reservationId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the reservation details
    } else if (response.statusCode == 404) {
      throw Exception('Reservation not found');
    } else {
      throw Exception('Failed to retrieve reservation: ${response.body}');
    }
  }

  // 3. Create a new reservation
  Future<Map<String, dynamic>> createReservation(
      Map<String, dynamic> reservationData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reservation'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reservationData),
    );

    if (response.statusCode == 201) {
      return json
          .decode(response.body); // Returning the response with reservation ID
    } else {
      throw Exception('Failed to create reservation: ${response.body}');
    }
  }

  // 4. Update reservation by ID
  Future<Map<String, dynamic>> updateReservation(
      String reservationId, Map<String, dynamic> reservationData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/reservation/$reservationId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reservationData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the success message
    } else if (response.statusCode == 404) {
      throw Exception('Reservation not found');
    } else {
      throw Exception('Failed to update reservation: ${response.body}');
    }
  }

  // 5. Delete reservation by ID
  Future<void> deleteReservation(String reservationId, String tableNo) async {
    final response = await http.delete(
        Uri.parse('$baseUrl/reservation/$reservationId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'tableNo': tableNo}));

    if (response.statusCode == 200) {
      // Successfully deleted
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Reservation not found');
    } else {
      throw Exception('Failed to delete reservation: ${response.body}');
    }
  }
}
