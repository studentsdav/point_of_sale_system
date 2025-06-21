import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import 'package:point_of_sale_system/model/service_charge_model.dart';

class ServiceChargeApiService {
  final String baseUrl;

  ServiceChargeApiService({String? baseUrl}) : baseUrl = baseUrl ?? apiBaseUrl;

  Future<void> _ensureBoxesOpen() async {
    if (!Hive.isBoxOpen('service')) {
      await Hive.openBox<ServiceChargeModel>('service');
    }
    if (!Hive.isBoxOpen('cache_data_service')) {
      await Hive.openBox<dynamic>('cache_data_service');
    }
  }

  // 1. Get all service charge configurations
  Future<List<Map<String, dynamic>>> getServiceChargeConfigurations() async {
    await _ensureBoxesOpen(); // ✅ Ensure Hive boxes are opened

    final Box<ServiceChargeModel> serviceBox =
        Hive.box<ServiceChargeModel>('service');
    final Box<dynamic> cacheBox = Hive.box('cache_data_service');

    // Check last fetch timestamp
    int? lastFetchTime = cacheBox.get('last_fetch_time_service');

    // If cached data is available and less than 24 hours old, return cached data
    // if (lastFetchTime != null &&
    //     DateTime.now()
    //             .difference(DateTime.fromMillisecondsSinceEpoch(lastFetchTime))
    //             .inHours <
    //         24) {
    //   return serviceBox.values.map((discount) => discount.toJson()).toList();
    // }

    final response = await http.get(
      Uri.parse('$baseUrl/servicecharge'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      List<ServiceChargeModel> discounts = responseData
          .map((json) => ServiceChargeModel.fromJson(json))
          .toList();

      // Clear existing data and store new data in Hive
      await serviceBox.clear();
      await serviceBox.addAll(discounts);

      // Store the current timestamp
      await cacheBox.put(
          'last_fetch_time_service', DateTime.now().millisecondsSinceEpoch);

      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception(
          'Failed to retrieve service charge configurations: ${response.body}');
    }
  }

  // 2. Get service charge configuration by ID
  Future<Map<String, dynamic>> getServiceChargeConfigurationById(
      String configId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/servicecharge/$configId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json
          .decode(response.body); // Returning the service charge configuration
    } else if (response.statusCode == 404) {
      throw Exception('Service charge configuration not found');
    } else {
      throw Exception(
          'Failed to retrieve service charge configuration: ${response.body}');
    }
  }

  // 3. Create a new service charge configuration
  Future<Map<String, dynamic>> createServiceChargeConfiguration(
      Map<String, dynamic> configData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/servicecharge'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(configData),
    );

    if (response.statusCode == 201) {
      return json.decode(response
          .body); // Returning the response with service charge config ID
    } else {
      throw Exception(
          'Failed to create service charge configuration: ${response.body}');
    }
  }

  // 4. Update service charge configuration by ID
  Future<Map<String, dynamic>> updateServiceChargeConfiguration(
      String configId, Map<String, dynamic> configData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/servicecharge/$configId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(configData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the success message
    } else if (response.statusCode == 404) {
      throw Exception('Service charge configuration not found');
    } else {
      throw Exception(
          'Failed to update service charge configuration: ${response.body}');
    }
  }

  // 5. Delete service charge configuration by ID
  Future<void> deleteServiceChargeConfiguration(String configId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/servicecharge/$configId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Successfully deleted
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Service charge configuration not found');
    } else {
      throw Exception(
          'Failed to delete service charge configuration: ${response.body}');
    }
  }
}
