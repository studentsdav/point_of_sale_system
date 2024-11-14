import 'package:flutter/material.dart';

class KOTConfigForm extends StatefulWidget {
  @override
  _KOTConfigFormState createState() => _KOTConfigFormState();
}

class _KOTConfigFormState extends State<KOTConfigForm> {
  final _formKey = GlobalKey<FormState>();
  int kotStartingNumber = 1;
  DateTime? startDate;
  String? selectedOutlet;
  final List<Map<String, dynamic>> kotConfigs = [];

  // List of outlets (this could be fetched dynamically from a database)
  final List<String> outlets = ['Outlet 1', 'Outlet 2', 'Outlet 3', 'Outlet 4'];

  // Method to save KOT Config
  void _saveKOTConfig() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Save the KOT config into the list
      setState(() {
        kotConfigs.add({
          'kotStartingNumber': kotStartingNumber,
          'startDate': startDate,
          'outlet': selectedOutlet,
          'updateDate': DateTime.now(),
        });
      });

      // Reset fields for the next entry
      kotStartingNumber = 1;
      startDate = null;
      selectedOutlet = null;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('KOT Config saved successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('KOT Configuration')),
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
                    // KOT Starting Number
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Starting KOT Number'),
                      keyboardType: TextInputType.number,
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
                    SizedBox(height: 16),
                    // Start Date
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Start Date (yyyy-MM-dd)'),
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
                          text: startDate != null ? "${startDate!.toLocal()}".split(' ')[0] : ''),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a start date';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // Outlet Selection Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Select Outlet'),
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
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveKOTConfig,
                      child: Text('Save KOT Config'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              // Display all KOT Config entries
              if (kotConfigs.isNotEmpty)
                Column(
                  children: kotConfigs.map((config) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your KOT number starts from ${config['kotStartingNumber']} from ${config['startDate'].toLocal()} and was updated on ${config['updateDate'].toLocal()}. Outlet: ${config['outlet']}',
                              style: TextStyle(
                                fontSize: 16,
                      
                   
                              ),
                            ),
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
}
