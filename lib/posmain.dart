import 'package:flutter/material.dart';
import 'package:point_of_sale_system/ItemMaster.dart';
import 'package:point_of_sale_system/admin.dart';
import 'package:point_of_sale_system/backend/table_api_service.dart';
import 'package:point_of_sale_system/bill_section.dart';
import 'package:point_of_sale_system/billing.dart';
import 'package:point_of_sale_system/guest_info.dart';
import 'package:point_of_sale_system/kotform.dart';
import 'package:point_of_sale_system/orderlist.dart';
import 'package:point_of_sale_system/payments.dart';
import 'package:point_of_sale_system/poslogin.dart';
import 'package:point_of_sale_system/reservation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class POSMainScreen extends StatefulWidget {
  final outlet;
  final propertyid;
  const POSMainScreen(
      {super.key, required this.outlet, required this.propertyid});

  @override
  _POSMainScreenState createState() => _POSMainScreenState();
}

class _POSMainScreenState extends State<POSMainScreen> {
  final tableapiService = TableApiService(apiUrl: 'http://localhost:3000/api');
  late IO.Socket socket;

  String selectedOutlet = 'Restaurant';
  List<String> outlets = [
    'Restaurant',
    'Bar',
    'Packing',
    'N.C. Order',
    'Swiggy',
    'Zomato',
    'Room Service'
  ];
  final Map<String, List<String>> areas = {
    // 'OPEN AREA': ['01', '02', '03', '04', '05', '06', '07', '08'],
    // 'HALL': ['01', '02', '03', '04'],
    // 'ROOF TOP': ['04', '05', '01', '02', '03', '04'],
    // 'GARDEN': ['01', '02', '03', '04', '05', '06', '07'],
    // 'VIP AREA': ['01', '02', '03', '04'],
  };

  final Map<String, String> tableStates = {
    // '1': 'occupied',
    // '2': 'vacant',
    // '3': 'dirty',
    // Add more table states here
  };

  Future<void> _fetchTableConfigs() async {
    try {
      final tables = await tableapiService.getTableConfigs();
      setState(() {
        tableStates.clear(); // Clear previous data if necessary

        for (var table in tables) {
          String tableNumber = table['table_no']
              .toString(); // Assuming table_no is the identifier
          String tableStatus =
              table['status'] ?? 'vacant'; // Assuming 'status' is the field
          tableStates[tableNumber] = tableStatus;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load tables')));
    }
  }

  @override
  void initState() {
    outlets = widget.outlet;
    // Load table configurations initially
    loadtables();
    _fetchTableConfigs();
    _initializeWebSocket();
    super.initState();
  }

  void _initializeWebSocket() {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'], // Force WebSocket transport
      'autoConnect': true,
    });

    socket.on('connect', (_) {
      print('Connected to WebSocket server');
    });

    socket.on('connect_error', (error) {
      print('Error connecting to WebSocket: $error');
    });

    socket.on('table_update', (data) async {
      try {
        print('Received update notification: $data');

        // Example: Update cache instead of refetching

        // If you want to refresh UI, you can call _fetchTableConfigs()
        //   loadtables();
        _fetchTableConfigs(); // Optionally refresh the UI
      } catch (error) {
        print('Error during table update handling: $error');
        // Optionally, throw error if necessary
        throw 'Error updating table state $error';
      }
    });

    socket.on('disconnect', (_) {
      print('Disconnected from WebSocket');
    });

    socket.connect();
  }

  void loadtables() async {
    try {
      // Fetch data from API
      final tableConfigs = await tableapiService.getTableConfigs();

      // Populate the map
      for (var table in tableConfigs) {
        final location = table['location'] as String; // Dynamic location
        final tableNo = table['table_no'] as String;

        // Add table numbers under their respective location
        if (!areas.containsKey(location)) {
          areas[location] = [];
        }
        setState(() {
          areas[location]?.add(tableNo);
        });
      }

      // Display location-wise tables
      print('Location-wise tables:');
      areas.forEach((location, tables) {
        print('$location: $tables');
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void loadtablesnew(selectedoutletnew) async {
    setState(() {
      areas.clear();
    });
    try {
      // Fetch data from API
      final tableConfigs = await tableapiService.getTableConfigs();

      final outletTables = tableConfigs.where((table) {
        return table['outlet_name'].toString().toLowerCase() ==
            selectedoutletnew;
      }).toList();

      for (var table in outletTables) {
        final location = table['location'] as String;
        final tableNo = table['table_no'] as String;

        // Add table numbers under their respective location

        if (!areas.containsKey(location)) {
          areas[location] = [];
        }
        setState(() {
          areas[location]?.add(tableNo);
        });
      }

      // Display location-wise tables for the selected outlet
      print('Tables for outlet "$selectedoutletnew":');
      areas.forEach((location, tables) {
        print('$location: $tables');
      });
    } catch (e) {
      print('Error: $e');
    }
    _fetchTableConfigs();
  }

  @override
  void dispose() {
    // Disconnect WebSocket when the widget is disposed
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        title: Row(
          children: [
            const Text(
              'Nourish Bistro and Cafe',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.mail),
            ),
            Text(
              'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.teal),
              accountName:
                  const Text('User A', style: TextStyle(color: Colors.white)),
              accountEmail: const Text('Session Started: 4h ago',
                  style: TextStyle(color: Colors.white70)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.teal),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem(Icons.home, 'Home', () {}),
                  _buildDrawerItem(Icons.book, 'Reservation', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReservationFormScreen()));
                  }),
                  _buildDrawerItem(Icons.swap_horiz, 'Table Shift', () {}),
                  _buildDrawerItem(Icons.receipt, 'Orders', () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => OrderList()));
                  }),
                  _buildDrawerItem(Icons.payment, 'Billing', () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => BillPage()));
                  }),
                  _buildDrawerItem(Icons.payment, 'Payment', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PaymentFormScreen(
                                  tableno: '1',
                                  billid: '1',
                                  propertyid: widget.propertyid,
                                  outletname: selectedOutlet,
                                )));
                  }),
                  _buildDrawerItem(Icons.report, 'Reports', () {}),
                  _buildDrawerItem(Icons.add_box, 'Item Add', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ItemMasterScreen()));
                  }),
                  _buildDrawerItem(Icons.person_add, 'Add Guest', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GuestRegistrationScreen()));
                  }),
                  _buildDrawerItem(Icons.settings, 'Setting', () {}),
                  _buildDrawerItem(
                      Icons.nightlight_round, 'Night Audit', () {}),
                  _buildDrawerItem(Icons.logout, 'Logout', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => POSLoginScreen(
                                propertyid: widget.propertyid,
                                outlet: widget.outlet)));
                  }),
                  _buildDrawerItem(Icons.admin_panel_settings, 'Admin', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AdminDashboard()));
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Outlet Tabs
          Container(
            color: Colors.teal.shade700,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: outlets.map((outlet) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: selectedOutlet == outlet
                          ? Colors.white
                          : Colors.teal.shade700,
                      backgroundColor: selectedOutlet == outlet
                          ? Colors.teal.shade900
                          : Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedOutlet = outlet;
                        loadtablesnew(outlet.toLowerCase());
                      });
                    },
                    child: Text(outlet),
                  ),
                );
              }).toList(),
            ),
          ),

          // Table Layout with GridView
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: areas.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal),
                        ),
                        const SizedBox(height: 8),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 3,
                          ),
                          itemCount: entry.value.length,
                          itemBuilder: (context, index) {
                            final tableNo = entry.value[index];

                            // Determine the color based on the table's state
                            final tableState = tableStates[tableNo] ??
                                'Vacant'; // Default to 'vacant'
                            Color tableColor;

                            switch (tableState) {
                              case 'Occupied':
                                tableColor = Colors.green;
                                break;
                              case 'Dirty':
                                tableColor = Colors.grey;
                                break;
                              case 'Vacant':
                              default:
                                tableColor = Colors.teal.shade100;
                                break;
                            }
                            return GestureDetector(
                              onTap: () {
                                if (tableState == 'Occupied') {
                                  // Navigate to billing screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BillingFormScreen(
                                        tableno: tableNo,
                                        propertyid: widget.propertyid,
                                        outlet: selectedOutlet,
                                      ),
                                    ),
                                  );
                                } else if (tableState == 'Vacant') {
                                  // Navigate to order form
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => KOTFormScreen(
                                        tableno: tableNo,
                                        propertyid: widget.propertyid,
                                        outlet: selectedOutlet,
                                      ),
                                    ),
                                  );
                                } else if (tableState == 'Dirty') {
                                  // Show a message or do nothing
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Table $tableNo is dirty and cannot be used.',
                                      ),
                                      backgroundColor: Colors.brown,
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: tableColor,
                                  border: Border.all(
                                    color: Colors.teal.shade700,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Display the table number
                                    Text(
                                      entry.value[index],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Display appropriate icons based on table state
                                    if (tableState == 'Occupied') ...[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.receipt_long,
                                                color: Colors.teal),
                                            onPressed: () {
                                              // Navigate to view bill screen
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      BillingFormScreen(
                                                    tableno: tableNo,
                                                    propertyid:
                                                        widget.propertyid,
                                                    outlet: selectedOutlet,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.restaurant_menu,
                                                color: Colors.teal),
                                            onPressed: () {
                                              // Navigate to add item screen
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      KOTFormScreen(
                                                    tableno: tableNo,
                                                    propertyid:
                                                        widget.propertyid,
                                                    outlet: selectedOutlet,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ] else if (tableState == 'Dirty') ...[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.payment,
                                                color: Colors.brown),
                                            onPressed: () {
                                              // Navigate to payment screen
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PaymentFormScreen(
                                                    tableno: tableNo,
                                                    billid: '1',
                                                    propertyid:
                                                        widget.propertyid,
                                                    outletname: selectedOutlet,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.cleaning_services,
                                                color: Colors.brown),
                                            onPressed: () {
                                              tableapiService.cleartable(
                                                  tableNo.toString());
                                              // Clear the table action
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Table $tableNo cleared successfully.'),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ] else if (tableState == 'Vacant') ...[
                                      IconButton(
                                        icon: const Icon(Icons.restaurant_menu,
                                            color: Colors.green),
                                        onPressed: () {
                                          // Navigate to order form
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  KOTFormScreen(
                                                tableno: tableNo,
                                                propertyid: widget.propertyid,
                                                outlet: selectedOutlet,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Summary Stats
          Container(
            color: Colors.teal.shade50,
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox('Today Reservation', '12', Colors.red),
                _buildStatBox('Today Sale', '₹120', Colors.green),
                _buildStatBox('Running Order', '₹120', Colors.blue),
                _buildStatBox('Pending Payment', '₹120', Colors.orange),
                _buildStatBox('Total Packing', '₹120', Colors.teal),
                _buildStatBox('Today Collection', '₹120', Colors.yellow),
              ],
            ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Help"),
                content: const Text("This is a help dialog for assistance."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ],
              );
            },
          );
        },
        icon: const Icon(Icons.help),
        label: const Text("Help"),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal.shade700),
      title: Text(title, style: TextStyle(color: Colors.teal.shade900)),
      onTap: onTap,
    );
  }

  Widget _buildStatBox(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
