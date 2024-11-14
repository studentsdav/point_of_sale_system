import 'package:flutter/material.dart';
import 'package:point_of_sale_system/forgot_password.dart';
import 'package:point_of_sale_system/posmain.dart';
import 'package:point_of_sale_system/registration.dart';

class POSLoginScreen extends StatelessWidget {
  const POSLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          height: 600,
          width: 800,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.grey.shade400, blurRadius: 10, offset: Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              // Left Side for Support Info
              Container(
                width: 300,
                padding: const EdgeInsets.all(20),
                color: Colors.purple,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CALL US FOR SUPPORT',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text('+ 91 - 89xxxxxx96\n+ 91 - 72xxxxxx01\n+ 91 - 63xxxxxx82\n+ 91 - 80xxxxxx70',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    const SizedBox(height: 20),
                    const Text('Mail Us at : pms@pmsplus.in',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    const Spacer(),
                    // Logo Image
                    Image.asset('assets/images/Res_Logo.jpg', width: 100), // Add your logo image in assets folder
                  ],
                ),
              ),
              // Right Side for Login Form
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      // Delicacy Logo
                      Image.asset('assets/images/Res_Logo.jpg', width: 100), // Add your delicacy logo in assets
                      const SizedBox(height: 20),
                      // Financial Year Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Financial Year',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        items: ['2023-2024', '2024-2025'].map((year) {
                          return DropdownMenuItem(value: year, child: Text(year));
                        }).toList(),
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 10),
                      // Select Outlet Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Outlet',
                          prefixIcon: Icon(Icons.store),
                          border: OutlineInputBorder(),
                        ),
                        items: ['Outlet 1', 'Outlet 2', 'Outlet 3'].map((outlet) {
                          return DropdownMenuItem(value: outlet, child: Text(outlet));
                        }).toList(),
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 10),
                      // User Type Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'User Type',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        items: ['Admin', 'User', 'Manager'].map((role) {
                          return DropdownMenuItem(value: role, child: Text(role));
                        }).toList(),
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 10),
                      // Username TextField
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'User Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Password TextField
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                          ),
                          onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>POSMainScreen()));
                            // Add login logic
                          },
                          child: const Text('Login', style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Forgot Password and Sign Up Links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgotPasswordScreen()));
                            },
                            child: const Text('Forgot Password?', style: TextStyle(color: Colors.purple)),
                          ),
                          TextButton(
                            onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>RegistrationScreen()));
                            },
                            child: const Text("Don't have Account? Sign Up", style: TextStyle(color: Colors.purple)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
