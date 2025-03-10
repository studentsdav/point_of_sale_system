import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _financialYearController =
      TextEditingController();
  final TextEditingController _posTerminalController = TextEditingController();

  String _role = 'User';

  void _register() {
    if (_formKey.currentState!.validate()) {
      // Handle registration logic here, such as sending data to an API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User Registered Successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Registration'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: 400, // Adjust width as needed
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username field with an icon
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                // Password field with an icon
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                // Role dropdown with an icon
                DropdownButtonFormField<String>(
                  value: _role,
                  items: ['User', 'Admin']
                      .map((role) =>
                          DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  onChanged: (value) => setState(() => _role = value!),
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.group),
                  ),
                ),
                // Financial Year field with an icon
                TextFormField(
                  controller: _financialYearController,
                  decoration: const InputDecoration(
                    labelText: 'Financial Year',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the financial year';
                    }
                    return null;
                  },
                ),
                // POS Terminal field with an icon
                TextFormField(
                  controller: _posTerminalController,
                  decoration: const InputDecoration(
                    labelText: 'POS Terminal',
                    prefixIcon: Icon(Icons.payment),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the POS terminal';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Register button with an icon
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _register,
                    icon: const Icon(
                      Icons.app_registration,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Register',
                      style: TextStyle(color: Colors.white),
                    ),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
