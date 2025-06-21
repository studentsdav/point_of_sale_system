import 'dart:convert';

import 'package:http/http.dart' as http;
import '../api_config.dart';

class FeedbackApiService {
  final String baseUrl;

  FeedbackApiService({String? baseUrl}) : baseUrl = baseUrl ?? apiBaseUrl;

  // Add new feedback
  Future<Map<String, dynamic>> addFeedback(
      int guestId, int rating, String comments) async {
    final response = await http.post(
      Uri.parse('$baseUrl/feedback'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'guest_id': guestId, 'rating': rating, 'comments': comments}),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add feedback');
    }
  }

  // Get all feedback
  Future<List<dynamic>> fetchAllFeedback() async {
    final response = await http.get(Uri.parse('$baseUrl/feedback'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch feedback');
    }
  }

  // Get feedback by ID
  Future<Map<String, dynamic>> fetchFeedbackById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/feedback/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Feedback not found');
    } else {
      throw Exception('Failed to fetch feedback');
    }
  }

  // Get feedback by Guest ID
  Future<List<dynamic>> fetchFeedbackByGuestId(int guestId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/feedback/guest/$guestId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('No feedback found for this guest');
    } else {
      throw Exception('Failed to fetch guest feedback');
    }
  }

  // Update feedback by ID
  Future<Map<String, dynamic>> updateFeedback(
      int id, int rating, String comments) async {
    final response = await http.put(
      Uri.parse('$baseUrl/feedback/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'rating': rating, 'comments': comments}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Feedback not found');
    } else {
      throw Exception('Failed to update feedback');
    }
  }

  // Delete feedback by ID
  Future<String> deleteFeedback(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/feedback/$id'));

    if (response.statusCode == 200) {
      return 'Feedback deleted successfully';
    } else if (response.statusCode == 404) {
      throw Exception('Feedback not found');
    } else {
      throw Exception('Failed to delete feedback');
    }
  }
}
