import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:point_of_sale_system/backend/reservationApiService.dart';

class ReservationFormScreen extends StatefulWidget {
  const ReservationFormScreen({super.key});

  @override
  _ReservationFormScreenState createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  ReservationApiService reservationApiService =
      ReservationApiService(baseUrl: 'http://localhost:3000/api');
  final _formKey = GlobalKey<FormState>();
  String? _guestName;
  String? _contactInfo;
  String? _address;
  String? _email;
  String? _remark;
  DateTime _reservationDate = DateTime.now();
  TimeOfDay _reservationTime = TimeOfDay.now();
  // String? _bookingNo = 'RES12345'; // Mock booking number
  String? _status = 'Booked';
  String? selectedOutlet;
  // List of available tables
  List<String> _tableNumbers = [];

  // Reservation Data (You can replace this with actual dynamic data)
  List<dynamic> _reservations = [];
  List<String> outlets = []; // List of outlets to select from
  List<dynamic> properties = [];
  List<dynamic> outletConfigurations = [];

  String? _selectedTable;
  Map<String, String>? _selectedReservation;

  @override
  void initState() {
    super.initState();
    _loadDataFromHive();
    _loadReservations();
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
        outlets = outletslist; // Set the outlets list
      });
    }
  }

  Future<void> _filterTablesByOutlet(String selectedOutlet) async {
    var box = await Hive.openBox('appData');
    var tables = box.get('tables');
    // Check if the tables and outletConfigurations are not null
    if (tables != null) {
      List<String> filteredTables = [];

      // Loop through the tables and find those matching the selected outlet
      for (var table in tables!) {
        if (table['outlet_name'].toString().toLowerCase() ==
                selectedOutlet.toLowerCase() &&
            table['table_no'] != null) {
          filteredTables.add(table['table_no'].toString());
        }
      }

      // Update the state with the filtered tables
      setState(() {
        _tableNumbers = filteredTables;
      });
    }
  }

  Future<void> _loadReservations() async {
    try {
      final reservations = await reservationApiService.getReservations();

      setState(() {
        _reservations = reservations; // Update local reservation list
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reservations: $e')),
      );
    }
  }

  // Function to handle form submission
  Future<void> _submitReservation() async {
    if (_formKey.currentState!.validate()) {
      // Prepare reservation data
      final reservationData = {
        'guest_name': _guestName ?? '',
        'contact_info': _contactInfo ?? '',
        'address': _address ?? '',
        'email': _email ?? '',
        'reservation_date': _reservationDate.toIso8601String(),
        'reservation_time': _reservationTime.format(context),
        'table_no': _selectedTable.toString(),
        'status': _status ?? '',
        'outlet_name': selectedOutlet.toString(),
        'remark': _remark.toString(),
        'property_id': properties.isNotEmpty
            ? properties[0]['property_id']
            : null // If property data exists, add it
      };

      try {
        // Call the API to create the reservation
        await reservationApiService.createReservation(reservationData);

        // Assuming the API returns the newly created reservation
        setState(() {
          _reservations.add(reservationData); // Update local reservation list
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation successfully made!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create reservation: $e')),
        );
      }
    }
  }

  Future<void> _updateReservation(String reservationId) async {
    if (_formKey.currentState!.validate()) {
      final updatedReservationData = {
        'guest_name': _guestName ?? '',
        'contact_info': _contactInfo ?? '',
        'address': _address ?? '',
        'email': _email ?? '',
        'reservation_date': _reservationDate.toIso8601String(),
        'reservation_time': _reservationTime.format(context),
        'table_no': _selectedTable.toString(),
        'status': _status ?? '',
        'outlet_name': selectedOutlet.toString(),
        'remark': _remark.toString(),
      };

      try {
        // Update the reservation via API

        final response = await reservationApiService.updateReservation(
            reservationId, updatedReservationData);

        // Update local reservation list (assuming the API returns the updated reservation)
        setState(() {
          final index =
              _reservations.indexWhere((res) => res['id'] == reservationId);
          if (index != -1) {
            _reservations[index] =
                response; // Update the reservation in the list
          }
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update reservation: $e')),
        );
      }
    }
  }

  Future<void> _deleteReservation(String reservationId, String tableno) async {
    try {
      await reservationApiService.deleteReservation(reservationId, tableno);

      // Remove the reservation from the local list
      setState(() {
        _reservations.removeWhere((res) => res['id'] == reservationId);
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete reservation: $e')),
      );
    }
  }

  // Date Picker
  Future<void> _selectReservationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _reservationDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _reservationDate) {
      setState(() {
        _reservationDate = picked;
      });
    }
  }

  // Time Picker
  Future<void> _selectReservationTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reservationTime,
    );
    if (picked != null && picked != _reservationTime) {
      setState(() {
        _reservationTime = picked;
      });
    }
  }

  // Cancel Reservation
  void _cancelReservation() {
    // Clear all form fields or show a cancel message
    setState(() {
      _guestName = null;
      _contactInfo = null;
      _address = null;
      _email = null;
      _reservationDate = DateTime.now();
      _reservationTime = TimeOfDay.now();
      _selectedTable = null;
      _remark = "";
      _status = 'Cancelled';
    });

    // Show cancel message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reservation Cancelled')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Form'),
      ),
      body: Row(
        children: [
          // Left Panel: Reservation Form
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.grey, blurRadius: 10)
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Outlet Selection (Mandatory)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.store),
                            border: OutlineInputBorder(),
                            labelText: 'Select Outlet',
                          ),
                          items: outlets.map((outlet) {
                            return DropdownMenuItem(
                                value: outlet, child: Text(outlet));
                          }).toList(),
                          onChanged: (value) => setState(() {
                            _selectedTable = null;
                            selectedOutlet = value!;
                            _filterTablesByOutlet(selectedOutlet!);
                          }),
                          validator: (value) =>
                              value == null ? 'Please select an outlet' : null,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // // Booking Number (Non-editable)
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: TextFormField(
                      //     initialValue: _bookingNo,
                      //     decoration: InputDecoration(
                      //       labelText: 'Booking Number',
                      //       border: OutlineInputBorder(),
                      //       prefixIcon: Icon(Icons.bookmark), // Icon added here
                      //     ),
                      //     enabled: false, // Non-editable
                      //   ),
                      // ),
                      // Guest Name
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Guest Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person), // Icon added here
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
                      // Address
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder(),
                            prefixIcon:
                                Icon(Icons.location_on), // Icon added here
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
                      // Contact Info
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly, // Restricts input to digits only
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Mobile Number',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone), // Icon added here
                          ),
                          onChanged: (value) {
                            setState(() {
                              _contactInfo = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter contact information';
                            }
                            return null;
                          },
                        ),
                      ),
                      // Email
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email), // Icon added here
                          ),
                          onChanged: (value) {
                            setState(() {
                              _email = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the email';
                            }
                            return null;
                          },
                        ),
                      ),
                      // Reservation Date (Date Picker)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reservation Date: ${_formatDate(_reservationDate)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            ElevatedButton(
                              onPressed: () => _selectReservationDate(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text('Pick Date'),
                            ),
                          ],
                        ),
                      ),
                      // Reservation Time (Time Picker)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reservation Time: ${_reservationTime.format(context)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            ElevatedButton(
                              onPressed: () => _selectReservationTime(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text('Pick Time'),
                            ),
                          ],
                        ),
                      ),
                      // Table Number Dropdown
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          value: _selectedTable, // Currently selected table
                          decoration: const InputDecoration(
                            labelText: 'Select Table',
                            border: OutlineInputBorder(),
                            prefixIcon:
                                Icon(Icons.table_chart), // Icon for tables
                          ),
                          items: _tableNumbers.map((tableNo) {
                            return DropdownMenuItem<String>(
                              value: tableNo,
                              child: Text('Table $tableNo'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTable =
                                  value; // Update the selected table
                            });
                          },
                        ),
                      ),
                      // Remark
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Remark',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.message), // Icon added here
                          ),
                          onChanged: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                _remark = "";
                              } else {
                                _remark = value;
                              }
                            });
                          },
                        ),
                      ),
                      // Reservation Date (Date Picker)
                      // Buttons: Book and Cancel
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _submitReservation,
                              child: const Text('Submit Reservation'),
                            ),
                            // ElevatedButton(
                            //   onPressed: _cancelReservation,
                            //   style: ElevatedButton.styleFrom(
                            //     backgroundColor: Colors.red,
                            //   ),
                            //   child: Text('Cancel Reservation'),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Right Panel: Reservation Data
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.grey, blurRadius: 10)
                  ],
                ),
                child: ListView.builder(
                  itemCount: _reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = _reservations[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text(
                            reservation['guest_name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                  'Date: ${_formatDate(reservation['reservation_date'])}'),
                              Text('Time: ${reservation['reservation_time']}'),
                              Text('Table No: ${reservation['table_no']}'),
                              Text('Outlet: ${reservation['outlet_name']}'),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              _selectedReservation = {
                                'guest_name':
                                    reservation['guest_name'].toString(),
                                'contact_info':
                                    reservation['contact_info'].toString(),
                                'address': reservation['address'].toString(),
                                'email': reservation['email'].toString(),
                                'reservation_date':
                                    reservation['reservation_date'].toString(),
                                'reservation_time':
                                    reservation['reservation_time'].toString(),
                                'table_no': reservation['table_no'].toString(),
                                'outlet_name':
                                    reservation['outlet_name'].toString(),
                                'remark': reservation['remark'].toString(),
                              };
                            });
                            _showReservationDialog(context);
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  // Handle edit logic
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _reservations.removeAt(index);
                                  });
                                  _deleteReservation(
                                    reservation['id'].toString(),
                                    reservation['table_no'].toString(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReservationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reservation Details'),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.grey, blurRadius: 10)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: const Text('Guest Name:'),
                      subtitle: Text(_selectedReservation!['guest_name'] ?? ''),
                    ),
                    ListTile(
                      title: const Text('Contact Info:'),
                      subtitle:
                          Text(_selectedReservation!['contact_info'] ?? ''),
                    ),
                    ListTile(
                      title: const Text('Address:'),
                      subtitle: Text(_selectedReservation!['address'] ?? ''),
                    ),
                    ListTile(
                      title: const Text('Email:'),
                      subtitle: Text(_selectedReservation!['email'] ?? ''),
                    ),
                    ListTile(
                      title: const Text('Reservation Date:'),
                      subtitle: Text(_formatDate(
                          _selectedReservation!['reservation_date'])),
                    ),
                    ListTile(
                      title: const Text('Reservation Time:'),
                      subtitle:
                          Text(_selectedReservation!['reservation_time'] ?? ''),
                    ),
                    ListTile(
                      title: const Text('Table No:'),
                      subtitle: Text(_selectedReservation!['table_no'] ?? ''),
                    ),
                    ListTile(
                      title: const Text('Outlet:'),
                      subtitle:
                          Text(_selectedReservation!['outlet_name'] ?? ''),
                    ),
                    ListTile(
                      title: const Text('Remark:'),
                      subtitle: Text(_selectedReservation!['remark'] ?? ''),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
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
}
