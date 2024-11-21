import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WaiterConfigurationForm extends StatefulWidget {
  @override
  _WaiterConfigurationFormState createState() => _WaiterConfigurationFormState();
}

class _WaiterConfigurationFormState extends State<WaiterConfigurationForm> {
  final _formKey = GlobalKey<FormState>();
  String? selectedOutlet;
  String waiterName = '';
  String contactNumber = '';
  DateTime? hireDate;
  String status = 'active';
  bool isSaved = false;


  // List to store saved waiter configurations
  final List<Map<String, dynamic>> waiters = [];
  
 List<String> outlets = []; // List of outlets to select from
  List<dynamic> properties = [];
  List<dynamic> outletConfigurations = [];
@override
void initState(){
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
}



  void _saveWaiterConfiguration() {
    if (_formKey.currentState!.validate() && selectedOutlet != null && hireDate != null) {
      _formKey.currentState!.save();
      setState(() {
        waiters.add({
          'waiterName': waiterName,
          'contactNumber': contactNumber,
          'hireDate': hireDate,
          'status': status,
          'selectedOutlet': selectedOutlet,
        });
      });
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
      selectedOutlet = waiters[index]['selectedOutlet'];
      waiterName = waiters[index]['waiterName'];
      contactNumber = waiters[index]['contactNumber'];
      hireDate = waiters[index]['hireDate'];
      status = waiters[index]['status'];
      waiters.removeAt(index); // Remove the selected waiter to allow editing
    });
  }

  IconData _getStatusIcon(String status) {
    return status == 'active' ? Icons.circle : Icons.radio_button_off;
  }

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
            Text('Select Outlet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Outlet',
                icon: Icon(Icons.store),
              ),
              items: outlets.map((outlet) {
                return DropdownMenuItem(value: outlet, child: Text(outlet));
              }).toList(),
              onChanged: (value) => setState(() => selectedOutlet = value),
              validator: (value) => value == null ? 'Please select an outlet' : null,
            ),
            const SizedBox(height: 20),

            // Waiter Configuration Form
            Text('Enter Waiter Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Waiter Name',
                      icon: Icon(Icons.person),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter waiter name' : null,
                    onSaved: (value) => waiterName = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Contact Number',
                      icon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? 'Please enter contact number' : null,
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
                      if (pickedDate != null) setState(() => hireDate = pickedDate);
                    },
                    validator: (_) => hireDate == null ? 'Please select a hire date' : null,
                    controller: TextEditingController(
                      text: hireDate == null
                          ? ''
                          : "${hireDate!.day}-${hireDate!.month}-${hireDate!.year}",
                    ),
                  ),
                DropdownButtonFormField<String>(
  decoration: InputDecoration(
    labelText: 'Status',
    icon: Icon(Icons.check_circle),  // Replaced icon with check_circle
  ),
  items: ['active', 'inactive'].map((status) {
    return DropdownMenuItem(value: status, child: Text(status));
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
            Text('Saved Waiter Profiles:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          color: waiter['status'] == 'active' ? Colors.green : Colors.red,
        ),
        title: Text(waiter['waiterName'], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact: ${waiter['contactNumber']}'),
            Text('Hire Date: ${waiter['hireDate']?.day}-${waiter['hireDate']?.month}-${waiter['hireDate']?.year}'),
            Text('Outlet: ${waiter['selectedOutlet']}'),
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
              onPressed: () => _deleteWaiter(index), // Assuming _deleteWaiter is implemented to delete the waiter
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

}

void main() {
  runApp(MaterialApp(home: WaiterConfigurationForm()));
}
