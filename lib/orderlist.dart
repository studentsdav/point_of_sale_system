import 'package:flutter/material.dart';
import 'package:point_of_sale_system/backend/OrderApiService.dart';

class OrderList extends StatefulWidget {
  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  OrderApiService orderApiService =
      OrderApiService(baseUrl: 'http://localhost:3000/api');
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> orderItems = [];
  var selectedOrderId;
  bool isLoadingOrders = true;
  bool isLoadingItems = false;

  // Mock data for items
  // final List<Map<String, dynamic>> _items = List.generate(10, (index) {
  //   return {
  //     'sno': index + 1,
  //     'name': 'Item ${index + 1}',
  //     'qty': 1,
  //     'rate': 100.0,
  //     'amount': 100.0,
  //     'tax': 5.0,
  //     'discount_amount': 10.0,
  //     'happy_hour_discount': 5.0,
  //     'scheme': 'None',
  //     'category': 'Category ${index % 3}',
  //   };
  // });

  Map<String, Map<String, dynamic>> itemMap = {};

  String ordernumber = "";

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      isLoadingOrders = true;
    });

    try {
      // Fetch orders by table and status (assuming this fetches the 10 orders)
      orders = await orderApiService.getOrdersByStatus('Pending');

      // Check if there are orders, then extract their IDs
      if (orders.isNotEmpty) {
        // Extract all order IDs from the fetched orders
        List<String> orderIds =
            orders.map((order) => order['order_id'].toString()).toList();

        // Fetch items for all selected orders
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

  Future<void> _fetchOrderItems(orderIds) async {
    setState(() {
      orderItems.clear();
      itemMap.clear();
      isLoadingItems = true;
    });

    try {
      // Fetch items for all selected orders
      final fetchedItems = await orderApiService.getOrderItemsByIds(orderIds);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order List')),
      body: Row(
        children: [
          // Left Panel - Pending Orders
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[200],
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    child: ListTile(
                      title: Text('Order No: ${order["order_number"]}'),
                      subtitle: Text(
                          'Table No: ${order["table_number"]} - ${order["order_type"]}'),
                      onTap: () {
                        setState(() {
                          selectedOrderId = order['order_id'].toString();
                          ordernumber = order['order_number'].toString();
                          _fetchOrderItems([selectedOrderId as String]);
                        });
                      },
                      selected: selectedOrderId == order['order_id'].toString(),
                    ),
                  );
                },
              ),
            ),
          ),

          // Right Panel - Order Details
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.white,
              child: selectedOrderId != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Details',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Order No: ${ordernumber}'),
                        Divider(),
                        // List of order items
                        Expanded(
                          child: ListView.builder(
                            itemCount: itemMap.length,
                            itemBuilder: (context, index) {
                              final item = itemMap.values.toList()[index];
                              return ListTile(
                                title: Text(item["item_name"]),
                                subtitle: Text('Quantity: ${item["quantity"]}'),
                                trailing: Text('₹${item["total"]}'),
                              );
                            },
                          ),
                        ),
                        Divider(),
                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Modify order $selectedOrderId'),
                                  ),
                                );
                              },
                              icon: Icon(Icons.edit),
                              label: Text('Modify'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  orders.removeWhere((order) =>
                                      order['order_id'] == selectedOrderId);
                                  itemMap.remove(selectedOrderId);
                                  selectedOrderId = null;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Order deleted'),
                                  ),
                                );
                              },
                              icon: Icon(Icons.delete),
                              label: Text('Delete'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Printing order $selectedOrderId'),
                                  ),
                                );
                              },
                              icon: Icon(Icons.print),
                              label: Text('Print'),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        'Select an Order from the left panel',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
