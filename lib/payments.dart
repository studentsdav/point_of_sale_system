import 'package:flutter/material.dart';

class PaymentFormScreen extends StatefulWidget {
  @override
  _PaymentFormScreenState createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _paymentMethod;
  double _amount = 0.0;
  final _paymentDateController = TextEditingController();
  final _billIdController = TextEditingController();

  // List of bills for demonstration (replace with your actual bill data)
  final List<Map<String, String>> _bills = [
    {'bill_id': '101', 'amount': '1500.00'},
    {'bill_id': '102', 'amount': '2000.00'},
    {'bill_id': '103', 'amount': '1200.00'},
  ];

  // List of payment methods
  final List<String> _paymentMethods = ['Cash', 'Card', 'Mobile Payment'];

  @override
  void dispose() {
    _paymentDateController.dispose();
    _billIdController.dispose();
    super.dispose();
  }

  // Form submit function
  void _submitPayment() {
    if (_formKey.currentState!.validate()) {
      // Save payment data
  
      // Here you can save the payment data to the database

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successfully saved!')),
      );
    }
  }

  // Set selected bill details to the form
  void _selectBill(Map<String, String> bill) {
    _billIdController.text = bill['bill_id']!;
    _amount = double.tryParse(bill['amount']!) ?? 0.0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Form'),
      ),
      body: Row(
        children: [
          // Left Panel: Bill List
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: _bills.length,
                itemBuilder: (context, index) {
                  final bill = _bills[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text('Bill ID: ${bill['bill_id']}'),
                      subtitle: Text('Amount: ${bill['amount']}'),
                      onTap: () => _selectBill(bill),
                    ),
                  );
                },
              ),
            ),
          ),

          // Right Panel: Payment Form
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity, // Take up the full width
                constraints: BoxConstraints(maxWidth: 600), // Set max width for better appearance
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 10)],
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Bill ID (from previous bill)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _billIdController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Bill ID',
                            hintText: 'Enter Bill ID',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.receipt),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Bill ID';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Payment Method Dropdown
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          value: _paymentMethod,
                          decoration: InputDecoration(
                            labelText: 'Payment Method',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.payment),
                          ),
                          items: _paymentMethods.map((method) {
                            return DropdownMenuItem<String>(
                              value: method,
                              child: Text(method),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _paymentMethod = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a payment method';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Payment Amount
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            hintText: 'Enter Payment Amount',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          initialValue: _amount.toString(),
                          onChanged: (value) {
                            setState(() {
                              _amount = double.tryParse(value) ?? 0.0;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the amount';
                            }
                            if (double.tryParse(value) == null || double.parse(value) <= 0) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Payment Date
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _paymentDateController,
                          decoration: InputDecoration(
                            labelText: 'Payment Date',
                            hintText: 'Enter Payment Date (YYYY-MM-DD)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the payment date';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Submit Button
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: _submitPayment,
                              child: Text('Save Payment'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
