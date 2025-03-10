import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:point_of_sale_system/model/delivery_charge_model.dart';

class DeliveryApiService {
  final String baseUrl;

  DeliveryApiService({required this.baseUrl});

  Future<void> _ensureBoxesOpen() async {
    if (!Hive.isBoxOpen('delivery')) {
      await Hive.openBox<DeliveryChargeModel>('delivery');
    }
    if (!Hive.isBoxOpen('cache_data_delivery')) {
      await Hive.openBox<dynamic>('cache_data_delivery');
    }
  }

  // 1. Get all delivery charge configurations
  Future<List<Map<String, dynamic>>> getDeliveryCharges() async {
    await _ensureBoxesOpen(); // ✅ Ensure Hive boxes are opened

    final Box<DeliveryChargeModel> deliveryBox =
        Hive.box<DeliveryChargeModel>('delivery');
    final Box<dynamic> cacheBox = Hive.box('cache_data_delivery');

    // Check last fetch timestamp
    int? lastFetchTime = cacheBox.get('last_fetch_time_delivery');

    // If cached data is available and less than 24 hours old, return cached data
    // if (lastFetchTime != null &&
    //     DateTime.now()
    //             .difference(DateTime.fromMillisecondsSinceEpoch(lastFetchTime))
    //             .inHours <
    //         24) {
    //   return deliveryBox.values.map((discount) => discount.toJson()).toList();
    // }

    final response = await http.get(
      Uri.parse('$baseUrl/deliverycharges'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      List<DeliveryChargeModel> discounts = responseData
          .map((json) => DeliveryChargeModel.fromJson(json))
          .toList();

      // Clear existing data and store new data in Hive
      await deliveryBox.clear();
      await deliveryBox.addAll(discounts);

      // Store the current timestamp
      await cacheBox.put(
          'last_fetch_time_delivery', DateTime.now().millisecondsSinceEpoch);

      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception(
          'Failed to retrieve discount configurations: ${response.body}');
    }
  }

  // 2. Get delivery charge configuration by ID
  Future<Map<String, dynamic>> getDeliveryChargeById(String chargeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/deliverycharges/$chargeId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Delivery charge configuration not found');
    } else {
      throw Exception('Failed to retrieve delivery charge: ${response.body}');
    }
  }

  // 3. Create a new delivery charge configuration
  Future<Map<String, dynamic>> createDeliveryCharge(
      Map<String, dynamic> chargeData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/deliverycharges'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(chargeData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to create delivery charge configuration: ${response.body}');
    }
  }

  // 4. Update delivery charge configuration by ID
  Future<Map<String, dynamic>> updateDeliveryCharge(
      String chargeId, Map<String, dynamic> chargeData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/deliverycharges/$chargeId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(chargeData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Delivery charge configuration not found');
    } else {
      throw Exception(
          'Failed to update delivery charge configuration: ${response.body}');
    }
  }

  // 5. Delete delivery charge configuration by ID
  Future<void> deleteDeliveryCharge(String chargeId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/deliverycharges/$chargeId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Delivery charge configuration not found');
    } else {
      throw Exception(
          'Failed to delete delivery charge configuration: ${response.body}');
    }
  }
}
