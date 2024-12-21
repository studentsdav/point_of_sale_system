import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:point_of_sale_system/backend/outlet_service.dart';
import 'package:point_of_sale_system/backend/property_service.dart';

class PropertyConfigurationForm extends StatefulWidget {
  const PropertyConfigurationForm({super.key});

  @override
  _PropertyConfigurationFormState createState() =>
      _PropertyConfigurationFormState();
}

class _PropertyConfigurationFormState extends State<PropertyConfigurationForm> {
  final _formKey = GlobalKey<FormState>();
  String propertyName = '';
  String address = '';
  String contactNumber = '';
  String email = '';
  String businessHours = '';
  String taxRegNo = '';
  String propertyId = '';
  bool isSaved = false;

  final PropertyService _propertyService = PropertyService();
  List propertyList = [];
  bool isLoading = false;

  @override
  void initState() {
    _initializeHive();
    super.initState();
    _fetchProperties();
  }

  final OutletApiService apiService =
      OutletApiService(baseUrl: 'http://localhost:3000/api');
  List<dynamic> properties = [];
  List<dynamic> outletConfigurations = [];

  Future<void> _loadData() async {
    try {
      final fetchedProperties = await apiService.getAllProperties();
      final fetchedOutletConfigurations =
          await apiService.fetchOutletConfigurations();

      // If your data is in JSON format, you should decode it first:
      // List<dynamic> jsonData = json.decode(fetchedProperties);
      List<Map<String, dynamic>> propertiesList =
          List<Map<String, dynamic>>.from(fetchedProperties);
      List<Map<String, dynamic>> outletConfigurationsList =
          List<Map<String, dynamic>>.from(fetchedOutletConfigurations);

      // Save data to SharedPreferences
      await _saveDataToHive(propertiesList, outletConfigurationsList);

      setState(() {
        properties = propertiesList;
        outletConfigurations = outletConfigurationsList;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $error')),
      );
    }
  }

  // Method to save fetched data into SharedPreferences
  Future<void> _initializeHive() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  }

  Future<void> _saveDataToHive(List<Map<String, dynamic>> properties,
      List<Map<String, dynamic>> outletConfigurations) async {
    var box = await Hive.openBox('appData');

    // Store the data in a Hive box
    await box.put('properties', properties);
    await box.put('outletConfigurations', outletConfigurations);
  }

  // Fetch properties from the service
  Future<void> _fetchProperties() async {
    setState(() {
      isLoading = true;
    });
    try {
      final properties = await _propertyService
          .getAllProperties(); // Fetch the list of properties
      setState(() {
        propertyList = properties; // Store the fetched properties in the list
        isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching properties: $error')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _savePropertyConfiguration() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        // Generate Property ID with the current date and time
        propertyId = _generatePropertyId();
        isSaved = true;
        _submitForm();
      });
    }
  }

  Future<void> _submitForm() async {
    try {
      final response = await _propertyService.createProperty(
        propertyId: int.parse(_generatePropertyId()),
        propertyName: propertyName,
        address: address,
        contactNumber: contactNumber,
        email: email,
        businessHours: businessHours,
        taxRegNo: taxRegNo,
        state: "Uttarakhand",
        district: "Dehradun",
        country: "India",
        currency: "\$",
        is_saved: isSaved,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Property created: ${response['property_name']}')),
      );
      _fetchProperties();
      _loadData();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating property: $error')),
      );
    }
  }

  String _generatePropertyId() {
    final now = DateTime.now();
    // Format the propertyId as 'YYYYMMDDHHMMSS'
    return "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
  }

  void _editPropertyConfiguration(Map<String, dynamic> property) {
    setState(() {
      propertyId = property['property_id'].toString();
      propertyName = property['property_name'];
      address = property['address'];
      contactNumber = property['contact_number'];
      email = property['email'];
      businessHours = property['business_hours'];
      taxRegNo = property['tax_reg_no'];
      isSaved = true;
    });
  }

  Future<void> _updateProperty() async {
    try {
      await _propertyService.updateProperty(
        state: "Uttarakhand",
        district: "Dehradun",
        country: "india",
        currency: "\$",
        propertyId: int.parse(propertyId),
        propertyName: propertyName,
        address: address,
        contactNumber: contactNumber,
        email: email,
        businessHours: businessHours,
        taxRegNo: taxRegNo,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property updated successfully')),
      );
      _fetchProperties();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating property: $error')),
      );
    }
  }

  Future<void> _deleteProperty(int propertyId) async {
    try {
      await _propertyService.deleteProperty(propertyId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property deleted successfully')),
      );
      _fetchProperties();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting property: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Property Configuration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter Property Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: propertyName,
                    decoration: const InputDecoration(
                      labelText: 'Property Name',
                      icon: Icon(Icons.business),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter property name' : null,
                    onSaved: (value) => propertyName = value!,
                  ),
                  TextFormField(
                    initialValue: address,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      icon: Icon(Icons.location_on),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter address' : null,
                    onSaved: (value) => address = value!,
                  ),
                  TextFormField(
                    initialValue: contactNumber,
                    decoration: const InputDecoration(
                      labelText: 'Contact Number',
                      icon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter contact number' : null,
                    onSaved: (value) => contactNumber = value!,
                  ),
                  TextFormField(
                    initialValue: email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      icon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter email' : null,
                    onSaved: (value) => email = value!,
                  ),
                  TextFormField(
                    initialValue: businessHours,
                    decoration: const InputDecoration(
                      labelText: 'Business Hours',
                      icon: Icon(Icons.access_time),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter business hours' : null,
                    onSaved: (value) => businessHours = value!,
                  ),
                  TextFormField(
                    initialValue: taxRegNo,
                    decoration: const InputDecoration(
                      labelText: 'Tax Registration Number (GST No)',
                      icon: Icon(Icons.card_giftcard),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter GST No' : null,
                    onSaved: (value) => taxRegNo = value!,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (isSaved) {
                            _updateProperty();
                          } else {
                            _savePropertyConfiguration();
                          }
                        },
                        child:
                            Text(isSaved ? 'Update Property' : 'Save Property'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => setState(() {
                          isSaved = false;
                          _formKey.currentState!.reset();
                        }),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            if (!isLoading && propertyList.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                itemCount: propertyList.length,
                itemBuilder: (context, index) {
                  final property = propertyList[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property['property_name'] ?? 'No Name',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                              'Address: ${property['address'] ?? 'Not available'}'),
                          const SizedBox(height: 8),
                          Text(
                              'Contact Number: ${property['contact_number'] ?? 'Not available'}'),
                          const SizedBox(height: 8),
                          Text(
                              'Email: ${property['email'] ?? 'Not available'}'),
                          const SizedBox(height: 8),
                          Text(
                              'Business Hours: ${property['business_hours'] ?? 'Not available'}'),
                          const SizedBox(height: 8),
                          Text(
                              'Tax Registration No: ${property['tax_reg_no'] ?? 'Not available'}'),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  setState(() {
                                    isSaved = false;
                                    _formKey.currentState!.reset();
                                  });
                                  _editPropertyConfiguration(property);
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteProperty(
                                    int.parse(property['property_id'])),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: PropertyConfigurationForm()));
}
