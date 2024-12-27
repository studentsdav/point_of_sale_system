import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:point_of_sale_system/backend/outlet_service.dart';

class OutletConfigurationForm extends StatefulWidget {
  const OutletConfigurationForm({super.key});

  @override
  _OutletConfigurationFormState createState() =>
      _OutletConfigurationFormState();
}

class _OutletConfigurationFormState extends State<OutletConfigurationForm> {
  final OutletApiService apiService =
      OutletApiService(baseUrl: 'http://localhost:3000/api');
  List<dynamic> properties = [];
  List<dynamic> outletConfigurations = [];
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  String? selectedProperty;
  String outletName = '';
  String address = '';
  String contactNumber = '';
  String managerName = '';
  String openingHours = '';
  bool isSaved = false;

  @override
  void initState() {
    _initializeHive();
    _loadData();
    super.initState();
  }

  Future<void> _loadDatanew() async {
    try {
      List<Map<String, dynamic>> propertiesList = [];
      List<Map<String, dynamic>> outletConfigurationsList = [];

      // Fetch properties
      try {
        final fetchedProperties = await apiService.getAllProperties();
        if (fetchedProperties.isNotEmpty) {
          propertiesList = List<Map<String, dynamic>>.from(fetchedProperties);
          print('Properties fetched successfully.');
        } else {
          print('No properties found.');
        }
      } catch (error) {
        print('Failed to fetch properties: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch properties: $error')),
        );
      }

      // Fetch outlet configurations
      try {
        final fetchedOutletConfigurations =
            await apiService.fetchOutletConfigurations();
        if (fetchedOutletConfigurations.isNotEmpty) {
          outletConfigurationsList =
              List<Map<String, dynamic>>.from(fetchedOutletConfigurations);
          print('Outlet configurations fetched successfully.');
        } else {
          print('No outlet configurations found.');
        }
      } catch (error) {
        print('Failed to fetch outlet configurations: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to fetch outlet configurations: $error')),
        );
      }

      // Save data if available
      try {
        if (propertiesList.isNotEmpty || outletConfigurationsList.isNotEmpty) {
          await _saveDataToHive(propertiesList, outletConfigurationsList);
          print('Data saved successfully.');
        } else {
          print('No data to save.');
        }
      } catch (error) {
        print('Failed to save data: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save data: $error')),
        );
      }

      // Update state
      setState(() {
        properties = propertiesList;
        outletConfigurations = outletConfigurationsList;
        isLoading = false;
      });
    } catch (error) {
      // Handle unexpected errors
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $error')),
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

  Future<void> _loadData() async {
    try {
      // Fetch properties
      List<Map<String, dynamic>> propertiesList = [];
      try {
        final fetchedProperties = await apiService.getAllProperties();
        if (fetchedProperties.isNotEmpty) {
          propertiesList = List<Map<String, dynamic>>.from(fetchedProperties);
          setState(() {
            properties = propertiesList;
            isLoading = false;
          });
          await _saveDataToHiveproperty(propertiesList);
          print('Properties saved successfully.');
        }
      } catch (error) {
        print('Error fetching properties: $error');
      }

      // Fetch outlet configurations
      List<Map<String, dynamic>> outletConfigurationsList = [];
      try {
        final fetchedOutletConfigurations =
            await apiService.fetchOutletConfigurations();
        if (fetchedOutletConfigurations.isNotEmpty) {
          outletConfigurationsList =
              List<Map<String, dynamic>>.from(fetchedOutletConfigurations);
          setState(() {
            outletConfigurations = outletConfigurationsList;
            isLoading = false;
          });

          await _saveDataToHiveoutlet(outletConfigurationsList);
          print('Outlet configurations saved successfully.');
        }
      } catch (error) {
        print('Error fetching outlet configurations: $error');
      }

      // Log final status
      if (propertiesList.isEmpty && outletConfigurationsList.isEmpty) {
        print('No data fetched for both properties and outlet configurations.');
      }
    } catch (error) {
      print('Unexpected error: $error');
    }
  }

  Future<void> _saveDataToHiveproperty(
    List<Map<String, dynamic>> properties,
  ) async {
    var box = await Hive.openBox('appData');
    // Store the data in a Hive box
    await box.put('properties', properties);
  }

  Future<void> _saveDataToHiveoutlet(
      List<Map<String, dynamic>> outletConfigurations) async {
    var box = await Hive.openBox('appData');

    await box.put('outletConfigurations', outletConfigurations);
  }

  void _saveOutletConfiguration() async {
    if (_formKey.currentState!.validate() && selectedProperty != null) {
      _formKey.currentState!.save();
      final outletData = {
        'property_id': int.parse(selectedProperty!),
        'outlet_name': outletName,
        'address': address,
        'contact_number': contactNumber,
        'manager_name': managerName,
        'opening_hours': openingHours,
        'currency': "\$",
        'city': "Dehradun",
        'country': "India",
        'state': "Uttarakhand"
      };

      try {
        await apiService.createOutletConfiguration(outletData);
        setState(() {
          isSaved = true;
          _loadDatanew();
          _loadData();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Outlet configuration saved successfully!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to save outlet configuration: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
    }
  }

  void _editOutletConfiguration() {
    setState(() {
      isSaved = false;
    });
  }

  Future<void> deleteOutletConfiguration(id) async {
    try {
      await apiService.deleteOutletConfiguration(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outlet deleted successfully!')),
      );
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete outlet: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Outlet Configuration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Selection (Mandatory First)
            const Text('Select Property',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Property',
                icon: Icon(Icons.home),
              ),
              items: properties.map<DropdownMenuItem<String>>((property) {
                return DropdownMenuItem<String>(
                  value: property['property_id'].toString(),
                  child: Text(property['property_name']),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedProperty = value),
              validator: (value) =>
                  value == null ? 'Please select a property' : null,
            ),
            const SizedBox(height: 20),

            // Outlet Configuration Form
            const Text('Enter Outlet Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Outlet Name',
                      icon: Icon(Icons.store),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter outlet name' : null,
                    onSaved: (value) => outletName = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      icon: Icon(Icons.location_on),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter address' : null,
                    onSaved: (value) => address = value!,
                  ),
                  TextFormField(
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
                    decoration: const InputDecoration(
                      labelText: 'Manager Name',
                      icon: Icon(Icons.person),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter manager name' : null,
                    onSaved: (value) => managerName = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Opening Hours',
                      icon: Icon(Icons.access_time),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter opening hours' : null,
                    onSaved: (value) => openingHours = value!,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveOutletConfiguration,
                    child: const Text('Save Outlet Configuration'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Show Outlet Profile (if saved)
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Outlet Profiles',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ...outletConfigurations.map((config) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue, width: 2),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.blue.shade50,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Outlet Profile: ${config['property_id']}',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.green),
                                      onPressed: () {
                                        // Implement edit functionality here
                                        _editOutletConfiguration();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        // Implement delete functionality here
                                        deleteOutletConfiguration(
                                            config['id'].toString());
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.store,
                                        size: 30, color: Colors.blue),
                                    const SizedBox(width: 10),
                                    Text(config['outlet_name'],
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 30, color: Colors.blue),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(config['address'],
                                          style: const TextStyle(fontSize: 14)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.phone,
                                        size: 30, color: Colors.blue),
                                    const SizedBox(width: 10),
                                    Text(config['contact_number'],
                                        style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.person,
                                        size: 30, color: Colors.blue),
                                    const SizedBox(width: 10),
                                    Text(config['manager_name'],
                                        style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 30, color: Colors.blue),
                                    const SizedBox(width: 10),
                                    Text(config['opening_hours'],
                                        style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: OutletConfigurationForm()));
}
