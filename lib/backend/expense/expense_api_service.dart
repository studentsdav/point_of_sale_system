import 'dart:convert';

import 'package:http/http.dart' as http;

class ExpenseApiService {
  final String baseUrl =
      "http://your-api-url.com/expenses"; // Replace with actual API URL

  // Add a new expense
  Future<Map<String, dynamic>> addExpense(
      Map<String, dynamic> expenseData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(expenseData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to add expense: ${response.body}");
    }
  }

  // Get all expenses
  Future<List<dynamic>> getAllExpenses() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch expenses");
    }
  }

  // Get expense by ID
  Future<Map<String, dynamic>> getExpenseById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Expense not found");
    } else {
      throw Exception("Failed to fetch expense");
    }
  }

  // Update expense
  Future<Map<String, dynamic>> updateExpense(
      String id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Expense not found");
    } else {
      throw Exception("Failed to update expense");
    }
  }

  // Delete an expense
  Future<void> deleteExpense(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete expense");
    }
  }
}
