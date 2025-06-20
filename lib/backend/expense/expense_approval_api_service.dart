import 'dart:convert';

import 'package:http/http.dart' as http;
import '../api_config.dart';

class ExpenseApprovalApiService {
  final String baseUrl = '$apiBaseUrl/expense-approvals';

  // Submit a new expense approval request
  Future<Map<String, dynamic>> submitApproval(
      Map<String, dynamic> approvalData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(approvalData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to submit approval: ${response.body}");
    }
  }

  // Get all expense approvals
  Future<List<dynamic>> getAllApprovals() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch approvals");
    }
  }

  // Get approval by expense ID
  Future<List<dynamic>> getApprovalByExpenseId(String expenseId) async {
    final response = await http.get(Uri.parse("$baseUrl/expense/$expenseId"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch approval by expense ID");
    }
  }

  // Get approval by ID
  Future<Map<String, dynamic>> getApprovalById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Approval record not found");
    } else {
      throw Exception("Failed to fetch approval record");
    }
  }

  // Update approval status
  Future<Map<String, dynamic>> updateApproval(
      String id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Approval record not found");
    } else {
      throw Exception("Failed to update approval");
    }
  }

  // Delete an approval record
  Future<void> deleteApproval(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete approval record");
    }
  }
}
