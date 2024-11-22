import 'package:flutter/material.dart';

class ReservationFormScreen extends StatefulWidget {
  @override
  _ReservationFormScreenState createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _guestName;
  String? _contactInfo;
  String? _address;
  String? _email;
  DateTime _reservationDate = DateTime.now();
  TimeOfDay _reservationTime = TimeOfDay.now();
  int? _tableNo;
  String? _bookingNo = 'RES12345'; // Mock booking number
  String? _status = 'Booked';

  // List of available tables
  final List<int> _tableNumbers = [1, 2, 3, 4, 5];

  // Reservation Data (You can replace this with actual dynamic data)
  List<Map<String, String>> _reservations = [];

  // Function to handle form submission
  void _submitReservation() {
    if (_formKey.currentState!.validate()) {
      // Create reservation data
      final reservationData = {
        'guest_name': _guestName ?? '',
        'contact_info': _contactInfo ?? '',
        'address': _address ?? '',
        'email': _email ?? '',
        'reservation_date': _reservationDate.toIso8601String(),
        'reservation_time': _reservationTime.format(context),
        'table_no': _tableNo.toString(),
        'status': _status ?? '',
      };

      // Add the new reservation to the list
      setState(() {
        _reservations.add(reservationData);
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reservation successfully made!')),
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
      _tableNo = null;
      _status = 'Cancelled';
    });

    // Show cancel message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reservation Cancelled')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservation Form'),
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
                constraints: BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 10)],
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Booking Number (Non-editable)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: _bookingNo,
                          decoration: InputDecoration(
                            labelText: 'Booking Number',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.bookmark), // Icon added here
                          ),
                          enabled: false, // Non-editable
                        ),
                      ),
                      // Guest Name
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
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
                          decoration: InputDecoration(
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
                          decoration: InputDecoration(
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
                          decoration: InputDecoration(
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
                              'Reservation Date: ${_reservationDate.toLocal()}'
                                  .split(' ')[0],
                              style: TextStyle(fontSize: 16),
                            ),
                            ElevatedButton(
                              onPressed: () => _selectReservationDate(context),
                              child: Text('Pick Date'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
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
                              style: TextStyle(fontSize: 16),
                            ),
                            ElevatedButton(
                              onPressed: () => _selectReservationTime(context),
                              child: Text('Pick Time'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Table Number Dropdown
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<int>(
                          value: _tableNo,
                          decoration: InputDecoration(
                            labelText: 'Table No',
                            border: OutlineInputBorder(),
                            prefixIcon:
                                Icon(Icons.table_chart), // Icon added here
                          ),
                          items: _tableNumbers.map((tableNo) {
                            return DropdownMenuItem<int>(
                              value: tableNo,
                              child: Text('Table $tableNo'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _tableNo = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a table number';
                            }
                            return null;
                          },
                        ),
                      ),
                      // Buttons: Book and Cancel
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: _submitReservation,
                              child: Text('Submit Reservation'),
                            ),
                            ElevatedButton(
                              onPressed: _cancelReservation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: Text('Cancel Reservation'),
                            ),
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
                constraints: BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 10)],
                ),
                child: ListView(
                  children: _reservations.map((reservation) {
                    return ListTile(
                      title: Text(reservation['guest_name'] ?? ''),
                      subtitle: Text(
                          'Date: ${reservation['reservation_date']} | Time: ${reservation['reservation_time']}'),
                      trailing: Text('Table No: ${reservation['table_no']}'),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
