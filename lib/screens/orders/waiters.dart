import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:point_of_sale_system/backend/order/waiterApiService.dart';

class WaiterConfigurationForm extends StatefulWidget {
  @override
  _WaiterConfigurationFormState createState() =>
      _WaiterConfigurationFormState();
}

class _WaiterConfigurationFormState extends State<WaiterConfigurationForm> {
  WaiterApiService waiterApiService = WaiterApiService();

  final _formKey = GlobalKey<FormState>();
  String? selectedOutlet;
  String waiterName = '';
  String contactNumber = '';
  DateTime? hireDate;
  String status = 'active';
  bool isSaved = false;

  // List to store saved waiter configurations
  List<dynamic> waiters = [];
  List<String> outlets = []; // List of outlets to select from
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
        this.outlets = outletslist; // Set the outlets list
      });
    }
    _fetchAllWaiters();
  }

  Future<void> _fetchAllWaiters() async {
    try {
      List<Map<String, dynamic>> waiterList =
          await waiterApiService.getAllWaiters();
      setState(() {
        waiters = waiterList; // Update the state with the fetched waiters
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load waiters: $error')),
      );
    }
  }

  void _saveWaiterConfiguration() async {
    if (_formKey.currentState!.validate() &&
        selectedOutlet != null &&
        hireDate != null) {
      _formKey.currentState!.save();

      Map<String, dynamic> waiterData = {
        'property_id': properties[0]['property_id'],
        'waiter_name': waiterName,
        'contact_number': contactNumber,
        'hire_date': hireDate?.toIso8601String(),
        'status': status,
        'selected_outlet': selectedOutlet,
      };

      try {
        await waiterApiService.createWaiter(waiterData);
        _fetchAllWaiters();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Waiter saved successfully')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving waiter: $error')),
        );
      }

      // Reset form after saving
      _formKey.currentState!.reset();
      setState(() {
        selectedOutlet = null;
        hireDate = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields.')),
      );
    }
  }

  void _editWaiterConfiguration(int index) {
    setState(() {
      isSaved = false;
      selectedOutlet = waiters[index]['selected_outlet'];
      waiterName = waiters[index]['waiter_name'];
      contactNumber = waiters[index]['contact_number'];
      hireDate = _formatDatenew(waiters[index]['hire_date']);
      status = waiters[index]['status'];
    });
  }

  void _deleteWaiterConfiguration(String waiterId) async {
    try {
      await waiterApiService.deleteWaiter(waiterId);
      setState(() {
        waiters.removeWhere((waiter) => waiter['waiterId'] == waiterId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Waiter deleted successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting waiter: $error')),
      );
    }
  }

  IconData _getStatusIcon(String status) {
    return status == 'active' ? Icons.circle : Icons.radio_button_off;
  }

  // void _saveWaiterConfiguration() {
  //   if (_formKey.currentState!.validate() && selectedOutlet != null && hireDate != null) {
  //     _formKey.currentState!.save();
  //     setState(() {
  //       waiters.add({
  //         'waiterName': waiterName,
  //         'contactNumber': contactNumber,
  //         'hireDate': hireDate,
  //         'status': status,
  //         'selectedOutlet': selectedOutlet,
  //       });
  //     });
  //     // Reset form after saving
  //     _formKey.currentState!.reset();
  //     setState(() {
  //       selectedOutlet = null;
  //       hireDate = null;
  //     });
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Please fill all required fields.')),
  //     );
  //   }
  // }

  // void _editWaiterConfiguration(int index) {
  //   setState(() {
  //     isSaved = false;
  //     selectedOutlet = waiters[index]['selectedOutlet'];
  //     waiterName = waiters[index]['waiterName'];
  //     contactNumber = waiters[index]['contactNumber'];
  //     hireDate = waiters[index]['hireDate'];
  //     status = waiters[index]['status'];
  //     waiters.removeAt(index); // Remove the selected waiter to allow editing
  //   });
  // }

  // IconData _getStatusIcon(String status) {
  //   return status == 'active' ? Icons.circle : Icons.radio_button_off;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Waiter Configuration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Outlet Selection (Mandatory)
            Text('Select Outlet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Outlet',
                icon: Icon(Icons.store),
              ),
              items: outlets.map((outlet) {
                return DropdownMenuItem(value: outlet, child: Text(outlet));
              }).toList(),
              onChanged: (value) => setState(() => selectedOutlet = value),
              validator: (value) =>
                  value == null ? 'Please select an outlet' : null,
            ),
            const SizedBox(height: 20),

            // Waiter Configuration Form
            Text('Enter Waiter Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Waiter Name',
                      icon: Icon(Icons.person),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter waiter name' : null,
                    onSaved: (value) => waiterName = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Contact Number',
                      icon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter contact number' : null,
                    onSaved: (value) => contactNumber = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Hire Date',
                      icon: Icon(Icons.date_range),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null)
                        setState(() => hireDate = pickedDate);
                    },
                    validator: (_) =>
                        hireDate == null ? 'Please select a hire date' : null,
                    controller: TextEditingController(
                      text: hireDate == null
                          ? ''
                          : "${hireDate!.day}-${hireDate!.month}-${hireDate!.year}",
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Status',
                      icon: Icon(Icons
                          .check_circle), // Replaced icon with check_circle
                    ),
                    items: ['active', 'inactive'].map((status) {
                      return DropdownMenuItem(
                          value: status, child: Text(status));
                    }).toList(),
                    onChanged: (value) {
                      // Check if value is not null before updating the status
                      if (value != null) {
                        setState(() {
                          status = value; // Update the status if it's not null
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveWaiterConfiguration,
                    child: Text('Save Waiter Configuration'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Show Waiter Profiles (List of saved waiters)
            Text('Saved Waiter Profiles:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              itemCount: waiters.length,
              itemBuilder: (context, index) {
                final waiter = waiters[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: Icon(
                      _getStatusIcon(waiter['status']),
                      color: waiter['status'] == 'active'
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: Text(waiter['waiter_name'],
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contact: ${waiter['contact_number']}'),
                        Text('Hire Date: ${_formatDate(waiter['hire_date'])}'),
                        Text('Outlet: ${waiter['selected_outlet']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editWaiterConfiguration(index),
                        ),
                        IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteWaiter(index);
                              _deleteWaiterConfiguration(
                                  waiter['waiter_id'].toString());
                            } // Assuming _deleteWaiter is implemented to delete the waiter
                            ),
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  void _deleteWaiter(int index) {
    setState(() {
      waiters.removeAt(index); // Removes the waiter from the list
    });
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

  DateTime? _formatDatenew(dynamic date) {
    try {
      if (date is String) {
        return DateTime.parse(date)
            .toLocal(); // Parse and convert to local timezone
      } else if (date is DateTime) {
        return date.toLocal(); // Ensure it's in local timezone
      }
    } catch (e) {
      print("Error formatting date: $e");
    }
    return null; // Return null if the parsing fails
  }
}

void main() {
  runApp(MaterialApp(home: WaiterConfigurationForm()));
}
