import 'package:flutter/material.dart';
import 'package:point_of_sale_system/backend/OrderApiService.dart';
import 'package:point_of_sale_system/modifyOrder.dart';

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
      orders = await orderApiService.getOrdersByStatus('Pending');
      if (orders.isNotEmpty) {
        List<String> orderIds =
            orders.map((order) => order['order_id'].toString()).toList();
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
      final fetchedItems = await orderApiService.getOrderItemsByIds(orderIds);
      for (var item in [...orderItems, ...fetchedItems]) {
        final key = item['item_name'];

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

  void _showModifyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modify Order Items'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: itemMap.length,
                  itemBuilder: (context, index) {
                    final item = itemMap.values.toList()[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(item['item_name'])),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (item['quantity'] > 1) {
                                item['quantity'] -= 1;
                                item['total'] =
                                    item['quantity'] * item['price'];
                              }
                            });
                          },
                        ),
                        Text('${item['quantity']}'),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              item['quantity'] += 1;
                              item['total'] = item['quantity'] * item['price'];
                            });
                          },
                        ),
                        SizedBox(width: 10),
                        Text('₹${item['total']}'),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {}); // Save changes to the main state
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order List')),
      body: Row(
        children: [
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
                        Expanded(
                          child: ListView.builder(
                            itemCount: itemMap.length,
                            itemBuilder: (context, index) {
                              final item = itemMap.values.toList()[index];
                              return ListTile(
                                title: Text(item["item_name"]),
                                subtitle: Text('Quantity: ${item["quantity"]}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('₹${item["total"]}'),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        // Confirm deletion with the user
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Delete Item'),
                                              content: Text(
                                                  'Are you sure you want to delete "${item["item_name"]}" from the order?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    // Remove the item from the map
                                                    setState(() {
                                                      itemMap.remove(
                                                          item["item_name"]);
                                                    });

                                                    // Close the dialog
                                                    Navigator.of(context).pop();

                                                    // Show a confirmation message
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            '"${item["item_name"]}" has been removed from the order.'),
                                                      ),
                                                    );
                                                  },
                                                  child: Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () => _modifyBill(orders),
                              child: Text('Modify'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  orders.removeWhere((order) =>
                                      order['order_id'].toString() ==
                                      selectedOrderId.toString());
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

  void _modifyBill(orders) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ModifyOrderList(
                  orders: orders,
                )));
  }
}
