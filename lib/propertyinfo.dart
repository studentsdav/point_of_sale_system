import 'package:flutter/material.dart';

class PropertyConfigurationForm extends StatefulWidget {
  @override
  _PropertyConfigurationFormState createState() =>
      _PropertyConfigurationFormState();
}

class _PropertyConfigurationFormState extends State<PropertyConfigurationForm> {
  final _formKey = GlobalKey<FormState>();
  String propertyName = '';
  String address = '';
  String contactNumber = '';
  String email = '';
  String businessHours = '';
  String taxRegNo = '';  // New field for Tax Registration Number
  String propertyId = '';    // Property ID as string to hold the datetime-based ID
  bool isSaved = false;

  void _savePropertyConfiguration() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        // Generate Property ID with the current date and time
        propertyId = _generatePropertyId();
        isSaved = true;
      });
    }
  }

  void _editPropertyConfiguration() {
    setState(() {
      isSaved = false;
    });
  }

  String _generatePropertyId() {
    final now = DateTime.now();
    // Format the propertyId as 'YYYYMMDDHHMMSS'
    return "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Property Configuration')),
      body: SingleChildScrollView(  // Make the entire body scrollable
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Configuration Form Panel
            Text('Enter Property Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Property Name',
                      icon: Icon(Icons.business),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter property name' : null,
                    onSaved: (value) => propertyName = value!,
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
                      labelText: 'Email',
                      icon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value!.isEmpty ? 'Please enter email' : null,
                    onSaved: (value) => email = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Business Hours',
                      icon: Icon(Icons.access_time),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter business hours' : null,
                    onSaved: (value) => businessHours = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Tax Registration Number (GST No)',
                      icon: Icon(Icons.card_giftcard),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter GST No' : null,
                    onSaved: (value) => taxRegNo = value!,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _savePropertyConfiguration,
                    child: Text('Save Property Configuration'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Show Property Profile (if saved)
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
                    Text('Property Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.business, size: 30, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(propertyName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                        Icon(Icons.email, size: 30, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(email, style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 30, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(businessHours, style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.card_giftcard, size: 30, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(taxRegNo, style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.assignment_ind, size: 30, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text('Property ID: $propertyId', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _editPropertyConfiguration,
                      child: Text('Edit Property Configuration'),
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
  runApp(MaterialApp(home: PropertyConfigurationForm()));
}
