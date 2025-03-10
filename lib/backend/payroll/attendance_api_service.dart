import 'dart:convert';

import 'package:http/http.dart' as http;

class AttendanceApiService {
  final String baseUrl;

  AttendanceApiService(this.baseUrl);

  // Add an attendance record
  Future<Map<String, dynamic>> addAttendance(
      Map<String, dynamic> attendanceData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/attendance'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(attendanceData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add attendance record');
    }
  }

  // Fetch all attendance records
  Future<List<dynamic>> fetchAllAttendance() async {
    final response = await http.get(Uri.parse('$baseUrl/attendance'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch attendance records');
    }
  }

  // Update an attendance record
  Future<Map<String, dynamic>> updateAttendance(
      int id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/attendance/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Attendance record not found');
    } else {
      throw Exception('Failed to update attendance record');
    }
  }

  // Delete an attendance record
  Future<void> deleteAttendance(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/attendance/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete attendance record');
    }
  }
}
