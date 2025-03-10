import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:point_of_sale_system/model/discount_model.dart';

class DiscountApiService {
  final String baseUrl;

  DiscountApiService({required this.baseUrl});

  // 1. Get all discount configurations
  Future<void> _ensureBoxesOpen() async {
    if (!Hive.isBoxOpen('discounts')) {
      await Hive.openBox<DiscountModel>('discounts');
    }
    if (!Hive.isBoxOpen('cache_data_discount')) {
      await Hive.openBox<dynamic>('cache_data_discount');
    }
  }

  /// Fetches discounts if cache is older than 24 hours
  Future<List<Map<String, dynamic>>> getDiscountConfigurations() async {
    await _ensureBoxesOpen(); // ✅ Ensure Hive boxes are opened

    final Box<DiscountModel> discountBox = Hive.box<DiscountModel>('discounts');
    final Box<dynamic> cacheBox = Hive.box('cache_data_discount');

    // Check last fetch timestamp
    int? lastFetchTime = cacheBox.get('last_fetch_time_disocunt');

    // If cached data is available and less than 24 hours old, return cached data
    // if (lastFetchTime != null &&
    //     DateTime.now()
    //             .difference(DateTime.fromMillisecondsSinceEpoch(lastFetchTime))
    //             .inHours <
    //         24) {
    //   return discountBox.values.map((discount) => discount.toJson()).toList();
    // }

    // Make API call if cache is outdated
    final response = await http.get(
      Uri.parse('$baseUrl/discounts'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      List<DiscountModel> discounts =
          responseData.map((json) => DiscountModel.fromJson(json)).toList();

      // Clear existing data and store new data in Hive
      await discountBox.clear();
      await discountBox.addAll(discounts);

      // Store the current timestamp
      await cacheBox.put(
          'last_fetch_time_disocunt', DateTime.now().millisecondsSinceEpoch);

      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception(
          'Failed to retrieve discount configurations: ${response.body}');
    }
  }

  List<DiscountModel> getLocalDiscounts() {
    return Hive.box<DiscountModel>('discounts').values.toList();
  }

  // 2. Get discount configuration by ID
  Future<Map<String, dynamic>> getDiscountConfigurationById(
      String configId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/discounts/$configId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Discount configuration not found');
    } else {
      throw Exception(
          'Failed to retrieve discount configuration: ${response.body}');
    }
  }

  // 3. Create a new discount configuration
  Future<Map<String, dynamic>> createDiscountConfiguration(
      Map<String, dynamic> configData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/discounts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(configData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to create discount configuration: ${response.body}');
    }
  }

  // 4. Update discount configuration by ID
  Future<Map<String, dynamic>> updateDiscountConfiguration(
      String configId, Map<String, dynamic> configData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/discounts/$configId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(configData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Discount configuration not found');
    } else {
      throw Exception(
          'Failed to update discount configuration: ${response.body}');
    }
  }

  // 5. Delete discount configuration by ID
  Future<void> deleteDiscountConfiguration(String configId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/discounts/$configId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Discount configuration not found');
    } else {
      throw Exception(
          'Failed to delete discount configuration: ${response.body}');
    }
  }
}
