import 'package:flutter/material.dart';

import '../../backend/billing/bill_service.dart';
import '../../backend/order/OrderApiService.dart';
import '../orders/modifyOrder.dart';

class BillPage extends StatefulWidget {
  final propertyid;
  final outletname;
  const BillPage(
      {super.key, required this.propertyid, required this.outletname});
  @override
  _BillPageState createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  BillingApiService billApiService =
      BillingApiService(baseUrl: 'http://localhost:3000/api');
  OrderApiService orderApiService =
      OrderApiService(baseUrl: 'http://localhost:3000/api');
  List<Map<String, String>> _bills = [];
  final List<Map<String, String>> _billsdata = [];
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> orderItems = [];
  var selectedOrderId;
  bool isLoadingOrders = true;
  bool isLoadingItems = false;
  Map<String, Map<String, dynamic>> itemMap = {};
  String ordernumber = "";

  Map<String, dynamic>? _selectedBill;
  late Future<List<Map<String, String>>> _billingFuture;

  @override
  void initState() {
    _billingFuture = getbillByStatusnew('UnPaid');
    super.initState();
  }

  Future<List<Map<String, String>>> getbillByStatusnew(String status) async {
    try {
      // Await the result from the API call
      List<Map<String, dynamic>> billJson = await billApiService
          .getbillByStatus(status: status); // Await the Future

      // Map the API response to the structure of _bills
      _bills = billJson.map((bill) {
        return {
          'bill_id': bill['id']
              .toString(), // Adjust based on the field name in your API response
          'bill_number': bill['bill_number'].toString(),
          'tax_value': bill['tax_value'].toString(),
          'discount_value': bill['discount_value'].toString(),
          'outlet_name': bill['outlet_name'].toString(),
          'status': bill['status'].toString(),
          'bill_generated_at': bill['bill_generated_at'].toString(),
          'guest_name': bill['guestname'].toString(),
          'grand_total': bill['grand_total'].toString(),
          'discount_percentage': bill['discount_percentage'].toString(),
          'service_charge_percentage':
              bill['service_charge_percentage'].toString(),
          'service_charge_value': bill['service_charge_value'].toString(),
          'delivery_charge': bill['delivery_charge'].toString(),
          'packing_charge': bill['packing_charge'].toString(),
          'delivery_charge_value': bill['delivery_charge_value'].toString(),
          'packing_charge_value': bill['packing_charge_value'].toString(),
          'total_amount': bill['total_amount'].toString(),
          'country': 'India'
        };
      }).toList();

      return _bills;
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  // Future<List<Map<String, String>>> getbillBybillno(String billno) async {
  //   try {
  //     // Await the result from the API call
  //     List<Map<String, dynamic>> billJson = await billApiService
  //         .getbillByStatus(billno: billno); // Await the Future

  //     // Map the API response to the structure of _bills
  //     _billsdata = billJson.map((bill) {
  //       return {
  //         'bill_id': bill['id']
  //             .toString(), // Adjust based on the field name in your API response
  //         'bill_number': bill['bill_number'].toString(),
  //         'amount': bill['grand_total']
  //             .toString(), // Adjust based on the field name in your API response
  //         'total_amount': bill['grand_total'].toString(),
  //         'tax_value': bill['tax_value'].toString(),
  //         'discount_value': bill['discount_value'].toString(),
  //         'outlet_name': bill['outlet_name'].toString(),
  //         'status': bill['status'].toString(),
  //         'bill_generated_at': bill['bill_generated_at'].toString(),
  //         'guest_name': bill['guestname'].toString(),
  //         'country': 'India'
  //       };
  //     }).toList();

  //     return _billsdata;
  //   } catch (e) {
  //     throw Exception('Error fetching orders: $e');
  //   }
  // }

  Future<void> _fetchOrders(billid) async {
    setState(() {
      isLoadingOrders = true;
    });

    try {
      // Fetch orders by table and status (assuming this fetches the 10 orders)
      orders = await orderApiService.getOrdersBybillid(billid);

      // Check if there are orders, then extract their IDs
      if (orders.isNotEmpty) {
        // Extract all order IDs from the fetched orders
        List<String> orderIds =
            orders.map((order) => order['order_id'].toString()).toList();

        // Fetch items for all selected orders
        _fetchOrderItems(orderIds);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching orders: $e')),
      );
    } finally {
      setState(() {
        isLoadingOrders = false;
      });
    }
  }

  Future<void> _fetchOrderItems(List<String> orderIds) async {
    setState(() {
      isLoadingItems = true;
    });

    try {
      // Fetch items for all selected orders
      final fetchedItems = await orderApiService.getOrderItemsByIds(orderIds);
      itemMap.clear();
      orderItems.clear();
      // Process fetched items
      for (var item in [...orderItems, ...fetchedItems]) {
        final key = item['item_name'];

        // Safely parse item quantity, rate, and tax
        int itemQuantity = 0;
        if (item['item_quantity'] != null) {
          if (item['item_quantity'] is String) {
            itemQuantity = int.tryParse(item['item_quantity']) ?? 0;
          } else if (item['item_quantity'] is int) {
            itemQuantity = item['item_quantity'] as int;
          }
        }

        double itemRate = 0.0;
        if (item['item_rate'] != null) {
          if (item['item_rate'] is String) {
            itemRate = double.tryParse(item['item_rate']) ?? 0.0;
          } else if (item['item_rate'] is double) {
            itemRate = item['item_rate'] as double;
          }
        }

        int taxRate = 0;
        if (item['taxrate'] != null && item['taxrate'] is int) {
          taxRate = item['taxrate'];
        }

        if (itemMap.containsKey(key)) {
          itemMap[key]!['quantity'] += itemQuantity;
          itemMap[key]!['total'] = itemMap[key]!['quantity'] * itemRate;
        } else {
          itemMap[key] = {
            'sno': itemMap.length + 1,
            'item_name': item['item_name'],
            'quantity': itemQuantity,
            'price': itemRate,
            'tax': taxRate,
            'total': itemQuantity * itemRate,
            'order_id': item['order_id'],
          };
        }
      }

      setState(() {
        orderItems = itemMap.values.toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching order items: ${e.toString()}')),
      );
      print("Error: $e");
    } finally {
      setState(() {
        isLoadingItems = false;
      });
    }
  }

  String _formatDate(dynamic date) {
    try {
      if (date is String) {
        final parsedDate =
            DateTime.parse(date).toLocal(); // Convert to local timezone
        return "${_twoDigits(parsedDate.day)}-${_twoDigits(parsedDate.month)}-${parsedDate.year} : ${_twoDigits(parsedDate.hour)}:${_twoDigits(parsedDate.minute)}";
      } else if (date is DateTime) {
        final localDate = date.toLocal(); // Ensure it's in the local timezone
        return "${_twoDigits(localDate.day)}-${_twoDigits(localDate.month)}-${localDate.year} : ${_twoDigits(localDate.hour)}:${_twoDigits(localDate.minute)}";
      }
    } catch (e) {
      print("Error formatting date: $e");
    }
    return "Invalid Date";
  }

// Helper function to ensure two digits for day, month, hour, and minute
  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Billing System'),
        ),
        body: FutureBuilder<List<Map<String, String>>>(
            future: _billingFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show a loading indicator while waiting for data
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // Handle error
                return Center(
                    child: Text('Error loading menu items: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                return Row(children: [
                  // Left Side: Bills List
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey[200],
                      child: ListView.builder(
                        itemCount: _bills.length,
                        itemBuilder: (context, index) {
                          final bill = _bills[index];
                          bool isSelected = _selectedBill == bill;
                          return Card(
                            color: isSelected ? Colors.blue[100] : Colors.white,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                                title: Text('Bill ID: ${bill['bill_number']}'),
                                subtitle:
                                    Text('Amount: ${bill['grand_total']}'),
                                onTap: () {
                                  _fetchOrders(bill['bill_id'].toString());
                                  _selectBill(bill);
                                }),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _selectedBill == null
                        ? const Center(
                            child: Text('Select a bill to view details'))
                        : Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header: Bill Details
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          width: 1, color: Colors.grey),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bill Number: ${_selectedBill!['bill_number']}',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Guest Name: ${_selectedBill?['guest_name'] ?? 'N/A'}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Date & Time: ${_formatDate(_selectedBill!['bill_generated_at'])}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Status: ${_selectedBill!['status']}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Items List
                                Expanded(
                                  child: isLoadingItems
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : orderItems.isEmpty
                                          ? const Center(
                                              child: Text(
                                                'No items available',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount: orderItems.length,
                                              itemBuilder: (context, index) {
                                                final item = orderItems[index];
                                                return Card(
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  child: ListTile(
                                                    title: Text(
                                                        '${item['item_name']}'),
                                                    subtitle: Text(
                                                      'Qty: ${item['quantity']} | Price: ₹${item['price'].toStringAsFixed(2)}',
                                                    ),
                                                    trailing: Text(
                                                      'Total: ₹${item['total'].toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                ),

                                // Footer: Charges
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                          width: 1, color: Colors.grey),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Total:'),
                                          Text(
                                            '₹${_selectedBill?['total_amount'] ?? '0.00'}',
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      // Tax Details
                                      // if (_selectedBill?['country'] ==
                                      //     'India') ...[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Tax:'),
                                          Text(
                                            '₹${_selectedBill?['tax_value'] ?? '0.00'}',
                                          ),
                                        ],
                                      ),

                                      // Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.spaceBetween,
                                      //   children: [
                                      //     Text(
                                      //         'CGST: ${_selectedBill?['cgst_percentage'] ?? '0'}% '),
                                      //     Text(
                                      //       '₹${_selectedBill?['cgst_value'] ?? '0.00'}',
                                      //     ),
                                      //   ],
                                      // ),
                                      // const SizedBox(height: 8),
                                      // Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.spaceBetween,
                                      //   children: [
                                      //     Text(
                                      //         'SGST: ${_selectedBill?['sgst_percentage'] ?? '0'}%'),
                                      //     Text(
                                      //       '₹${_selectedBill?['sgst_value'] ?? '0.00'}',
                                      //     ),
                                      //   ],
                                      // ),
                                      // ] else ...[
                                      //   Row(
                                      //     mainAxisAlignment:
                                      //         MainAxisAlignment.spaceBetween,
                                      //     children: [
                                      //       Text(
                                      //           'Tax: ${_selectedBill?['tax_percentage'] ?? '0'}%'),
                                      //       Text(
                                      //         '₹${_selectedBill?['tax_value'] ?? '0.00'}',
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ],
                                      const SizedBox(height: 8),

                                      // Discount
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              'Discount: ${_selectedBill?['discount_percentage'] ?? '0'}% '),
                                          Text(
                                            '₹${_selectedBill?['discount_value'] ?? '0.00'}',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Service Charge
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              'Service Charge: ${_selectedBill?['service_charge_percentage'] ?? '0'}% '),
                                          Text(
                                            '₹${_selectedBill?['service_charge_value'] ?? '0.00'}',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Packing Charge
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              'Packing Charge: ${_selectedBill?['packing_charge_percentage'] ?? '0'}%'),
                                          Text(
                                            '₹${_selectedBill?['packing_charge'] ?? '0.00'}',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Delivery Charge
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              'Delivery Charge: ${_selectedBill?['delivery_charge_percentage'] ?? '0'}%'),
                                          Text(
                                            '₹${_selectedBill?['delivery_charge'] ?? '0.00'}',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Grand Total
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Grand Total:',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '₹${_selectedBill?['grand_total'] ?? '0.00'}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      // Action Buttons
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () =>
                                                _modifyBillDialog(),
                                            child: const Text('Edit'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                _modifyBill(orders),
                                            child: const Text('Print'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => _cancelBill(),
                                            child: const Text('Cancel'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ]);
              }
              return const CircularProgressIndicator();
            }));
  }

  void _modifyBillDialog() {
    // Controllers for text fields
    final TextEditingController guestNameController = TextEditingController();
    final TextEditingController discountController = TextEditingController();
    final TextEditingController serviceChargeController =
        TextEditingController();
    final TextEditingController packingChargeController =
        TextEditingController();
    final TextEditingController deliveryChargeController =
        TextEditingController();

    // Pre-fill the fields with current values
    guestNameController.text = _selectedBill?['guest_name'] ?? '';
    discountController.text = _selectedBill?['discount_value'] ?? '0';
    serviceChargeController.text = _selectedBill?['service_charge'] ?? '0';
    packingChargeController.text = _selectedBill?['packing_charge'] ?? '0';
    deliveryChargeController.text = _selectedBill?['delivery_charge'] ?? '0';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modify Bill'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: guestNameController,
                  decoration: const InputDecoration(labelText: 'Guest Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: discountController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Discount Amount'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: serviceChargeController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Service Charge'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: packingChargeController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Packing Charge'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: deliveryChargeController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Delivery Charge'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveModifiedBill(
                  guestNameController.text,
                  double.tryParse(discountController.text) ?? 0,
                  double.tryParse(serviceChargeController.text) ?? 0,
                  double.tryParse(packingChargeController.text) ?? 0,
                  double.tryParse(deliveryChargeController.text) ?? 0,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveModifiedBill(String guestName, double discount,
      double serviceCharge, double packingCharge, double deliveryCharge) {
    setState(() {
      // Update the selected bill fields
      _selectedBill?['guest_name'] = guestName;
      _selectedBill?['discount_value'] = discount.toStringAsFixed(2);
      _selectedBill?['service_charge'] = serviceCharge.toStringAsFixed(2);
      _selectedBill?['packing_charge'] = packingCharge.toStringAsFixed(2);
      _selectedBill?['delivery_charge'] = deliveryCharge.toStringAsFixed(2);

      // Recalculate the total
      double subtotal = double.tryParse(_selectedBill?['subtotal'] ?? '0') ?? 0;
      double taxValue =
          double.tryParse(_selectedBill?['tax_value'] ?? '0') ?? 0;
      double grandTotal = subtotal +
          taxValue +
          serviceCharge +
          packingCharge +
          deliveryCharge -
          discount;
      _selectedBill?['grand_total'] = grandTotal.toStringAsFixed(2);
    });

    // Optionally, save changes to the backend
    // Example:
    // billApiService.updateBill(_selectedBill!['bill_id'], _selectedBill!);
  }

  // Method to select a bill
  void _selectBill(Map<String, dynamic> bill) {
    setState(() {
      _selectedBill = bill;
    });
  }

  // Method to handle Edit
  void _editBill() {
    print('Editing bill: ${_selectedBill!['bill_number']}');
  }

  // Method to handle Cancel
  void _cancelBill() {
    print('Cancelling bill: ${_selectedBill!['bill_number']}');
    // Add your cancel functionality here
  }

  // Method to handle Modify
  void _modifyBill(orders) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ModifyOrderList(
                  outletname: widget.outletname,
                  propertyid: widget.propertyid,
                  orders: orders,
                )));
  }
}
