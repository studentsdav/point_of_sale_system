import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:point_of_sale_system/model/packing_charge_model.dart';

class PackingChargeApiService {
  final String baseUrl;

  PackingChargeApiService({required this.baseUrl});

  Future<void> _ensureBoxesOpen() async {
    if (!Hive.isBoxOpen('packing')) {
      await Hive.openBox<PackingChargeModel>('packing');
    }
    if (!Hive.isBoxOpen('cache_data_packing')) {
      await Hive.openBox<dynamic>('cache_data_packing');
    }
  }

  // 1. Get all Packing Charge configurations
  Future<List<Map<String, dynamic>>> getPackingChargeConfigurations() async {
    await _ensureBoxesOpen(); // ✅ Ensure Hive boxes are opened

    final Box<PackingChargeModel> packingBox =
        Hive.box<PackingChargeModel>('packing');
    final Box<dynamic> cacheBox = Hive.box('cache_data_packing');

    // Check last fetch timestamp
    int? lastFetchTime = cacheBox.get('last_fetch_time_packing');

    // If cached data is available and less than 24 hours old, return cached data
    // if (lastFetchTime != null &&
    //     DateTime.now()
    //             .difference(DateTime.fromMillisecondsSinceEpoch(lastFetchTime))
    //             .inHours <
    //         24) {
    //   return packingBox.values.map((discount) => discount.toJson()).toList();
    // }

    final response = await http.get(
      Uri.parse('$baseUrl/packingcharge'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      List<PackingChargeModel> discounts = responseData
          .map((json) => PackingChargeModel.fromJson(json))
          .toList();

      // Clear existing data and store new data in Hive
      await packingBox.clear();
      await packingBox.addAll(discounts);

      // Store the current timestamp
      await cacheBox.put(
          'last_fetch_time_packing', DateTime.now().millisecondsSinceEpoch);

      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception(
          'Failed to retrieve Packing Charge configurations: ${response.body}');
    }
  }

  // 2. Get Packing Charge configuration by ID
  Future<Map<String, dynamic>> getPackingChargeConfigurationById(
      String configId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/packingcharge/$configId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json
          .decode(response.body); // Returning the Packing Charge configuration
    } else if (response.statusCode == 404) {
      throw Exception('Packing Charge configuration not found');
    } else {
      throw Exception(
          'Failed to retrieve Packing Charge configuration: ${response.body}');
    }
  }

  // 3. Create a new Packing Charge configuration
  Future<Map<String, dynamic>> createPackingChargeConfiguration(
      Map<String, dynamic> configData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/packingcharge'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(configData),
    );

    if (response.statusCode == 201) {
      return json.decode(response
          .body); // Returning the response with Packing Charge config ID
    } else {
      throw Exception(
          'Failed to create Packing Charge configuration: ${response.body}');
    }
  }

  // 4. Update Packing Charge configuration by ID
  Future<Map<String, dynamic>> updatePackingChargeConfiguration(
      String configId, Map<String, dynamic> configData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/packingcharge/$configId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(configData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the success message
    } else if (response.statusCode == 404) {
      throw Exception('Packing Charge configuration not found');
    } else {
      throw Exception(
          'Failed to update Packing Charge configuration: ${response.body}');
    }
  }

  // 5. Delete Packing Charge configuration by ID
  Future<void> deletePackingChargeConfiguration(String configId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/packingcharge/$configId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Successfully deleted
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Packing Charge configuration not found');
    } else {
      throw Exception(
          'Failed to delete Packing Charge configuration: ${response.body}');
    }
  }
}
