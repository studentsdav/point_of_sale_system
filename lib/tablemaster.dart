import 'package:flutter/material.dart';

class TableManagementPage extends StatefulWidget {
  @override
  _TableManagementPageState createState() => _TableManagementPageState();
}

class _TableManagementPageState extends State<TableManagementPage> {
  int? _tableNo;
  int _seats = 2;
  String _status = 'Vacant'; // default status
  String? _selectedOutlet; // Outlet selection
  List<Map<String, dynamic>> _tables = [];
  List<String> outlets = ['Outlet 1', 'Outlet 2', 'Outlet 3']; // Example outlets

  // Function to save table entry
  void _saveTableEntry() {
    // Ensure that the outlet is selected and table number is valid
    if (_selectedOutlet == null || _tableNo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an outlet and enter a valid table number')),
      );
      return;
    }

    // Check for duplicate table number for the selected outlet
    if (_tables.any((table) => table['outlet'] == _selectedOutlet && table['table_no'] == _tableNo)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Table number $_tableNo already exists for this outlet.')),
      );
      return;
    }

    setState(() {
      // Add the new table to the list
      _tables.add({
        'outlet': _selectedOutlet,
        'table_no': _tableNo,
        'seats': _seats,
        'status': _status,
      });

      // Reset table-related form values but keep outlet selection
      _tableNo = null;
      _seats = 2;
      _status = 'Vacant';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Table created successfully!')),
    );
  }

  // Function to edit a table entry
  void _editTableEntry(int index) {
    setState(() {
      final table = _tables[index];
      _selectedOutlet = table['outlet'];
      _tableNo = table['table_no'];
      _seats = table['seats'];
      _status = table['status'];
    });
  }

  // Function to delete a table entry
  void _deleteTableEntry(int index) {
    setState(() {
      _tables.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Table deleted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Table Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Outlet Selection
            DropdownButtonFormField<String>(
              value: _selectedOutlet,
              onChanged: (newValue) {
                setState(() {
                  _selectedOutlet = newValue;
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

            // Table Creation Form (Only visible when an outlet is selected)
            if (_selectedOutlet != null) ...[
              // Table Number
              TextFormField(
                decoration: InputDecoration(labelText: 'Table Number'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _tableNo = int.tryParse(value);
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a table number';
                  }
                  if (_tableNo == null) {
                    return 'Table number must be a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Number of Seats
              TextFormField(
                decoration: InputDecoration(labelText: 'Seats'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _seats = int.tryParse(value) ?? 2;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of seats';
                  }
                  if (_seats <= 0) {
                    return 'Seats must be greater than 0';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Table Status
              DropdownButtonFormField<String>(
                value: _status,
                onChanged: (newValue) {
                  setState(() {
                    _status = newValue!;
                  });
                },
                items: ['Vacant', 'Occupied', 'Dirty']
                    .map((status) => DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                decoration: InputDecoration(labelText: 'Table Status'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a table status';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Save Button
              ElevatedButton(
                onPressed: _saveTableEntry,
                child: Text('Save Table'),
              ),
            ],

            SizedBox(height: 32),

            // Display Created Tables
            Text(
              'Created Tables for ${_selectedOutlet ?? ''}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _tables.isEmpty
                ? Text('No tables created yet for this outlet.')
                : Expanded(
                    child: ListView.builder(
                      itemCount: _tables.length,
                      itemBuilder: (context, index) {
                        final table = _tables[index];
                        if (table['outlet'] == _selectedOutlet) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            elevation: 4,
                            child: ListTile(
                              leading: Icon(Icons.table_chart, color: Colors.blue),
                              title: Text('Table ${table['table_no']}'),
                              subtitle: Text(
                                  'Seats: ${table['seats']} | Status: ${table['status']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Edit Icon
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.orange),
                                    onPressed: () {
                                      _editTableEntry(index);
                                    },
                                  ),
                                  // Delete Icon
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _deleteTableEntry(index);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return SizedBox.shrink(); // If the table is not for the selected outlet, hide it
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TableManagementPage(),
  ));
}
