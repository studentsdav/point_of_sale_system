import 'dart:convert';

import 'package:http/http.dart' as http;

class LoyaltyTransactionService {
  final String baseUrl = "https://your-api-url.com/loyalty-transactions";

  Future<Map<String, dynamic>> createTransaction(
      {required int guestId,
      required int programId,
      int? orderId,
      int? pointsEarned,
      int? pointsRedeemed,
      required String transactionType,
      String? expiryDate,
      required int storeId,
      required String paymentMethod}) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "guest_id": guestId,
        "program_id": programId,
        "order_id": orderId,
        "points_earned": pointsEarned ?? 0,
        "points_redeemed": pointsRedeemed ?? 0,
        "transaction_type": transactionType,
        "expiry_date": expiryDate,
        "store_id": storeId,
        "payment_method": paymentMethod
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create transaction: ${response.body}");
    }
  }

  Future<List<dynamic>> getAllTransactions() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch transactions");
    }
  }

  Future<List<dynamic>> getTransactionsByGuest(int guestId) async {
    final response = await http.get(Uri.parse("$baseUrl/guest/$guestId"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("No transactions found for this guest");
    }
  }

  Future<List<dynamic>> getTransactionsByStore(int storeId) async {
    final response = await http.get(Uri.parse("$baseUrl/store/$storeId"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("No transactions found for this store");
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    final response = await http.delete(Uri.parse("$baseUrl/$transactionId"));
    if (response.statusCode != 200) {
      throw Exception("Failed to delete transaction");
    }
  }
}
