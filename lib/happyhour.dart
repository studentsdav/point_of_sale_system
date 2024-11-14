import 'package:flutter/material.dart';

class HappyHourConfigForm extends StatefulWidget {
  @override
  _HappyHourConfigFormState createState() => _HappyHourConfigFormState();
}

class _HappyHourConfigFormState extends State<HappyHourConfigForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedOutlet; // To store the selected outlet
  String? _selectedHappyHour; // To store the selected happy hour
  Map<int, bool> _selectedItems = {}; // To store the selected items for happy hour
  final _discountController = TextEditingController();

  // Start and End time variables
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Sample data for outlets (replace with actual data)
  List<String> outlets = ['Outlet 1', 'Outlet 2', 'Outlet 3'];

  // Sample data for happy hour configurations (replace with actual data)
  List<String> happyHours = ['Happy Hour 1', 'Happy Hour 2', 'Happy Hour 3'];

  // Sample data for items (replace with actual data)
  List<String> items = ['Item 1', 'Item 2', 'Item 3', 'Item 4'];

  // List to store multiple configurations
  List<Map<String, dynamic>> savedConfigurations = [];

  // Save happy hour item configuration
  void _saveHappyHourConfig() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Iterate through selected items and store their names
      List<String> selectedItems = [];
      _selectedItems.forEach((itemId, isSelected) {
        if (isSelected) {
          selectedItems.add(items[itemId]);
        }
      });

      // Save the current configuration in the list
      setState(() {
        savedConfigurations.add({
          'outlet': _selectedOutlet,
          'happyHour': _selectedHappyHour,
          'discount': _discountController.text,
          'startTime': _startTime?.format(context),
          'endTime': _endTime?.format(context),
          'items': selectedItems,
        });

        // Clear form fields
        _selectedOutlet = null;
        _selectedHappyHour = null;
        _selectedItems.clear();
        _discountController.clear();
        _startTime = null;
        _endTime = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Happy Hour configuration saved successfully'))
      );
    }
  }

  // Function to pick time
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != TimeOfDay.now()) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Happy Hour Configuration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
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
                    _selectedHappyHour = null;
                    _selectedItems.clear();
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
              
              // Only show Happy Hour Selection if an outlet is selected
              if (_selectedOutlet != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Happy Hour Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedHappyHour,
                      onChanged: (value) {
                        setState(() {
                          _selectedHappyHour = value;
                        });
                      },
                      items: happyHours.map((happyHour) {
                        return DropdownMenuItem<String>(
                          value: happyHour,
                          child: Text(happyHour),
                        );
                      }).toList(),
                      decoration: InputDecoration(labelText: 'Select Happy Hour'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a happy hour configuration';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Item List with Discount Selection
                    Text('Select Items for Happy Hour:'),
                    ...items.asMap().entries.map((entry) {
                      int index = entry.key;
                      String item = entry.value;
                      return CheckboxListTile(
                        title: Text(item),
                        value: _selectedItems[index] ?? false,
                        onChanged: (value) {
                          setState(() {
                            _selectedItems[index] = value!;
                          });
                        },
                      );
                    }).toList(),
                    SizedBox(height: 16),
                    
                    // Discount Percentage Input
                    TextFormField(
                      controller: _discountController,
                      decoration: InputDecoration(
                        labelText: 'Discount Percentage (%)',
                        suffixText: '%',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a discount percentage';
                        }
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Please enter a valid discount percentage';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Start Time Picker
                    Text('Select Start Time:'),
                    ElevatedButton(
                      onPressed: () => _selectTime(context, true),
                      child: Text(_startTime == null ? 'Select Time' : _startTime!.format(context)),
                    ),
                    SizedBox(height: 16),

                    // End Time Picker
                    Text('Select End Time:'),
                    ElevatedButton(
                      onPressed: () => _selectTime(context, false),
                      child: Text(_endTime == null ? 'Select Time' : _endTime!.format(context)),
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              
              // Save Button
              ElevatedButton(
                onPressed: _saveHappyHourConfig,
                child: Text('Save Happy Hour Configuration'),
              ),

              // Display Saved Configuration
              SizedBox(height: 32),
              if (savedConfigurations.isNotEmpty)
                Text(
                  'Saved Configurations:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ...savedConfigurations.map((config) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Outlet:', config['outlet']),
                          _buildInfoRow('Happy Hour:', config['happyHour']),
                          _buildInfoRow('Discount:', '${config['discount']}%'),
                          _buildInfoRow('Start Time:', config['startTime']),
                          _buildInfoRow('End Time:', config['endTime']),
                          SizedBox(height: 8),
                          Text(
                            'Items with Discount:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...config['items'].map<Widget>((item) {
                            return Text(item);
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
