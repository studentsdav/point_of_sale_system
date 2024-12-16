import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:point_of_sale_system/backend/bill_api_service.dart';
import 'package:point_of_sale_system/backend/bill_service.dart';
import 'package:point_of_sale_system/backend/paymentApiService.dart';

class PaymentFormScreen extends StatefulWidget {
  final tableno;
  final billid;
  final propertyid;
  final outletname;
  const PaymentFormScreen(
      {super.key,
      required this.billid,
      required this.propertyid,
      required this.outletname,
      required this.tableno});
  @override
  _PaymentFormScreenState createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  PaymentApiService paymentApiService =
      PaymentApiService(baseUrl: 'http://localhost:3000/api');
  BillingApiService billApiService =
      BillingApiService(baseUrl: 'http://localhost:3000/api');
  final _formKey = GlobalKey<FormState>();
  String? _paymentMethod;
  double _amount = 0.0;
  final _billIdController = TextEditingController();
  final _amountController = TextEditingController();

  List<Map<String, String>> _bills = [
    // {'bill_id': '1', 'amount': '1500.00'},
    // {'bill_id': '2', 'amount': '2000.00'},
    // {'bill_id': '3', 'amount': '1200.00'},
  ];

  // List of payment methods
  final List<String> _paymentMethods = ['Cash', 'Card', 'Mobile Payment'];

  DateTime? paymentDate;
  late Future<List<Map<String, String>>> _paymentFuture;
  String? billid;

  Map<String, String>? _selectedBill;

  String? table_no;

  @override
  void initState() {
    _paymentFuture = getbillByStatusnew('UnPaid');
    super.initState();
  }

  @override
  void dispose() {
    _billIdController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String generateTransactionId() {
    final now = DateTime.now();
    final transactionId =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    return transactionId;
  }

  // Form submit function
  Future<void> _submitPayment() async {
    table_no ??= widget.tableno;
    if (_formKey.currentState!.validate()) {
      final paymentData = {
        'bill_id': int.parse(billid!),
        'payment_method': _paymentMethod,
        'payment_amount': _amount,
        'payment_date': paymentDate!.toIso8601String(),
        'transaction_id': generateTransactionId(), // Add transaction ID
        'remarks': '_remarks', // Add remarks
        'outlet_name': widget.outletname, // Add outlet name
        'property_id': widget.propertyid, // Add property ID
        'table_no': table_no
      };
      try {
        await paymentApiService.createPayment(paymentData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment successfully saved!')),
        );
        setState(() {
          _amount = 0.0;
          _billIdController.text = "";
          _amountController.text = "";
          _bills.removeWhere((bill) => bill['bill_id'] == billid);
        });
      } catch (exeption) {
        // Show error message if something goes wrong
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving order: $exeption')),
        );
        throw (exeption);
      }
    }
  }

  Future<List<Map<String, String>>> getbillByStatusnew(String status) async {
    try {
      // Await the result from the API call
      List<Map<String, dynamic>> billJson =
          await billApiService.getbillByStatus(status); // Await the Future

      // Map the API response to the structure of _bills
      _bills = billJson.map((bill) {
        return {
          'bill_id': bill['id']
              .toString(), // Adjust based on the field name in your API response
          'bill_number': bill['bill_number'].toString(),
          'amount': bill['grand_total']
              .toString(), // Adjust based on the field name in your API response
          'table_no': bill['table_no'].toString()
        };
      }).toList();

      return _bills;
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  // Set selected bill details to the form
  void _selectBill(Map<String, String> bill) {
    table_no = bill['table_no'];
    billid = bill['bill_id']!;
    _billIdController.text = bill['bill_number']!;
    _amount = double.tryParse(bill['amount']!) ?? 0.0;
    _amountController.text = _amount.toStringAsFixed(2);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Form'),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
          future: _paymentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator while waiting for data
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Handle error
              return Center(
                  child: Text('Error loading menu items: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              return Row(children: [
                // Left Panel: Bill List
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.grey[200],
                    padding: EdgeInsets.all(16),
                    child: ListView.builder(
                      itemCount: _bills.length,
                      itemBuilder: (context, index) {
                        final bill = _bills[index];
                        bool isSelected = _selectedBill == bill;
                        Color selectedColor = isSelected
                            ? Colors.blue
                            : Colors.white; // Change color based on selection
                        return Card(
                          color: selectedColor,
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(
                                'Bill ID: ${bill['bill_number']} |     Table No: ${bill['table_no']} '),
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
                      constraints: BoxConstraints(
                          maxWidth: 600), // Set max width for better appearance
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.grey, blurRadius: 10)
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          children: [
                            // Bill ID (from previous bill)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                readOnly: true,
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
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Restricts input to digits only
                                ],
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                controller: _amountController,
                                decoration: InputDecoration(
                                  labelText: 'Amount',
                                  hintText: 'Enter Payment Amount',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.attach_money),
                                ),
                                // initialValue: _amount.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _amount = double.tryParse(value) ?? 0.0;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the amount';
                                  }
                                  if (double.tryParse(value) == null ||
                                      double.parse(value) <= 0) {
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
                                keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Payment Date',
                                  prefixIcon: Icon(Icons.date_range),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (pickedDate != null)
                                    setState(() => paymentDate = pickedDate);
                                },
                                validator: (_) => paymentDate == null
                                    ? 'Please select a payment date'
                                    : null,
                                controller: TextEditingController(
                                  text: paymentDate == null
                                      ? ''
                                      : "${paymentDate!.day}-${paymentDate!.month}-${paymentDate!.year}",
                                ),
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
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green),
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
              ]);
            }
            return CircularProgressIndicator();
          }),
    );
  }
}
