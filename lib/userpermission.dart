import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:point_of_sale_system/backend/user_permissions.dart';

class UserPermissionForm extends StatefulWidget {
  @override
  _UserPermissionFormState createState() => _UserPermissionFormState();
}

class _UserPermissionFormState extends State<UserPermissionForm> {
  final _formKey = GlobalKey<FormState>();
  UserPermissionApiService userPermissionApiService =
      UserPermissionApiService(baseUrl: 'http://localhost:3000/api');
  List<String> selectedOutlets = [];
  List<String> selectedUsers = []; // List to store selected user ids
  Map<String, List<String>> userPermissions =
      {}; // Map to store user permissions

  // Example lists for outlets, users, and permissions
  List<Map<String, dynamic>> users = [];
  String? selectedOutlet; // Only one outlet can be selected
  List<Map<String, dynamic>> permissions = [
    {'name': 'View Sales', 'description': 'Allows viewing sales reports'},
    {'name': 'Generate KOT', 'description': 'Allows generating KOT'},
    {'name': 'Modify', 'description': 'Allows modifying records'},
    {'name': 'Delete', 'description': 'Allows deleting records'},
    {
      'name': 'Edit Configurations',
      'description': 'Allows editing software configurations'
    },
    {'name': 'Admin Part', 'description': 'Access to admin functionalities'},
    {'name': 'Reports', 'description': 'Access to reports generation'},
    // Add more permissions here
  ];
  String? selectedOutletName;
  List<String> savedOutlets = [];
  List<Map<String, dynamic>> outlets = [];
  Map<String, List<String>> savedUserPermissions =
      {}; // Store saved user permissions

  List<dynamic> properties = [];
  List<dynamic> outletConfigurations = [];
  @override
  void initState() {
    super.initState();
    _loadDataFromHive();
    // Defer the execution of _loadPermissionsFromDatabase
    Future.delayed(Duration.zero, _loadPermissionsFromDatabase);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Call this method after the widget tree is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPermissionsFromDatabase();
    });
  }

  // Load data from Hive
  Future<void> _loadDataFromHive() async {
    var box = await Hive.openBox('appData');
    var boxnew = await Hive.openBox('appDatauser');

    // Retrieve the data
    var userlist = boxnew.get('users');
    var properties = box.get('properties');
    var outletConfigurations = box.get('outletConfigurations');
    List<Map<String, dynamic>> userslist = [];
    // Check if outletConfigurations is not null
    if (outletConfigurations != null) {
      // Extract the outlet names into the outlets list
      List<Map<String, dynamic>> outletslist = [];
      for (var outlet in outletConfigurations) {
        if (outlet['outlet_name'] != null) {
          outletslist.add({
            'outlet_id': outlet['id'].toString(),
            'outlet_name': outlet['outlet_name'].toString(),
          });
        }
      }
      if (userlist != null) {
        for (var user in userlist) {
          if (user['username'] != null && user['user_id'] != null) {
            userslist.add({
              'username': user['username'].toString(),
              'user_id': user['user_id'].toString(),
            });
          }
        }
      }
      setState(() {
        this.properties = properties ?? [];
        this.outletConfigurations = outletConfigurations ?? [];
        this.outlets = outletslist; // Set the outlets list
        this.users = userslist;
      });
    }
  }

  String? getOutletIdByName(String outletName) {
    for (var outlet in outlets) {
      if (outlet['outlet_name'] == outletName) {
        return outlet['outlet_id'].toString();
      }
    }
    return null; // Return null if no matching outlet is found
  }

  Future<String?> getPermissionId(userId, outletId, requiredPermission) async {
    try {
      // Fetch all permissions from the API
      List<Map<String, dynamic>> permissions =
          await userPermissionApiService.getAllUserPermissions();

      // Check if the provided outlet and user match any entry
      for (var permission in permissions) {
        if (permission['outlet_id'].toString() == outletId &&
            permission['user_id'].toString() == userId &&
            permission['permission_name'] == requiredPermission) {
          return permission['id'].toString(); // Return the permission ID
        }
      }

      return null; // No match found
    } catch (error) {
      throw Exception('Error checking permissions: $error');
    }
  }

  void _savePermissionsToDatabase(outlet) async {
    try {
      String? outletId = getOutletIdByName(outlet[0]);

      if (outletId == null) {
        throw 'Outlet ID not found for the provided name: ${outlet[0]}';
      }

      for (var userId in selectedUsers) {
        for (var permission in userPermissions[userId] ?? []) {
          String? username = users.firstWhere(
              (user) => user['user_id'].toString() == userId.toString(),
              orElse: () => {'username': null})['username'];
          Map<String, dynamic> data = {
            'user_id': userId,
            'outlet_id': outletId, // Use the retrieved outlet ID
            'outlet_name': outlet[0],
            'permission_name': permission,
            'property_id': properties[0]['property_id'],
            'username': username
          };

          // Validate if the permission already exists
          var exists = await getPermissionId(userId, outletId, permission);

          if (exists != null) {
            // Call update API if permission exists
            _updatePermission(exists, data);
          } else {
            // Call create API if permission does not exist
            await userPermissionApiService.createUserPermission(data);
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permissions saved to database successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving permissions: $error')),
      );
    }
  }

  void _loadPermissionsFromDatabase() async {
    try {
      // Ensure a single outlet is selected before loading data
      if (selectedOutlets.isEmpty) {
        throw Exception('No outlet selected. Please select an outlet first.');
      }
      String selectedOutlet =
          selectedOutlets.first; // Get the single selected outlet

      // Fetch permissions from the API
      List<Map<String, dynamic>> permissions =
          await userPermissionApiService.getAllUserPermissions();

      setState(() {
        savedUserPermissions = {}; // Clear previous data
        savedOutlets = []; // Clear previously saved outlets

        for (var permission in permissions) {
          // Check if the permission matches the selected outlet
          if (permission['outlet_name'].toString() == selectedOutlet) {
            String userId = permission['user_id'].toString();

            // Initialize permissions for this user if not already
            savedUserPermissions[userId] ??= [];
            userPermissions[userId] ??= [];

            // Add permission if not already added
            if (!savedUserPermissions[userId]!
                .contains(permission['permission_name'])) {
              savedUserPermissions[userId]!.add(permission['permission_name']);
            }

            // Synchronize with userPermissions
            if (!userPermissions[userId]!
                .contains(permission['permission_name'])) {
              userPermissions[userId]!.add(permission['permission_name']);
            }
          }
        }

        // Update saved outlets to match the selected one
        savedOutlets = [selectedOutlet];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Permissions loaded successfully for the selected outlet')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading permissions: $error')),
      );
    }
  }

  void _updatePermission(String id, Map<String, dynamic> updatedData) async {
    try {
      await userPermissionApiService.updateUserPermission(id, updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission updated successfully')));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating permission: $error')));
    }
  }

  void _deletePermission(String id) async {
    try {
      await userPermissionApiService.deleteUserPermission(id);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission deleted successfully')));
      _loadPermissionsFromDatabase(); // Reload the data
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting permission: $error')));
    }
  }

  void _savePermissions() {
    if (_formKey.currentState!.validate() &&
        selectedUsers.isNotEmpty &&
        selectedOutlets.isNotEmpty) {
      _formKey.currentState!.save();

      // Save permissions logic (e.g., save to database)
      setState(() {
        savedOutlets = List.from(selectedOutlets);
        savedUserPermissions = Map.from(userPermissions);
        _savePermissionsToDatabase(selectedOutlets);
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permissions saved successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please select outlet, user, and permissions')));
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
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                          labelText: 'Select Outlet', icon: Icon(Icons.store)),
                      items: outlets.map((outlet) {
                        return DropdownMenuItem<String>(
                          value: outlet['outlet_name'],
                          child: Text(outlet['outlet_name']),
                        );
                      }).toList(),
                      value: selectedOutlets.isNotEmpty
                          ? selectedOutlets.first
                          : null,
                      onChanged: (value) {
                        setState(() {
                          selectedOutlets = [
                            value!
                          ]; // Allow only one outlet at a time
                        });
                        _loadPermissionsFromDatabase(); // Reload permissions for the selected outlet
                      },
                      validator: (value) =>
                          value == null ? 'Please select an outlet' : null,
                      hint: Text('Select an outlet'),
                      isExpanded: true,
                    ),

                    SizedBox(height: 16),
                    // Multi-select Users
                    Text('Select Users',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    ...users.map((user) {
                      return CheckboxListTile(
                        title: Text(user['username']),
                        value: selectedUsers.contains(user['user_id']),
                        onChanged: (isSelected) {
                          setState(() {
                            if (isSelected!) {
                              selectedUsers.add(user['user_id']);
                            } else {
                              selectedUsers.remove(user['user_id']);
                            }
                          });

                          _loadPermissionsFromDatabase(); // Reload permissions for the selected outlet
                        },
                      );
                    }).toList(),
                    SizedBox(height: 16),
                    // Individual Permissions for each user
                    Text('Select Permissions for each User',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    ...selectedUsers.map((userId) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Permissions for ${users.firstWhere((user) => user['user_id'] == userId)['username']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    // Assign all permissions for the user with explicit type casting
                                    userPermissions[userId] = permissions
                                        .map((perm) => perm['name'].toString())
                                        .toList();
                                  });
                                },
                                child: Text('Assign All Permissions'),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          ...permissions.map((permission) {
                            return CheckboxListTile(
                              title: Text(permission['name']),
                              subtitle: Text(permission['description']),
                              value: userPermissions[userId]
                                      ?.contains(permission['name']) ??
                                  false,
                              onChanged: (isSelected) {
                                setState(() {
                                  if (isSelected!) {
                                    userPermissions[userId] ??= [];
                                    userPermissions[userId]
                                        ?.add(permission['name']);
                                  } else {
                                    userPermissions[userId]
                                        ?.remove(permission['name']);
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
                    String userName = users.firstWhere(
                        (user) => user['user_id'] == userId)['username'];
                    List<String> permissions = entry.value;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            12.0), // Rounded corners for card
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
                                Icon(Icons.store,
                                    color: Colors.green, size: 18),
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
                                    child: ListTile(
                                      title: Text(
                                        permission,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      leading: Icon(Icons.check_circle,
                                          color: Colors.green, size: 18),
                                      trailing: IconButton(
                                        onPressed: () {
                                          print(permissions);
                                          print(
                                              "Delete permission: $permission");
                                        },
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                      ),
                                    ));
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
