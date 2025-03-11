import 'package:flutter/material.dart';

void main() {
  runApp(const ExpenseManagerApp());
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AccountManagerScreen(),
    );
  }
}

class AccountManagerScreen extends StatefulWidget {
  const AccountManagerScreen({super.key});

  @override
  _AccountManagerScreenState createState() => _AccountManagerScreenState();
}

class _AccountManagerScreenState extends State<AccountManagerScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  List<Map<String, dynamic>> accounts = [
    {'id': 1, 'name': 'Savings', 'type': 'Bank', 'balance': 5000.00},
    {'id': 2, 'name': 'Cash', 'type': 'Wallet', 'balance': 1500.00},
  ];

  void _addOrUpdateAccount() {
    String name = _nameController.text;
    String type = _typeController.text;
    double balance = double.tryParse(_balanceController.text) ?? 0.00;

    setState(() {
      int existingIndex = accounts
          .indexWhere((acc) => acc['name'] == name && acc['type'] == type);
      if (existingIndex != -1) {
        accounts[existingIndex]['balance'] += balance;
      } else {
        accounts.add({
          'id': accounts.length + 1,
          'name': name,
          'type': type,
          'balance': balance,
        });
      }
      _nameController.clear();
      _typeController.clear();
      _balanceController.clear();
    });
  }

  void _deleteAccount(int index) {
    setState(() {
      accounts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account Manager")),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add/Update Account",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: "Account Name")),
                  TextField(
                      controller: _typeController,
                      decoration:
                          const InputDecoration(labelText: "Account Type")),
                  TextField(
                      controller: _balanceController,
                      decoration: const InputDecoration(labelText: "Balance"),
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: _addOrUpdateAccount,
                      child: const Text("Save Account")),
                ],
              ),
            ),
          ),
          const VerticalDivider(),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Account List",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        final account = accounts[index];
                        return Card(
                          child: ListTile(
                            title: Text(account['name']),
                            subtitle: Text(
                                "Type: ${account['type']} | Balance: \$${account['balance']}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteAccount(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
