import 'package:flutter/material.dart';
import 'package:point_of_sale_system/ItemMaster.dart';
import 'package:point_of_sale_system/admin.dart';
import 'package:point_of_sale_system/billing.dart';
import 'package:point_of_sale_system/guest_info.dart';
import 'package:point_of_sale_system/kotform.dart';
import 'package:point_of_sale_system/payments.dart';
import 'package:point_of_sale_system/poslogin.dart';
import 'package:point_of_sale_system/reservation.dart';

class POSMainScreen extends StatefulWidget {
  const POSMainScreen({super.key});

  @override
  _POSMainScreenState createState() => _POSMainScreenState();
}

class _POSMainScreenState extends State<POSMainScreen> {
  String selectedOutlet = 'Restaurant';
  final List<String> outlets = ['Restaurant', 'Bar', 'Packing', 'N.C. Order', 'Swiggy', 'Zomato', 'Room Service'];
  final Map<String, List<String>> areas = {
    'OPEN AREA': ['01', '02', '03', '04', '05', '06', '07', '08'],
    'HALL': ['01', '02', '03', '04'],
    'ROOF TOP': ['04', '05', '01', '02', '03', '04'],
    'GARDEN': ['01', '02', '03', '04', '05', '06', '07'],
    'VIP AREA': ['01', '02', '03', '04'],
  };

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
              accountName: const Text('User A', style: TextStyle(color: Colors.white)),
              accountEmail: const Text('Session Started: 4h ago', style: TextStyle(color: Colors.white70)),
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ReservationFormScreen()));
                  }),
                  _buildDrawerItem(Icons.swap_horiz, 'Table Shift', () {}),
                  _buildDrawerItem(Icons.receipt, 'Orders', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => KOTFormScreen()));
                  }),
                  _buildDrawerItem(Icons.payment, 'Billing', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BillingFormScreen()));
                  }),
                  _buildDrawerItem(Icons.payment, 'Payment', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentFormScreen()));
                  }),
                  _buildDrawerItem(Icons.report, 'Reports', () {}),
                  _buildDrawerItem(Icons.add_box, 'Item Add', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ItemMasterScreen()));
                  }),
                  _buildDrawerItem(Icons.person_add, 'Add Guest', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GuestRegistrationScreen()));
                  }),
                  _buildDrawerItem(Icons.settings, 'Setting', () {}),
                  _buildDrawerItem(Icons.nightlight_round, 'Night Audit', () {}),
                  _buildDrawerItem(Icons.logout, 'Logout', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => POSLoginScreen()));
                  }),
                  _buildDrawerItem(Icons.admin_panel_settings, 'Admin', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDashboard()));
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
                      foregroundColor: selectedOutlet == outlet ? Colors.white : Colors.teal.shade700,
                      backgroundColor: selectedOutlet == outlet ? Colors.teal.shade900 : Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedOutlet = outlet;
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
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                        const SizedBox(height: 8),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 4,
                          ),
                          itemCount: entry.value.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => KOTFormScreen()));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade100,
                                  border: Border.all(color: Colors.teal.shade700, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    entry.value[index],
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                                  ),
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
                _buildStatBox('Total Packing', '₹120', Colors.purple),
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
