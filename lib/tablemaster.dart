import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:point_of_sale_system/backend/table_api_service.dart';

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
  List<String> outlets = []; // Example outlets
  final String apiUrl = 'http://localhost:3000/api';  // Replace with your backend API URL
  List<dynamic> properties = [];
  List<dynamic> outletConfigurations = [];
  
  final TableApiService _tableApiService = TableApiService(apiUrl: 'http://localhost:3000/api'); // Create the service instance

  // Fetch table configurations
  Future<void> _fetchTableConfigs() async {
    try {
      final tables = await _tableApiService.getTableConfigs();
      setState(() {
        _tables = tables;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load tables')));
    }
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
      this.outlets = outletslist; // Set the outlets list
    });
  }
}


  List<Map<String, dynamic>> _parseJson(String jsonString) {
    // You can use a JSON decoder if you save the data in a valid JSON format
    return jsonString.isNotEmpty ? List<Map<String, dynamic>>.from([]) : [];
  }
  // Save a new table entry
  Future<void> _saveTableEntry() async {
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

    final tableData = {
      'table_no': _tableNo,
      'seats': _seats,
      'status': _status,
      'outlet_name': _selectedOutlet, // Assuming outlet ID is the index + 1
      'property_id': properties[0]['property_id'], // Or get this from input
      'category': 'Regular', // Or get this from input
      'location':'Main Hall'// Or get this from input
    };

    try {
      final success = await _tableApiService.createTableConfig(tableData);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Table created successfully!')));
        _fetchTableConfigs();  // Fetch updated table configurations
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create table')));
    }
  }

  // Edit an existing table entry
  Future<void> _editTableEntry(int id) async {
    final table = _tables.firstWhere((table) => table['id'] == id);

    setState(() {
      _selectedOutlet = table['outlet'];
      _tableNo = table['table_no'];
      _seats = table['seats'];
      _status = table['status'];
    });
  }

  // Delete a table entry
  Future<void> _deleteTableEntry(int id) async {
    try {
      final success = await _tableApiService.deleteTableConfig(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Table deleted successfully!')));
        _fetchTableConfigs();  // Fetch updated table configurations
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete table')));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDataFromHive();
    _fetchTableConfigs();  // Fetch table configurations when the page is loaded
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

            // Table List
            Expanded(
              child: ListView.builder(
                itemCount: _tables.length,
                itemBuilder: (context, index) {
                  final table = _tables[index];
                  return ListTile(
                    title: Text('Table ${table['table_no']}'),
                    subtitle: Text('Seats: ${table['seats']} | Status: ${table['status']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteTableEntry(table['id']),
                    ),
                    onTap: () => _editTableEntry(table['id']),
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
