import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _joinDateController = TextEditingController();

  String? _username;
  String? _fullName;
  DateTime _dob = DateTime(1990, 1, 1);
  String? _mobileNo;
  String? _email;
  String? _password;
  String? _selectedOutlet;
  DateTime _joinDate = DateTime.now();
  String _status = "Active";
  String? _role;
  List<String> outlets = ["Outlet 1", "Outlet 2", "Outlet 3"];
  String? selectedStatus;

  // Simulated list of existing usernames
  List<String> existingUsernames = ["john_doe", "jane_doe", "admin"];
  List<Map<String, dynamic>> users = [];

  void toggleStatus() {
    setState(() {
      _status = (_status == "Active") ? "Inactive" : "Active";
    });
  }

  Future<void> _selectDate(BuildContext context, bool isDob) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        if (isDob) {
          _dob = selectedDate;
          _dobController.text = "${_dob.toLocal()}".split(' ')[0];
        } else {
          _joinDate = selectedDate;
          _joinDateController.text = "${_joinDate.toLocal()}".split(' ')[0];
        }
      });
    }
  }

  void saveUserProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        users.add({
          "username": _username,
          "fullName": _fullName,
          "dob": _dob,
          "mobileNo": _mobileNo,
          "email": _email,
          "joinDate": _joinDate,
          "status": _status,
          "selectedOutlet": _selectedOutlet,
          "role": _role,
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User Profile Saved")));
    }
  }

  void editProfile(int index) {
    // Populate the form fields with the selected user's data
    setState(() {
      _username = users[index]['username'];
      _fullName = users[index]['fullName'];
      _dob = users[index]['dob'];
      _mobileNo = users[index]['mobileNo'];
      _email = users[index]['email'];
      _joinDate = users[index]['joinDate'];
      _status = users[index]['status'];
      _selectedOutlet = users[index]['selectedOutlet'];
      _role = users[index]['role'];
    });
  }

  void deleteProfile(int index) {
    setState(() {
      users.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User Profile Deleted")));
  }

  String? _usernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }

    // Check if username is unique
    if (existingUsernames.contains(value)) {
      return 'Username already taken. Please choose another one';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                    ),
                    onChanged: (value) {
                      _username = value;
                    },
                    validator: _usernameValidator,  // Use the username validator here
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    onChanged: (value) {
                      _fullName = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _dobController,
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    onChanged: (value) {
                      _mobileNo = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    onChanged: (value) {
                      _email = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
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
                    decoration: InputDecoration(
                      labelText: 'Select Outlet',
                      prefixIcon: Icon(Icons.store),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an outlet';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    onChanged: (value) {
                      _password = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _joinDateController,
                        decoration: InputDecoration(
                          labelText: 'Join Date',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _role,
                    onChanged: (newValue) {
                      setState(() {
                        _role = newValue;
                      });
                    },
                    items: ['admin', 'user', 'manager', 'super admin']
                        .map((role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Role',
                      prefixIcon: Icon(Icons.group),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a role';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: saveUserProfile,
                    child: Text('Save Profile'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            // Display List of Users
            if (users.isNotEmpty)
              ...users.map((user) {
                int index = users.indexOf(user);
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(user['username'] ?? ''),
                    subtitle: Text(user['fullName'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => editProfile(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteProfile(index),
                        ),
                      ],
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('User Details'),
                            content: Column(mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Username: ${user['username']}'),
                                Text('Full Name: ${user['fullName']}'),
                                Text('Date of Birth: ${user['dob']}'),
                                Text('Mobile No: ${user['mobileNo']}'),
                                Text('Email: ${user['email']}'),
                                Text('Join Date: ${user['joinDate']}'),
                                Text('Status: ${user['status']}'),
                                Text('Role: ${user['role']}'),
                                Text('Outlet: ${user['selectedOutlet']}'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
