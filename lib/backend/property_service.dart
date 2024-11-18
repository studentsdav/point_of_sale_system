import 'dart:convert';
import 'package:http/http.dart' as http;

class PropertyService {
  static const String _baseUrl = 'http://localhost:3000/api'; // Replace with your backend API URL

  // Function to create a property
  Future<Map<String, dynamic>> createProperty({
    required int propertyId,
    required String propertyName,
    required String address,
    required String contactNumber,
    required String email,
    required String businessHours,
    required String taxRegNo,
    required String state,
    required String district,
    required String country,
    required String currency,
    required bool is_saved
  }) async {
    final Uri url = Uri.parse('$_baseUrl/properties'); // API endpoint

    // Data to send in the body of the request
    final Map<String, dynamic> requestBody = {
      'property_id': propertyId,
      'property_name': propertyName,
      'address': address,
      'contact_number': contactNumber,
      'email': email,
      'business_hours': businessHours,
      'tax_reg_no': taxRegNo,
      'state': state,
      'district': district,
      'country': country,
      'currency': currency,
      'is_saved':is_saved
    };

    try {
      // Send the POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      // Check if the request was successful (status code 201)
      if (response.statusCode == 201) {
        return json.decode(response.body);  // Return the response data as a map
      } else {
        throw Exception('Failed to create property');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }
}
