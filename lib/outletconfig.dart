import 'package:flutter/material.dart';

class OutletConfigurationForm extends StatefulWidget {
  @override
  _OutletConfigurationFormState createState() =>
      _OutletConfigurationFormState();
}

class _OutletConfigurationFormState extends State<OutletConfigurationForm> {
  final _formKey = GlobalKey<FormState>();
  String? selectedProperty;
  String outletName = '';
  String address = '';
  String contactNumber = '';
  String managerName = '';
  String openingHours = '';
  bool isSaved = false;

  final List<String> properties = [
    'Property 1',
    'Property 2',
    'Property 3',
  ]; // List of properties to select from

  void _saveOutletConfiguration() {
    if (_formKey.currentState!.validate() && selectedProperty != null) {
      _formKey.currentState!.save();
      setState(() {
        isSaved = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields.')),
      );
    }
  }

  void _editOutletConfiguration() {
    setState(() {
      isSaved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Outlet Configuration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Selection (Mandatory First)
            Text('Select Property', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Property',
                icon: Icon(Icons.home),
              ),
              items: properties.map((property) {
                return DropdownMenuItem(value: property, child: Text(property));
              }).toList(),
              onChanged: (value) => setState(() => selectedProperty = value),
              validator: (value) => value == null ? 'Please select a property' : null,
            ),
            const SizedBox(height: 20),

            // Outlet Configuration Form
            Text('Enter Outlet Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Outlet Name',
                      icon: Icon(Icons.store),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter outlet name' : null,
                    onSaved: (value) => outletName = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Address',
                      icon: Icon(Icons.location_on),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter address' : null,
                    onSaved: (value) => address = value!,
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
                      labelText: 'Manager Name',
                      icon: Icon(Icons.person),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter manager name' : null,
                    onSaved: (value) => managerName = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Opening Hours',
                      icon: Icon(Icons.access_time),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter opening hours' : null,
                    onSaved: (value) => openingHours = value!,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveOutletConfiguration,
                    child: Text('Save Outlet Configuration'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Show Outlet Profile (if saved)
            if (isSaved)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue.shade50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Outlet Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.store, size: 30, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(outletName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 30, color: Colors.blue),
                        const SizedBox(width: 10),
                        Expanded(child: Text(address, style: TextStyle(fontSize: 14))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 30, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(contactNumber, style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.person, size: 30, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(managerName, style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 30, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(openingHours, style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.home, size: 30, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text('Property: $selectedProperty', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _editOutletConfiguration,
                      child: Text('Edit Outlet Configuration'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: OutletConfigurationForm()));
}
