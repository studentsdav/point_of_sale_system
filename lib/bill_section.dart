import 'package:flutter/material.dart';
import 'package:point_of_sale_system/backend/OrderApiService.dart';
import 'package:point_of_sale_system/backend/bill_service.dart';

class BillPage extends StatefulWidget {
  @override
  _BillPageState createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  BillingApiService billApiService =
      BillingApiService(baseUrl: 'http://localhost:3000/api');
  OrderApiService orderApiService =
      OrderApiService(baseUrl: 'http://localhost:3000/api');
  List<Map<String, String>> _bills = [];
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
          'total_amount': bill['grand_total'].toString(),
          'tax_value': bill['tax_value'].toString(),
          'discount_value': bill['discount_value'].toString(),
          'outlet_name': bill['outlet_name'].toString(),
          'status': bill['status'].toString(),
          'bill_generated_at': bill['bill_generated_at'].toString(),
        };
      }).toList();

      return _bills;
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

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
          title: Text('Billing System'),
        ),
        body: FutureBuilder<List<Map<String, String>>>(
            future: _billingFuture,
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
                  // Left Side: Bills List
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.grey[200],
                      child: ListView.builder(
                        itemCount: _bills.length,
                        itemBuilder: (context, index) {
                          final bill = _bills[index];
                          bool isSelected = _selectedBill == bill;
                          return Card(
                            color: isSelected ? Colors.blue[100] : Colors.white,
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                                title: Text('Bill ID: ${bill['bill_number']}'),
                                subtitle: Text('Amount: ${bill['amount']}'),
                                onTap: () {
                                  _fetchOrders(bill['bill_id'].toString());
                                  _selectBill(bill);
                                }),
                          );
                        },
                      ),
                    ),
                  ),

                  // Right Side: Bill Details
                  Expanded(
                    flex: 3,
                    child: _selectedBill == null
                        ? Center(child: Text('Select a bill to view details'))
                        : Container(
                            padding: EdgeInsets.all(16),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header: Bill Details
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 1, color: Colors.grey)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bill Number: ${_selectedBill!['bill_number']}',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Date & Time: ${_formatDate(_selectedBill!['bill_generated_at'])}',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Status: ${_selectedBill!['status']}',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 16),
                                // Center: Items List
                                // Center: Items List
                                Expanded(
                                  child: isLoadingItems
                                      ? Center(
                                          child: CircularProgressIndicator())
                                      : orderItems.isEmpty
                                          ? Center(
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
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                                  child: ListTile(
                                                    title: Text(
                                                        '${item['item_name']}'),
                                                    subtitle: Text(
                                                        'Qty: ${item['quantity']} | Price: ${item['price'].toStringAsFixed(2)}'),
                                                    trailing: Text(
                                                      'Total: ${item['total'].toStringAsFixed(2)}',
                                                      style: TextStyle(
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
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            width: 1, color: Colors.grey)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Charges:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          'Total Amount: ${_selectedBill!['total_amount']}'),
                                      Text(
                                          'Tax Value: ${_selectedBill!['tax_value']}'),
                                      Text(
                                          'Discount Value: ${_selectedBill!['discount_value']}'),
                                      // Text(
                                      //     'Service Charge: ${_selectedBill!['service_charge_value']}'),
                                      // Text(
                                      //     'Packing Charge: ${_selectedBill!['packing_charge']}'),
                                      // Text(
                                      //     'Delivery Charge: ${_selectedBill!['delivery_charge']}'),
                                      // Text(
                                      //     'Other Charge: ${_selectedBill!['other_charge']}'),
                                      SizedBox(height: 8),
                                      Text(
                                        'Grand Total: ${_selectedBill!['amount']}',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => _editBill(),
                                            child: Text('Print'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => _cancelBill(),
                                            child: Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => _modifyBill(),
                                            child: Text('Modify'),
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
              return CircularProgressIndicator();
            }));
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
    // Add your edit functionality here
  }

  // Method to handle Cancel
  void _cancelBill() {
    print('Cancelling bill: ${_selectedBill!['bill_number']}');
    // Add your cancel functionality here
  }

  // Method to handle Modify
  void _modifyBill() {
    print('Modifying bill: ${_selectedBill!['bill_number']}');
    // Add your modify functionality here
  }
}
