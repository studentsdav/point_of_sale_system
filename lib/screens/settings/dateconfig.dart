import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../backend/settings/date_config_api_service.dart';

class SoftwareDateConfigForm extends StatefulWidget {
  const SoftwareDateConfigForm({super.key});

  @override
  _SoftwareDateConfigFormState createState() => _SoftwareDateConfigFormState();
}

class _SoftwareDateConfigFormState extends State<SoftwareDateConfigForm> {
  DateConfigApiService dateConfigApiService = DateConfigApiService();

  final _formKey = GlobalKey<FormState>();
  String? _selectedOutlet;
  DateTime? _selectedDate;
  final TextEditingController _descriptionController = TextEditingController();

  // Sample outlets data (this should be fetched from your database in a real scenario)
  List<String> outlets = [];

  // List to store saved configurations
  List<Map<String, dynamic>> savedConfigs = [];

  List<dynamic> properties = [];
  List<dynamic> outletConfigurations = [];
  @override
  void initState() {
    super.initState();
    _loadDataFromHive();
  }

  // Load data from Hive
  Future<void> _loadDataFromHive() async {
    var box = await Hive.openBox('appData');

    // Retrieve the data
    var properties = box.get('properties');
    var outletConfigurations = box.get('outletConfigurations');

    // Check if outletConfigurations is not null
    if (outletConfigurations != null) {
      // Extract the outlet names into the outlets list
      List<String> outletslist = [];
      for (var outlet in outletConfigurations) {
        if (outlet['outlet_name'] != null) {
          outletslist.add(outlet['outlet_name'].toString());
        }
      }

      setState(() {
        this.properties = properties ?? [];
        this.outletConfigurations = outletConfigurations ?? [];
        outlets = outletslist; // Set the outlets list
      });
    }
    _fetchDateConfigs();
  }

  void _fetchDateConfigs() async {
    try {
      List<Map<String, dynamic>> configs =
          await dateConfigApiService.getDateConfigs();

      setState(() {
        savedConfigs.clear();
        savedConfigs.addAll(configs);
      });
    } catch (e) {
      print('Error fetching date configurations: $e');
    }
  }

  void _saveSoftwareDateConfig() async {
    if (_formKey.currentState!.validate()) {
      final newConfig = {
        'property_id': properties[0]
            ['property_id'], // Replace with dynamic property ID
        'outlet': _selectedOutlet,
        'selected_date': _selectedDate?.toIso8601String(),
        'description': _descriptionController.text,
      };

      try {
        // Check if a configuration with the same property_id and outlet already exists
        final existingConfig = savedConfigs.firstWhere(
          (config) =>
              config['property_id'] == newConfig['property_id'].toString() &&
              config['outlet'] == newConfig['outlet'],
          orElse: () => {}, // Return an empty map if not found
        );

        if (existingConfig.isNotEmpty) {
          // If it exists, call the update function
          final updatedConfig = {
            'selected_date': newConfig['selected_date'],
            'description': newConfig['description'],
          };

          await dateConfigApiService.updateDateConfig(
              existingConfig['date_config_id'].toString(), updatedConfig);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Date configuration updated successfully')),
          );
        } else {
          // If it doesn't exist, create a new configuration
          await dateConfigApiService.createDateConfig(newConfig);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Date configuration saved successfully')),
          );
        }

        // Refresh the list and reset the form
        _fetchDateConfigs();
        _formKey.currentState!.reset();
        _descriptionController.clear();
        _selectedOutlet = null;
        _selectedDate = null;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving configuration: $e')),
        );
      }
    }
  }

  // Function to pick date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _deleteDateConfig(String dateConfigId) async {
    try {
      await dateConfigApiService.deleteDateConfig(dateConfigId);

      setState(() {
        savedConfigs.removeWhere((config) =>
            config['date_config_id'].toString() == dateConfigId.toString());
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Date configuration deleted successfully')),
      );
    } catch (e) {
      print('Error deleting configuration: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Software Date Configuration')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Outlet Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedOutlet,
                        onChanged: (value) {
                          setState(() {
                            _selectedOutlet = value;
                          });
                        },
                        items: outlets.map((outlet) {
                          return DropdownMenuItem<String>(
                            value: outlet,
                            child: Text(outlet),
                          );
                        }).toList(),
                        decoration:
                            const InputDecoration(labelText: 'Select Outlet'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an outlet';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date Picker
                      TextFormField(
                        controller: TextEditingController(
                          text: _selectedDate != null
                              ? "${_selectedDate!.toLocal()}".split(' ')[0]
                              : '',
                        ),
                        decoration: InputDecoration(
                          labelText: 'Select Software Date',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        validator: (value) {
                          if (_selectedDate == null) {
                            return 'Please select a date';
                          }
                          return null;
                        },
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),

                      // Description Input
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Save Button
                      ElevatedButton(
                        onPressed: _saveSoftwareDateConfig,
                        child: const Text('Save Configuration'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Display Saved Configurations (Log)
                const Text(
                  'Saved Configurations:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 16),
                if (savedConfigs.isNotEmpty)
                  Column(
                    children: savedConfigs.map((config) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLogInfoRow('Outlet:', config['outlet']!),
                              _buildLogInfoRow('Date:',
                                  _formatDate(config['selected_date'])),
                              _buildLogInfoRow(
                                  'Description:', config['description']!),
                              IconButton(
                                  onPressed: () {
                                    _deleteDateConfig(
                                        config['date_config_id'].toString());
                                  },
                                  icon: const Icon(Icons.delete))
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    try {
      if (date is String) {
        final parsedDate =
            DateTime.parse(date).toLocal(); // Convert to local timezone
        return "${parsedDate.day}-${parsedDate.month}-${parsedDate.year}";
      } else if (date is DateTime) {
        return "${date.toLocal().day}-${date.toLocal().month}-${date.toLocal().year}";
      }
    } catch (e) {
      print("Error formatting date: $e");
    }
    return "Invalid Date";
  }
}
