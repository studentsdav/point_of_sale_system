import 'package:flutter/material.dart';

class UserPermissionForm extends StatefulWidget {
  @override
  _UserPermissionFormState createState() => _UserPermissionFormState();
}

class _UserPermissionFormState extends State<UserPermissionForm> {
  final _formKey = GlobalKey<FormState>();
  List<String> selectedOutlets = [];
  List<String> selectedUsers = []; // List to store selected user ids
  Map<String, List<String>> userPermissions = {}; // Map to store user permissions
  
  // Example lists for outlets, users, and permissions
  List<Map<String, dynamic>> users = [
    {'id': '1', 'name': 'User 1'},
    {'id': '2', 'name': 'User 2'},
    {'id': '3', 'name': 'User 3'},
  ];

  List<Map<String, dynamic>> permissions = [
    {'name': 'View Sales', 'description': 'Allows viewing sales reports'},
    {'name': 'Generate KOT', 'description': 'Allows generating KOT'},
    {'name': 'Modify', 'description': 'Allows modifying records'},
    {'name': 'Delete', 'description': 'Allows deleting records'},
    {'name': 'Edit Configurations', 'description': 'Allows editing software configurations'},
    {'name': 'Admin Part', 'description': 'Access to admin functionalities'},
    {'name': 'Reports', 'description': 'Access to reports generation'},
    // Add more permissions here
  ];

  List<String> savedOutlets = [];
  Map<String, List<String>> savedUserPermissions = {}; // Store saved user permissions
  
  void _savePermissions() {
    if (_formKey.currentState!.validate() && selectedUsers.isNotEmpty && selectedOutlets.isNotEmpty) {
      _formKey.currentState!.save();

      // Save permissions logic (e.g., save to database)
      setState(() {
        savedOutlets = List.from(selectedOutlets);
        savedUserPermissions = Map.from(userPermissions);
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permissions saved successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select outlet, user, and permissions')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Permission Configuration')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Multiple outlets selection
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Select Outlet(s)', icon: Icon(Icons.store)),
                      items: ['Outlet 1', 'Outlet 2', 'Outlet 3'].map((outlet) {
                        return DropdownMenuItem<String>(
                          value: outlet,
                          child: Text(outlet),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedOutlets.add(value!)),
                      validator: (value) => value == null ? 'Please select an outlet' : null,
                      hint: Text('Select multiple outlets'),
                      isExpanded: true,
                    ),
                    SizedBox(height: 16),
                    // Multi-select Users
                    Text('Select Users', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ...users.map((user) {
                      return CheckboxListTile(
                        title: Text(user['name']),
                        value: selectedUsers.contains(user['id']),
                        onChanged: (isSelected) {
                          setState(() {
                            if (isSelected!) {
                              selectedUsers.add(user['id']);
                            } else {
                              selectedUsers.remove(user['id']);
                            }
                          });
                        },
                      );
                    }).toList(),
                    SizedBox(height: 16),
                    // Individual Permissions for each user
                    Text('Select Permissions for each User', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ...selectedUsers.map((userId) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Permissions for ${users.firstWhere((user) => user['id'] == userId)['name']}'),
                          ...permissions.map((permission) {
                            return CheckboxListTile(
                              title: Text(permission['name']),
                              subtitle: Text(permission['description']),
                              value: userPermissions[userId]?.contains(permission['name']) ?? false,
                              onChanged: (isSelected) {
                                setState(() {
                                  if (isSelected!) {
                                    if (userPermissions[userId] == null) {
                                      userPermissions[userId] = [];
                                    }
                                    userPermissions[userId]?.add(permission['name']);
                                  } else {
                                    userPermissions[userId]?.remove(permission['name']);
                                  }
                                });
                              },
                            );
                          }).toList(),
                          SizedBox(height: 16),
                        ],
                      );
                    }).toList(),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _savePermissions,
                      child: Text('Save Permissions'),
                    ),
                  ],
                ),
              ),
   SizedBox(height: 32),
// Display Saved Values - Each user in a separate ListView
if (savedUserPermissions.isNotEmpty)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: savedUserPermissions.entries.map((entry) {
      String userId = entry.key;
      String userName = users.firstWhere((user) => user['id'] == userId)['name'];
      List<String> permissions = entry.value;

      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Rounded corners for card
        ),
        margin: EdgeInsets.symmetric(vertical: 8),
        elevation: 4, // Shadow for the card
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display user name with bold and larger font
              Text(
                'User: $userName',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent, // User name in blue
                ),
              ),
              SizedBox(height: 8),
              // Display outlets with icons
              Row(
                children: [
                  Icon(Icons.store, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Outlets: ${savedOutlets.join(', ')}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Permissions section with divider and stylish text
              Divider(thickness: 1, color: Colors.grey.shade300),
              SizedBox(height: 8),
              Text(
                'Permissions:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepOrange,
                ),
              ),
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: permissions.map((permission) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Text(
                          permission,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      );
    }).toList(),
  ),

            ],
          ),
        ),
      ),
    );
  }
}
