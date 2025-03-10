import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../backend/settings/taxConfigApiService.dart';

class TaxConfigForm extends StatefulWidget {
  const TaxConfigForm({super.key});

  @override
  _TaxConfigFormState createState() => _TaxConfigFormState();
}

class _TaxConfigFormState extends State<TaxConfigForm> {
  final _formKey = GlobalKey<FormState>();
  final _taxNameController = TextEditingController();
  final _taxPercentageController = TextEditingController();
  final _greaterthanController = TextEditingController();
  final _lessthanController = TextEditingController();
  final TaxConfigApiService taxApiService =
      TaxConfigApiService(baseUrl: 'http://localhost:3000/api');
  String _taxType = 'exclusive'; // Default tax type
  String? _selectedOutlet; // To store the selected outlet

  // Sample outlets for selection (replace with actual data from your database)
  List<String> outlets = [];

  // Map to store tax configurations
  List<Map<String, dynamic>> taxConfigurations = [];

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
    _fetchAllTaxConfigs();
  }

  // Save tax configuration
  // Fetch all tax configurations from API
  Future<void> _fetchAllTaxConfigs() async {
    try {
      List<Map<String, dynamic>> configs =
          await taxApiService.getAllTaxConfigs();
      setState(() {
        taxConfigurations = configs;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch tax configurations')));
    }
  }

// Save a new tax configuration
  void _saveTaxConfig() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Map<String, dynamic> newTaxConfig = {
        'tax_name': _taxNameController.text,
        'tax_percentage': double.tryParse(_taxPercentageController.text) ?? 0.0,
        'tax_type': _taxType,
        'outlet_name': _selectedOutlet,
        'greater_than': double.tryParse(_greaterthanController.text) ?? 0.0,
        'less_than': double.tryParse(_lessthanController.text) ?? 0.0,
        'property_id': properties[0]['property_id']
      };

      try {
        await taxApiService.createTaxConfig(newTaxConfig);
        _fetchAllTaxConfigs(); // Refresh list
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Tax configuration saved successfully')));
        _clearForm();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save tax configuration')));
      }
    }
  }

// Delete tax configuration
  void _deleteTaxConfig(String id) async {
    try {
      await taxApiService.deleteTaxConfig(id);
      // Refresh list
      setState(() {
        taxConfigurations
            .removeWhere((item) => item['id'].toString() == id.toString());
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tax configuration deleted')));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete tax configuration')));
    }
  }

// Clear form fields
  void _clearForm() {
    _taxNameController.clear();
    _taxPercentageController.clear();
    _greaterthanController.clear();
    _lessthanController.clear();
    setState(() {
      _taxType = 'exclusive';
      _selectedOutlet = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tax Configuration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tax Configuration Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Outlet Selection Dropdown
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
                  // Tax Name Input
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _taxNameController,
                    decoration: const InputDecoration(labelText: 'Tax Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a tax name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Tax Percentage Input
                  TextFormField(
                    controller: _taxPercentageController,
                    decoration: const InputDecoration(
                      labelText: 'Tax Percentage',
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // Restricts input to digits only
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a tax percentage';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Tax greater Than Input
                  TextFormField(
                    controller: _greaterthanController,
                    decoration: const InputDecoration(
                      labelText: 'Tax On Greater Than',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // Restricts input to digits only
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a tax value';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Tax less Than Input
                  TextFormField(
                    controller: _lessthanController,
                    decoration: const InputDecoration(
                      labelText: 'Tax On Less Than',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // Restricts input to digits only
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a tax percentage';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Tax Type Dropdown (Exclusive/Inclusive)
                  DropdownButtonFormField<String>(
                    value: _taxType,
                    onChanged: (value) {
                      setState(() {
                        _taxType = value!;
                      });
                    },
                    items: ['exclusive', 'inclusive'].map((taxType) {
                      return DropdownMenuItem<String>(
                        value: taxType,
                        child: Text(taxType),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'Tax Type'),
                  ),

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveTaxConfig,
                    child: const Text('Save Tax Configuration'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Display saved tax configurations
            Expanded(
              child: ListView.builder(
                itemCount: taxConfigurations.length,
                itemBuilder: (context, index) {
                  var taxConfig = taxConfigurations[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.money, color: Colors.green),
                      title: Text(taxConfig['tax_name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Percentage: ${taxConfig['tax_percentage']}%'),
                          Text('Type: ${taxConfig['tax_type']}'),
                          Text('Outlet: ${taxConfig['outlet_name']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _deleteTaxConfig(taxConfig['id'].toString()),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
