import 'package:flutter/material.dart';
import 'package:point_of_sale_system/posmain.dart';

class POSLoginForm extends StatelessWidget {
  final propertyid;
  final outlet;
  const POSLoginForm(
      {super.key, required this.outlet, required this.propertyid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Company Logo
              Image.asset(
                'assets/images/Res_Logo.jpg', // Replace with your logo's path
                height: 100,
              ),
              const SizedBox(height: 20),

              // Username Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 16),

              // Role Selection Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Admin',
                    child: Text('Admin'),
                  ),
                  DropdownMenuItem(
                    value: 'Cashier',
                    child: Text('Cashier'),
                  ),
                  DropdownMenuItem(
                    value: 'Manager',
                    child: Text('Manager'),
                  ),
                ],
                onChanged: (value) {
                  // Handle role selection
                },
              ),
              const SizedBox(height: 24),

              // Login Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => POSMainScreen(
                              propertyid: propertyid, outlet: outlet)));
                  // Handle login action
                },
                child: const Text('Login'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
