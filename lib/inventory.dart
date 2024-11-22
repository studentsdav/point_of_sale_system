import 'package:flutter/material.dart';

class StockEntryForm extends StatefulWidget {
  @override
  _StockEntryFormState createState() => _StockEntryFormState();
}

class _StockEntryFormState extends State<StockEntryForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedOutlet;
  String? _selectedItem;
  int _quantity = 0;
  String? _transactionType; // 'credit' or 'debit'
  DateTime? _selectedDate;

  // Outlet and associated items mapping
  List<String> outlets = ['Outlet 1', 'Outlet 2', 'Outlet 3'];

  Map<String, List<Map<String, dynamic>>> itemsByOutlet = {
    'Outlet 1': [
      {'item_id': 1, 'item_name': 'Item 1', 'quantity': 100},
      {'item_id': 2, 'item_name': 'Item 2', 'quantity': 200},
    ],
    'Outlet 2': [
      {'item_id': 3, 'item_name': 'Item 3', 'quantity': 150},
      {'item_id': 4, 'item_name': 'Item 4', 'quantity': 80},
    ],
    'Outlet 3': [
      {'item_id': 5, 'item_name': 'Item 5', 'quantity': 50},
      {'item_id': 6, 'item_name': 'Item 6', 'quantity': 300},
    ],
  };

  List<Map<String, dynamic>> availableItems =
      []; // To store items filtered by selected outlet

  // Function to save stock entry (add or remove stock)
  void _saveStockEntry() {
    if (_formKey.currentState!.validate()) {
      var selectedItem = availableItems.firstWhere(
        (item) => item['item_id'] == int.parse(_selectedItem!),
        orElse: () => {},
      );

      if (selectedItem.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item not found in inventory')));
        return;
      }

      if (_selectedOutlet == null ||
          _selectedItem == null ||
          _transactionType == null ||
          _selectedDate == null ||
          _quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please fill all fields correctly')));
        return;
      }

      if (_transactionType == 'debit' && selectedItem['quantity'] < _quantity) {
        // Show alert if stock is insufficient for debit
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Insufficient Stock'),
            content: Text('There is not enough stock available for debit.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      setState(() {
        if (selectedItem.isNotEmpty) {
          if (_transactionType == 'credit') {
            selectedItem['quantity'] += _quantity;
          } else if (_transactionType == 'debit') {
            selectedItem['quantity'] -= _quantity;
          }
        }

        // Reset the form after saving
        _selectedItem = null;
        _quantity = 0;
        _selectedDate = null;
        _transactionType = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stock updated successfully!')),
      );
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

  // Update available items based on selected outlet
  void _updateAvailableItems() {
    if (_selectedOutlet != null) {
      setState(() {
        availableItems = itemsByOutlet[_selectedOutlet!] ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stock Entry Form')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form for selecting outlet, item, quantity, date, and transaction type
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Select Outlet
                      DropdownButtonFormField<String>(
                        value: _selectedOutlet,
                        onChanged: (value) {
                          setState(() {
                            _selectedOutlet = value;
                          });
                          _updateAvailableItems(); // Update item list when outlet changes
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

                      // Select Item (only show items related to the selected outlet)
                      DropdownButtonFormField<String>(
                        value: _selectedItem,
                        onChanged: (value) {
                          setState(() {
                            _selectedItem = value;
                          });
                        },
                        items: availableItems.map((item) {
                          return DropdownMenuItem<String>(
                            value: item['item_id'].toString(),
                            child: Text(item['item_name']),
                          );
                        }).toList(),
                        decoration: InputDecoration(labelText: 'Select Item'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an item';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Quantity Entry
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Quantity'),
                        onChanged: (value) {
                          setState(() {
                            _quantity = int.tryParse(value) ?? 0;
                          });
                        },
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              _quantity <= 0) {
                            return 'Please enter a valid quantity';
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
                          labelText: 'Select Date',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (_selectedDate == null) {
                            return 'Please select a date';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Transaction Type (Credit / Debit) - Radio Buttons
                      Row(
                        children: [
                          Radio<String>(
                            value: 'credit',
                            groupValue: _transactionType,
                            onChanged: (value) {
                              setState(() {
                                _transactionType = value;
                              });
                            },
                          ),
                          Text('Credit'),
                          SizedBox(width: 16),
                          Radio<String>(
                            value: 'debit',
                            groupValue: _transactionType,
                            onChanged: (value) {
                              setState(() {
                                _transactionType = value;
                              });
                            },
                          ),
                          Text('Debit'),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _saveStockEntry,
                        child: Text('Save Stock Entry'),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Show Available Stock in Second Panel
                Text(
                  'Item List for Selected Outlet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: availableItems.isEmpty
                      ? Text('No items available for this outlet')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: availableItems.map((item) {
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              elevation: 4,
                              child: ListTile(
                                leading: Icon(Icons.shopping_cart,
                                    color: Colors.blue),
                                title: Text(item['item_name']),
                                subtitle: Text('Stock: ${item['quantity']}'),
                                trailing: Icon(Icons.arrow_forward_ios,
                                    color: Colors.blue),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: StockEntryForm(),
  ));
}
