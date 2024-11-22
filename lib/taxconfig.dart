import 'package:flutter/material.dart';

class TaxConfigForm extends StatefulWidget {
  @override
  _TaxConfigFormState createState() => _TaxConfigFormState();
}

class _TaxConfigFormState extends State<TaxConfigForm> {
  final _formKey = GlobalKey<FormState>();
  final _taxNameController = TextEditingController();
  final _taxPercentageController = TextEditingController();
  String _taxType = 'exclusive'; // Default tax type
  String? _selectedOutlet; // To store the selected outlet

  // Sample outlets for selection (replace with actual data from your database)
  List<String> outlets = ['Outlet 1', 'Outlet 2', 'Outlet 3', 'Outlet 4'];

  // Map to store tax configurations
  List<Map<String, dynamic>> taxConfigurations = [];

  // Save tax configuration
  void _saveTaxConfig() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create a new tax config
      Map<String, dynamic> newTaxConfig = {
        'taxName': _taxNameController.text,
        'taxPercentage': _taxPercentageController.text,
        'taxType': _taxType,
        'outlet': _selectedOutlet,
      };

      setState(() {
        taxConfigurations.add(newTaxConfig);
        // Clear form fields after saving
        _taxNameController.clear();
        _taxPercentageController.clear();
        _taxType = 'exclusive';
        _selectedOutlet = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tax configuration saved successfully')));
    }
  }

  // Delete tax configuration
  void _deleteTaxConfig(int index) {
    setState(() {
      taxConfigurations.removeAt(index);
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Tax configuration deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tax Configuration')),
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
                  // Tax Name Input
                  TextFormField(
                    controller: _taxNameController,
                    decoration: InputDecoration(labelText: 'Tax Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a tax name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Tax Percentage Input
                  TextFormField(
                    controller: _taxPercentageController,
                    decoration: InputDecoration(
                      labelText: 'Tax Percentage',
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a tax percentage';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
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
                    decoration: InputDecoration(labelText: 'Tax Type'),
                  ),
                  SizedBox(height: 16),
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
                    decoration: InputDecoration(labelText: 'Select Outlet'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an outlet';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveTaxConfig,
                    child: Text('Save Tax Configuration'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            // Display saved tax configurations
            Expanded(
              child: ListView.builder(
                itemCount: taxConfigurations.length,
                itemBuilder: (context, index) {
                  var taxConfig = taxConfigurations[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.money, color: Colors.green),
                      title: Text(taxConfig['taxName']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Percentage: ${taxConfig['taxPercentage']}%'),
                          Text('Type: ${taxConfig['taxType']}'),
                          Text('Outlet: ${taxConfig['outlet']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTaxConfig(index),
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
