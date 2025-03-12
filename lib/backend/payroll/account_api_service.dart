import 'dart:convert';

import 'package:http/http.dart' as http;

class AccountApiService {
  final String baseUrl;

  AccountApiService(this.baseUrl);

  // Create a new account
  Future<Map<String, dynamic>> createAccount(
      Map<String, dynamic> accountData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(accountData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create account');
    }
  }

  // Fetch all accounts
  Future<List<dynamic>> fetchAccounts() async {
    final response = await http.get(Uri.parse('$baseUrl/accounts'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch accounts');
    }
  }

  // Fetch account by ID
  Future<Map<String, dynamic>> fetchAccountById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/accounts/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Account not found');
    } else {
      throw Exception('Failed to fetch account');
    }
  }

  // Update account details
  Future<Map<String, dynamic>> updateAccount(
      int id, Map<String, dynamic> accountData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/accounts/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(accountData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Account not found');
    } else {
      throw Exception('Failed to update account');
    }
  }

  // Delete an account
  Future<void> deleteAccount(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/accounts/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete account');
    }
  }

  // Update account balance (Deposit/Withdraw)
  Future<Map<String, dynamic>> updateBalance(int id, double amount) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/accounts/$id/balance'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'amount': amount}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Account not found');
    } else {
      throw Exception('Failed to update balance');
    }
  }
}
