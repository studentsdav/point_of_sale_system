import 'package:flutter/material.dart';

class SoftwareDateConfigForm extends StatefulWidget {
  @override
  _SoftwareDateConfigFormState createState() => _SoftwareDateConfigFormState();
}

class _SoftwareDateConfigFormState extends State<SoftwareDateConfigForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedOutlet;
  DateTime? _selectedDate;
  TextEditingController _descriptionController = TextEditingController();

  // Sample outlets data (this should be fetched from your database in a real scenario)
  List<String> outlets = ['Outlet 1', 'Outlet 2', 'Outlet 3'];

  // List to store saved configurations
  List<Map<String, String>> savedConfigs = [];

  // Function to save the configuration
  void _saveSoftwareDateConfig() {
    if (_formKey.currentState!.validate()) {
      // Save configuration to list (this can also be saved to the database)
      setState(() {
        savedConfigs.add({
          'outlet': _selectedOutlet!,
          'date': _selectedDate != null
              ? "${_selectedDate!.toLocal()}".split(' ')[0]
              : 'No Date Selected',
          'description': _descriptionController.text.isEmpty
              ? 'No Description'
              : _descriptionController.text,
        });
      });

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Software Date configuration saved successfully')),
      );

      // Reset form after saving
      setState(() {
        _selectedOutlet = null;
        _selectedDate = null;
        _descriptionController.clear();
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Software Date Configuration')),
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
                        decoration: InputDecoration(labelText: 'Select Outlet'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an outlet';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

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
                            icon: Icon(Icons.calendar_today),
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
                      SizedBox(height: 16),

                      // Description Input
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description (optional)',
                        ),
                      ),
                      SizedBox(height: 16),

                      // Save Button
                      ElevatedButton(
                        onPressed: _saveSoftwareDateConfig,
                        child: Text('Save Configuration'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                // Display Saved Configurations (Log)
                Text(
                  'Saved Configurations:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 16),
                if (savedConfigs.isNotEmpty)
                  Column(
                    children: savedConfigs.map((config) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
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
                              _buildLogInfoRow('Date:', config['date']!),
                              _buildLogInfoRow(
                                  'Description:', config['description']!),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                SizedBox(height: 16),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
