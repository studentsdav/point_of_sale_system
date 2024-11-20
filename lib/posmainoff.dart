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
        backgroundColor: Colors.purple,
        title: Row(
          children: [
            const Text('Property name: Nourish Bistro and Cafe'),
            const Spacer(),
            IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.mail)),
            Text('Software Date: ${DateTime.now()}'),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.purple),
              accountName: const Text('User A'),
              accountEmail: const Text('Session Started: 4h ago'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.purple),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(leading: const Icon(Icons.home), title: const Text('Home'), onTap: () {
           
                  }),
                  ListTile(leading: const Icon(Icons.book), title: const Text('Reservation'), onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ReservationFormScreen()));
                  }),
                  ListTile(leading: const Icon(Icons.swap_horiz), title: const Text('Table Shift'), onTap: () {
          
                  }),
                  ListTile(leading: const Icon(Icons.receipt), title: const Text('Orders'), onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>KOTFormScreen()));
                  }),
                  ListTile(leading: const Icon(Icons.payment), title: const Text('Billing'), onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>BillingFormScreen()));
                  }),
                  ListTile(leading: const Icon(Icons.payment), title: const Text('Payment'), onTap: () {
                                                       Navigator.push(context, MaterialPageRoute(builder: (context)=>PaymentFormScreen()));
                  }),
                  ListTile(leading: const Icon(Icons.report), title: const Text('Reports'), onTap: () {}),
                  ListTile(leading: const Icon(Icons.add_box), title: const Text('Item Add'), onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context)=>ItemMasterScreen()));
                  }),
                  ListTile(leading: const Icon(Icons.person_add), title: const Text('Add Guest'), onTap: () {
                                                                           Navigator.push(context, MaterialPageRoute(builder: (context)=>GuestRegistrationScreen()));
                  }),
                  ListTile(leading: const Icon(Icons.settings), title: const Text('Setting'), onTap: () {}),
                  ListTile(leading: const Icon(Icons.nightlight_round), title: const Text('Night Audit'), onTap: () {}),
                  ListTile(leading: const Icon(Icons.logout), title: const Text('Logout'), onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context)=>POSLoginScreen()));
                  }),
                  ListTile(leading: const Icon(Icons.admin_panel_settings), title: const Text('Admin'), onTap: () {
                                   Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminDashboard()));
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
            color: Colors.purple,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: outlets.map((outlet) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: selectedOutlet == outlet ? Colors.white : Colors.black,
                      backgroundColor: selectedOutlet == outlet ? Colors.green : Colors.white,
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
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
                        ),
                        const SizedBox(height: 8),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 12, // 12 columns per row for 50x50 tables
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                          itemCount: entry.value.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>KOTFormScreen()));
                            },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.purple, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    entry.value[index],
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
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
            color: Colors.grey[200],
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox('Today Reservation', '12', Colors.red),
                _buildStatBox('Today Sale', '120 ₹', Colors.green),
                _buildStatBox('Running Order', '120 ₹', Colors.blue),
                _buildStatBox('Pending Payment', '120 ₹', Colors.orange),
                _buildStatBox('Total Packing', '120 ₹', Colors.purple),
                _buildStatBox('Today Collection', '120 ₹', Colors.yellow),
              ],
            ),
          ),
        ],
      ),
      
      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Action when Help is clicked
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
        backgroundColor: Colors.purple,
      ),
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
