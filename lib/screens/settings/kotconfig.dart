import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../backend/settings/kotConfigApiService.dart';

class KOTConfigForm extends StatefulWidget {
  const KOTConfigForm({super.key});

  @override
  _KOTConfigFormState createState() => _KOTConfigFormState();
}

class _KOTConfigFormState extends State<KOTConfigForm> {
  KOTConfigApiService kotConfigApiService = KOTConfigApiService();
  final _formKey = GlobalKey<FormState>();
  int kotStartingNumber = 1;
  DateTime? startDate;
  String? selectedOutlet;
  final List<Map<String, dynamic>> kotConfigs = [];

  // List of outlets (this could be fetched dynamically from a database)
  List<String> outlets = [];

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
    _loadDataFromApi();
  }

  Future<void> _loadDataFromApi() async {
    try {
      final data = await kotConfigApiService.getKOTConfigs();

      setState(() {
        kotConfigs.clear();
        kotConfigs.addAll(data);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $error')),
      );
    }
  }

  // Method to save KOT Config
  void _saveKOTConfig() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final kotConfigData = {
        'kot_starting_number': kotStartingNumber,
        'start_date': startDate?.toIso8601String(),
        'selected_outlet': selectedOutlet,
        'property_id': properties[0]
            ['property_id'], // Replace with actual property ID
      };

      try {
        await kotConfigApiService.createKOTConfig(kotConfigData);

        _loadDataFromApi();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('KOT Config saved successfully')),
        );

        // Reset fields
        kotStartingNumber = 1;
        startDate = null;
        selectedOutlet = null;
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save data: $error')),
        );
      }
    }
  }

  Future<void> _editKOTConfig(
      String id, Map<String, dynamic> updatedData) async {
    try {
      final updatedConfig =
          await kotConfigApiService.updateKOTConfig(id, updatedData);

      setState(() {
        final index = kotConfigs.indexWhere((config) => config['id'] == id);
        if (index != -1) {
          kotConfigs[index] = updatedConfig;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KOT Config updated successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update data: $error')),
      );
    }
  }

  Future<void> _deleteKOTConfig(String id) async {
    try {
      await kotConfigApiService.deleteKOTConfig(id);
      setState(() {
        kotConfigs
            .removeWhere((item) => item['kot_id'].toString() == id.toString());
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KOT Config deleted successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete data: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KOT Configuration')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Entry Panel for KOT Config Details
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Outlet Selection Dropdown
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Select Outlet'),
                      value: selectedOutlet,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedOutlet = newValue;
                        });
                      },
                      items: outlets.map((outlet) {
                        return DropdownMenuItem<String>(
                          value: outlet,
                          child: Text(outlet),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an outlet';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // KOT Starting Number
                    TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Restricts input to digits only
                      ],
                      decoration: const InputDecoration(
                          labelText: 'Starting KOT Number'),
                      initialValue: kotStartingNumber.toString(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a starting KOT number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        kotStartingNumber = int.parse(value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    // Start Date
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Start Date (yyyy-MM-dd)'),
                      keyboardType: TextInputType.datetime,
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (selectedDate != null && selectedDate != startDate) {
                          setState(() {
                            startDate = selectedDate;
                          });
                        }
                      },
                      controller: TextEditingController(
                          text: startDate != null
                              ? "${startDate!.toLocal()}".split(' ')[0]
                              : ''),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a start date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: _saveKOTConfig,
                      child: const Text('Save KOT Config'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Display all KOT Config entries
              if (kotConfigs.isNotEmpty)
                Column(
                  children: kotConfigs.map((config) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                'Your KOT number starts from ${config['kot_starting_number']} from ${_formatDate(config['start_date'])} and was updated on ${_formatDate(config['update_date'])}. Outlet: ${config['selected_outlet']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              trailing: IconButton(
                                  onPressed: () {
                                    _deleteKOTConfig(
                                        config['kot_id'].toString());
                                  },
                                  icon: const Icon(Icons.delete)),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
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
