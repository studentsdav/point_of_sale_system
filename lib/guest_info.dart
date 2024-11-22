import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:point_of_sale_system/backend/guest_record_api_service.dart'; // To format the date

class GuestRegistrationScreen extends StatefulWidget {
  @override
  _GuestRegistrationScreenState createState() =>
      _GuestRegistrationScreenState();
}

class _GuestRegistrationScreenState extends State<GuestRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final GuestRecordApiService apiService =
      GuestRecordApiService(baseUrl: 'http://localhost:3000/api');
  String? _guestId = 'G100'; // Set default Guest ID
  String? _guestName;
  String? _phoneNumber;
  String? _address;
  String? _email;
  DateTime? _anniversary;
  DateTime? _dob;
  String? _gstNo;
  String? _companyName;
  String? _discount;
  String? _gSuggestion;

  List<String> outlets = []; // List of outlets to select from
  List<dynamic> properties = [];
  List<dynamic> outletConfigurations = [];
  // Table data for displaying the guest records
  List<Map<String, dynamic>> _guestRecords = [];

  @override
  void initState() {
    super.initState();
    _loadDataFromHive();
    _fetchGuestRecords();
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

  // Function to handle form submission
  void _addGuest() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> newGuest = {
        'date_joined':
            DateTime.now().toIso8601String(), // ISO format for current date
        'guest_name': _guestName!,
        'guest_address': _address!,
        'phone_number': _phoneNumber!,
        'email': _email!,
        'anniversary': _anniversary!.toIso8601String(),
        'dob': _dob!.toIso8601String(),
        'gst_no': _gstNo!,
        'company_name': _companyName!,
        'discount': _discount!,
        'g_suggestion': _gSuggestion!,
        'property_id': properties[0]
            ['property_id'], // Replace with actual property ID
      };

      try {
        Map<String, dynamic> response =
            await apiService.createGuestRecord(newGuest);

        setState(() {
          _guestRecords.add(response);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Guest added successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _fetchGuestRecords() async {
    try {
      List<Map<String, dynamic>> guests = await apiService.getGuestRecords();

      setState(() {
        _guestRecords = guests;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching guest records: $e')),
      );
    }
  }

  void _deleteGuest(String guestId, int index) async {
    try {
      await apiService.deleteGuestRecord(guestId);

      setState(() {
        _guestRecords.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Guest deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting guest: $e')),
      );
    }
  }

  void _editGuest(String guestId, Map<String, dynamic> updatedData) async {
    try {
      Map<String, dynamic> updatedGuest =
          await apiService.updateGuestRecord(guestId, updatedData);

      // Update local state
      int index =
          _guestRecords.indexWhere((guest) => guest['guest_id'] == guestId);
      if (index != -1) {
        setState(() {
          _guestRecords[index] = updatedGuest;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Guest updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating guest: $e')),
      );
    }
  }

  // Function to open date picker and return formatted date

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
                      // // Guest ID (non-editable)
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: TextFormField(
                      //     initialValue: _guestId,
                      //     decoration: InputDecoration(
                      //       labelText: 'Guest ID',
                      //       prefixIcon: Icon(Icons.card_travel),
                      //       border: OutlineInputBorder(),
                      //     ),
                      //     enabled: false, // Make Guest ID non-editable
                      //   ),
                      // ),
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
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly, // Restricts input to digits only
                          ],
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
                      // Anniversary (Date Picker)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Anniversary',
                            prefixIcon: Icon(Icons.cake),
                            border: OutlineInputBorder(),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null)
                              setState(() => _anniversary = pickedDate);
                          },
                          validator: (_) => _anniversary == null
                              ? 'Please select a Anniversary date'
                              : null,
                          controller: TextEditingController(
                            text: _anniversary == null
                                ? ''
                                : "${_anniversary!.day}-${_anniversary!.month}-${_anniversary!.year}",
                          ),
                          readOnly: true, // Prevent text input
                        ),
                      ),
                      // Date of Birth (Date Picker)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'DOB',
                            prefixIcon: Icon(Icons.cake),
                            border: OutlineInputBorder(),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null)
                              setState(() => _dob = pickedDate);
                          },
                          validator: (_) =>
                              _dob == null ? 'Please select a DOB date' : null,
                          controller: TextEditingController(
                            text: _dob == null
                                ? ''
                                : "${_dob!.day}-${_dob!.month}-${_dob!.year}",
                          ),
                          readOnly: true, // Prevent text input
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
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly, // Restricts input to digits only
                          ],
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(Icons.save),
                              onPressed: _addGuest,
                              label: Text('Add'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Right panel - Guest Table
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Text(
                      'Guest Records',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _guestRecords.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              'Guest ID: ${_guestRecords[index]['guest_id']}',
                            ),
                            subtitle: Text(
                              'Guest Name: ${_guestRecords[index]['guest_name']}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize
                                  .min, // Ensure the Row does not take up extra space
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    // Open edit form with guest data
                                    // _editGuest(
                                    //   _guestRecords[index]['guest_id']
                                    //       .toString(),
                                    //   {
                                    //     'date_joined': DateTime.now()
                                    //         .toIso8601String(), // ISO format for current date
                                    //     'guest_name': _guestName!,
                                    //     'guest_address': _address!,
                                    //     'phone_number': _phoneNumber!,
                                    //     'email': _email!,
                                    //     'anniversary':
                                    //         _anniversary!.toIso8601String(),
                                    //     'dob': _dob!.toIso8601String(),
                                    //     'gst_no': _gstNo!,
                                    //     'company_name': _companyName!,
                                    //     'discount': _discount!,
                                    //     'g_suggestion': _gSuggestion!,
                                    //     'property_id': properties[0][
                                    //         'property_id'], // Replace with actual property ID
                                    //   },
                                    // );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteGuest(
                                        _guestRecords[index]['guest_id']
                                            .toString(),
                                        index);
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GuestProfileScreen(
                                    guestData: _guestRecords[index],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Delete Guest details
}

class GuestProfileScreen extends StatelessWidget {
  final Map<String, dynamic> guestData;

  // Constructor to receive guest data
  const GuestProfileScreen({Key? key, required this.guestData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guest Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(100),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildDetailRow(
                      'Guest ID', guestData['guest_id']!.toString()),
                  _buildDetailRow(
                      'Date Joined', _formatDate(guestData['date_joined']!)),
                  _buildDetailRow('Guest Name', guestData['guest_name']!),
                  _buildDetailRow('Phone Number', guestData['phone_number']!),
                  _buildDetailRow('Email', guestData['email']!),
                  _buildDetailRow('Address', guestData['guest_address']!),
                  _buildDetailRow(
                      'Anniversary', _formatDate(guestData['anniversary']!)),
                  _buildDetailRow('DOB', _formatDate(guestData['dob']!)),
                  _buildDetailRow('GST No.', guestData['gst_no']!),
                  _buildDetailRow('Company Name', guestData['company_name']!),
                  _buildDetailRow('Discount', guestData['discount']!),
                  _buildDetailRow(
                      'Guest Suggestion', guestData['g_suggestion']!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

  // Helper function to build the detail rows
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '$title:  ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
