import 'dart:convert';
import 'package:http/http.dart' as http;

class PrinterApiService {
  final String baseUrl;

  PrinterApiService({required this.baseUrl});

  // 1. Get all printer configurations
  Future<List<Map<String, dynamic>>> getPrinters() async {
    final response = await http.get(
      Uri.parse('$baseUrl/printer'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception('Failed to retrieve printer configurations: ${response.body}');
    }
  }

  // 2. Get printer configuration by ID
  Future<Map<String, dynamic>> getPrinterById(String printerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/printer/$printerId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the printer configuration details
    } else if (response.statusCode == 404) {
      throw Exception('Printer configuration not found');
    } else {
      throw Exception('Failed to retrieve printer configuration: ${response.body}');
    }
  }

  // 3. Create a new printer configuration
  Future<Map<String, dynamic>> createPrinter(Map<String, dynamic> printerData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/printer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(printerData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body); // Returning the response with printer ID
    } else {
      throw Exception('Failed to create printer configuration: ${response.body}');
    }
  }

  // 4. Update printer configuration by ID
  Future<Map<String, dynamic>> updatePrinter(String printerId, Map<String, dynamic> printerData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/printer/$printerId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(printerData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Returning the success message
    } else if (response.statusCode == 404) {
      throw Exception('Printer configuration not found');
    } else {
      throw Exception('Failed to update printer configuration: ${response.body}');
    }
  }

  // 5. Delete printer configuration by ID
  Future<void> deletePrinter(String printerId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/printer/$printerId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Successfully deleted
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Printer configuration not found');
    } else {
      throw Exception('Failed to delete printer configuration: ${response.body}');
    }
  }
}
