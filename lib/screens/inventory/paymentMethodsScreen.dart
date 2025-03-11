import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<Map<String, String>> paymentMethods = [
    {'name': 'Credit Card', 'description': 'Visa, MasterCard, Amex'},
    {'name': 'PayPal', 'description': 'Online payments'},
    {'name': 'Bank Transfer', 'description': 'Direct account transfer'},
  ];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void _addPaymentMethod() {
    if (nameController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty) {
      setState(() {
        paymentMethods.add({
          'name': nameController.text,
          'description': descriptionController.text,
        });
      });
      nameController.clear();
      descriptionController.clear();
      Navigator.pop(context);
    }
  }

  void _deletePaymentMethod(int index) {
    setState(() {
      paymentMethods.removeAt(index);
    });
  }

  void _showAddPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Method Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addPaymentMethod,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddPaymentDialog();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: paymentMethods.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(paymentMethods[index]['name']!),
              subtitle: Text(paymentMethods[index]['description']!),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deletePaymentMethod(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
