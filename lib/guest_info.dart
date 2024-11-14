import 'package:flutter/material.dart';

class GuestRegistrationScreen extends StatefulWidget {
  @override
  _GuestRegistrationScreenState createState() =>
      _GuestRegistrationScreenState();
}

class _GuestRegistrationScreenState extends State<GuestRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _guestId = 'G100';  // Set default Guest ID
  String? _guestName;
  String? _phoneNumber;
  String? _address;
  String? _email;
  String? _anniversary;
  String? _dob;
  String? _gstNo;
  String? _companyName;
  String? _discount;
  String? _gSuggestion;

  // Table data for displaying the guest records
  List<Map<String, String>> _guestRecords = [];

  // Function to handle form submission
  void _addGuest() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _guestRecords.add({
          'guest_id': _guestId!,
          'date_joined': DateTime.now().toString().split(' ')[0],
          'guest_name': _guestName!,
          'guest_address': _address!,
          'phone_number': _phoneNumber!,
          'email': _email!,
          'anniversary': _anniversary!,
          'dob': _dob!,
          'gst_no': _gstNo!,
          'company_name': _companyName!,
          'discount': _discount!,
          'g_suggestion': _gSuggestion!,
        });
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Guest added successfully!')),
      );
    }
  }

  // Function to handle guest record modification
  void _modifyGuest(int index) {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _guestRecords[index] = {
          'guest_id': _guestId!,
          'date_joined': DateTime.now().toString().split(' ')[0],
          'guest_name': _guestName!,
          'guest_address': _address!,
          'phone_number': _phoneNumber!,
          'email': _email!,
          'anniversary': _anniversary!,
          'dob': _dob!,
          'gst_no': _gstNo!,
          'company_name': _companyName!,
          'discount': _discount!,
          'g_suggestion': _gSuggestion!,
        };
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Guest modified successfully!')),
      );
    }
  }

  // Function to delete a guest
  void _deleteGuest(int index) {
    setState(() {
      _guestRecords.removeAt(index);
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Guest deleted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guest Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Left panel - Guest Registration Form
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 10)],
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Guest ID (non-editable)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: _guestId,
                          decoration: InputDecoration(
                            labelText: 'Guest ID',
                            prefixIcon: Icon(Icons.card_travel),
                            border: OutlineInputBorder(),
                          ),
                          enabled: false, // Make Guest ID non-editable
                        ),
                      ),
                      // Guest Name
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Guest Name',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _guestName = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the guest name';
                            }
                            return null;
                          },
                        ),
                      ),
                      // Phone Number
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _phoneNumber = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the phone number';
                            }
                            return null;
                          },
                        ),
                      ),
                      // Address
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Address',
                            prefixIcon: Icon(Icons.home),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _address = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the address';
                            }
                            return null;
                          },
                        ),
                      ),
                      // Email ID
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email ID',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _email = value;
                            });
                          },
                        ),
                      ),
                      // Anniversary
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Anniversary',
                            prefixIcon: Icon(Icons.cake),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _anniversary = value;
                            });
                          },
                        ),
                      ),
                      // Date of Birth
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'DOB',
                            prefixIcon: Icon(Icons.cake),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _dob = value;
                            });
                          },
                        ),
                      ),
                      // GST No
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'GST No.',
                            prefixIcon: Icon(Icons.local_taxi),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _gstNo = value;
                            });
                          },
                        ),
                      ),
                      // Company Name
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Company Name',
                            prefixIcon: Icon(Icons.business),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _companyName = value;
                            });
                          },
                        ),
                      ),
                      // Discount
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Discount',
                            prefixIcon: Icon(Icons.percent),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _discount = value;
                            });
                          },
                        ),
                      ),
                      // Guest Suggestion
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'G-Suggestion',
                            prefixIcon: Icon(Icons.comment),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _gSuggestion = value;
                            });
                          },
                        ),
                      ),
                      // Action Buttons
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: _addGuest,
                              child: Text('Add'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Modify the guest based on a selected index
                                // For now, we modify the first guest as an example
                                _modifyGuest(0);
                              },
                              child: Text('Modify'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Delete the guest based on a selected index
                                // For now, we delete the first guest as an example
                                _deleteGuest(0);
                              },
                              child: Text('Delete'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Exit action
                                Navigator.pop(context);
                              },
                              child: Text('Exit'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16), // Space between the panels
            // Right panel - Guest Records List
          Expanded(
  flex: 2,
  child: Container(
    color: Colors.white,
    child: ListView.builder(
      itemCount: _guestRecords.length,
      itemBuilder: (context, index) {
        final guest = _guestRecords[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text(
              guest['guest_name']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Guest Address
                  Text('Address: ${guest['guest_address']}'),
                  // Phone Number
                  Text('Phone: ${guest['phone_number']}'),
                  // Email ID
                  Text('Email: ${guest['email']}'),
                  // Anniversary
                  Text('Anniversary: ${guest['anniversary']}'),
                  // Date of Birth
                  Text('DOB: ${guest['dob']}'),
                  // GST Number
                  Text('GST No.: ${guest['gst_no']}'),
                  // Company Name
                  Text('Company: ${guest['company_name']}'),
                  // Discount
                  Text('Discount: ${guest['discount']}'),
                  // Suggestion
                  Text('Suggestion: ${guest['g_suggestion']}'),
                ],
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Implement editing functionality here
              },
            ),
          ),
        );
      },
    ),
  ),
),

          ],
        ),
      ),
    );
  }
}
