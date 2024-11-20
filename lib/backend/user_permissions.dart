import 'dart:convert';
import 'package:http/http.dart' as http;

class UserPermissionApiService {
  final String baseUrl;

  UserPermissionApiService({required this.baseUrl});

  // 1. Create a new user permission
  Future<Map<String, dynamic>> createUserPermission(Map<String, dynamic> userPermissionData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/userpermissions'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userPermissionData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body); // Returning the created user permission data
    } else {
      throw Exception('Failed to create user permission: ${response.body}');
    }
  }

  // 2. Get all user permissions
  Future<List<Map<String, dynamic>>> getAllUserPermissions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/userpermissions.json'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception('Failed to fetch user permissions: ${response.body}');
    }
  }

  // 3. Get user permission by ID
  Future<Map<String, dynamic>> getUserPermissionById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/userpermissions/$id.json'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the user permission data
    } else if (response.statusCode == 404) {
      throw Exception('User permission not found');
    } else {
      throw Exception('Failed to fetch user permission: ${response.body}');
    }
  }

  // 4. Update user permission by ID
  Future<Map<String, dynamic>> updateUserPermission(
      String id, Map<String, dynamic> userPermissionData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/userpermissions/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userPermissionData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the updated user permission data
    } else if (response.statusCode == 404) {
      throw Exception('User permission not found');
    } else {
      throw Exception('Failed to update user permission: ${response.body}');
    }
  }

  // 5. Delete user permission by ID
  Future<void> deleteUserPermission(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/userpermissions/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('User permission not found');
    } else {
      throw Exception('Failed to delete user permission: ${response.body}');
    }
  }
}
