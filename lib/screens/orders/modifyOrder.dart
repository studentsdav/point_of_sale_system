import 'package:flutter/material.dart';

import '../../backend/order/OrderApiService.dart';
import '../../backend/order/items_api_service.dart';

class ModifyOrderList extends StatefulWidget {
  final propertyid;
  final outletname;
  final orders;
  final billid;
  const ModifyOrderList(
      {super.key,
      required this.orders,
      required this.propertyid,
      required this.outletname,
      required this.billid});
  @override
  _ModifyOrderListState createState() => _ModifyOrderListState();
}

class _ModifyOrderListState extends State<ModifyOrderList> {
  OrderApiService orderApiService = OrderApiService();
  final List<String> _categories = ['Starters', 'Main Course', 'Desserts'];
  ItemsApiService itemsApiService = ItemsApiService();
  late Future<Map<String, List<Map<String, String>>>> _menuItemsFuture;
  // Menu items with their tags (Veg/Non-Veg) and rate
  final Map<String, List<Map<String, String>>> _menuItems = {
    // 'Starters': [
    //   {'name': 'Samosa', 'tag': 'Veg', 'rate': '50'},
    //   {'name': 'Spring Roll', 'tag': 'Veg', 'rate': '60'},
    //   {'name': 'Garlic Bread', 'tag': 'Veg', 'rate': '80'},
    //   {'name': 'Paneer Tikka', 'tag': 'Veg', 'rate': '120'},
    //   {'name': 'Hara Bhara Kebab', 'tag': 'Veg', 'rate': '100'},
    //   {'name': 'Chili Paneer', 'tag': 'Veg', 'rate': '140'},
    //   {'name': 'Methi Malai Murg', 'tag': 'Non-Veg', 'rate': '200'},
    //   {'name': 'Prawn Koliwada', 'tag': 'Non-Veg', 'rate': '220'},
    //   {'name': 'Chicken Tikka', 'tag': 'Non-Veg', 'rate': '180'},
    //   {'name': 'Fish Pakora', 'tag': 'Non-Veg', 'rate': '160'}
    // ],
    // 'Main Course': [
    //   {'name': 'Paneer Butter Masala', 'tag': 'Veg', 'rate': '180'},
    //   {'name': 'Dal Tadka', 'tag': 'Veg', 'rate': '120'},
    //   {'name': 'Butter Chicken', 'tag': 'Non-Veg', 'rate': '250'},
    //   {'name': 'Makhani Dal', 'tag': 'Veg', 'rate': '140'},
    //   {'name': 'Chicken Biryani', 'tag': 'Non-Veg', 'rate': '250'},
    //   {'name': 'Vegetable Biryani', 'tag': 'Veg', 'rate': '200'}
    // ],
    // 'Desserts': [
    //   {'name': 'Gulab Jamun', 'tag': 'Veg', 'rate': '60'},
    //   {'name': 'Ice Cream', 'tag': 'Veg', 'rate': '80'},
    //   {'name': 'Brownie', 'tag': 'Veg', 'rate': '100'},
    //   {'name': 'Ras Malai', 'tag': 'Veg', 'rate': '120'}
    // ]
  };

  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> orderItems = [];
  var selectedOrderId;
  bool isLoadingOrders = true;
  bool isLoadingItems = false;
  String _selectedCategory = "Main Course";
  Map<String, Map<String, dynamic>> itemMap = {};
  String ordernumber = "";

  @override
  void initState() {
    _menuItemsFuture = fetchMenuItems();
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      isLoadingOrders = true;
    });

    try {
      orders = widget.orders;
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

  Future<Map<String, List<Map<String, String>>>> fetchMenuItems() async {
    try {
      // Await the future to get the actual list
      final List<dynamic> data = await itemsApiService.fetchAllItems();

      // Clear the existing categories and menu items to avoid duplicates
      _categories.clear();
      _menuItems.clear();

      // Iterate over the list to transform API data into the required structure
      for (var item in data) {
        String category = item['category'];

        // Add category to the _categories list if it's not already present
        if (!_categories.contains(category)) {
          _categories.add(category);
          _menuItems[category] = [];
        }

        // Add the item to the appropriate category
        _menuItems[category]?.add({
          'name': item['item_name'],
          'tag': item['tag'],
          'rate': item['price'].toString(),
          'tax': item['tax_rate'].toString(),
          'discountable': item['discountable'].toString()
        });
      }

      // Set the default selected category (e.g., the first category in the _categories list)
      if (_categories.isNotEmpty) {
        setState(() {
          _selectedCategory = _categories.first;
        });
      }

      return _menuItems;
    } catch (e) {
      throw Exception("Error fetching items: $e");
    }
  }

  void _saveOrder(String orderId) async {
    try {
      double totalAmount = 0;
      double totaltax = 0;
      double totalamt = 0;
      List<Map<String, dynamic>> items = [];

      // Helper function to find category from _menuItems
      String findCategory(String itemName) {
        for (var category in _menuItems.keys) {
          if (_menuItems[category]?.any((item) => item['name'] == itemName) ??
              false) {
            return category;
          }
        }
        return 'Uncategorized'; // Default if no category is found
      }

      // Iterate over orderItems
      for (var item in orderItems) {
        final String itemName = item['item_name'] ?? 'Unknown';

        // Get the category for the current item
        final String category = findCategory(itemName);

        // Parse item details
        final int quantity =
            int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
        final double rate =
            double.tryParse(item['price']?.toString() ?? '0.0') ?? 0.0;
        final double taxRate =
            double.tryParse(item['tax']?.toString() ?? '0.0') ?? 0.0;
        final bool discountable = _getDiscountable(itemName);
        final double amount = rate * quantity;
        final double tax = (amount * taxRate) / 100;

        // Prepare item data
        items.add({
          'item_name': itemName,
          'item_category': category,
          'item_quantity': quantity,
          'item_rate': rate,
          'item_amount': amount,
          'taxRate': taxRate,
          'item_tax': tax,
          'total_item_value': amount + tax,
          'discountable': discountable,
        });

        // Calculate total amount (including tax)
        totalAmount += (amount + tax);
        totaltax += tax;
        totalamt += amount;
      }

      // Prepare the main order data
      final orderData = {
        'property_id': widget.propertyid,
        'tax_percentage': 0,
        'tax_value': totaltax,
        'total_amount': totalAmount,
        'discount_percentage': 0,
        'total_discount_value': 0,
        'service_charge_per': 0,
        'total_service_charge': 0,
        'total_happy_hour_discount': 0,
        'subtotal': totalamt,
        'total': totalAmount,
        'staff_id': 0,
        'order_cancelled_by': 0,
        'cancellation_reason': '',
        'updated_by': 0,
        'modified_case': true,
        'modified_by': 0,
        'modify_reason': '',
        'outlet_name': widget.outletname,
        'items': items,
        // Add other order details as needed
      };

      // Save the order to the API
      await orderApiService.updateOrder(orderId, orderData);

      setState(() {
        orderItems.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order saved successfully!')),
      );
      //  Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving order: $e')),
      );
    }
  }

  bool _getDiscountable(String itemName) {
    for (var category in _menuItems.keys) {
      final List<Map<String, String>>? categoryItems = _menuItems[category];
      if (categoryItems != null) {
        // Check if the item exists in the current category
        final item = categoryItems.firstWhere(
          (menuItem) => menuItem['name'] == itemName,
          orElse: () => <String, String>{}, // Return an empty map if not found
        );
        if (item.isNotEmpty) {
          return item['discountable'] == 'true'; // Convert string to boolean
        }
      }
    }
    return false; // Default to false if item is not found
  }

  void _showModifyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modify Order Items'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
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
                          icon: const Icon(Icons.remove),
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
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              item['quantity'] += 1;
                              item['total'] = item['quantity'] * item['price'];
                            });
                          },
                        ),
                        const SizedBox(width: 10),
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
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {}); // Save changes to the main state
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddItemDialog() {
    List<Map<String, dynamic>> topItems = [];
    List<Map<String, dynamic>> searchResults = [];

    showDialog(
      context: context,
      builder: (context) {
        // Initialize top 10 items
        if (topItems.isEmpty) {
          topItems =
              _menuItems.values.expand((items) => items).take(10).toList();
        }

        return AlertDialog(
          title: const Text('Add New Item'),
          content: StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SizedBox(
                  height: 400,
                  width: double.maxFinite,
                  child: ListView(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search Items',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchResults = _menuItems.values
                                .expand((items) => items)
                                .where((item) => item['name']
                                    .toString()
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      if (searchResults.isNotEmpty)
                        SizedBox(
                          height: 400,
                          width: double.maxFinite,
                          child: ListView.builder(
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              var item = searchResults[index];
                              int itemQty = itemMap.containsKey(item['name'])
                                  ? itemMap[item['name']]!['quantity']
                                  : 0;

                              return ListTile(
                                title: Text(item['name']),
                                subtitle: Text(
                                    'Rate: ₹${item['rate']} | Tax: ${item['tax']}%'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        setState(() {
                                          if (itemQty > 1) {
                                            itemQty--;
                                            itemMap[item['name']]!['quantity'] =
                                                itemQty;
                                            itemMap[item['name']]!['total'] =
                                                itemMap[item['name']]![
                                                        'price'] *
                                                    itemQty;
                                            orderItems =
                                                itemMap.values.toList();
                                          }
                                        });
                                      },
                                    ),
                                    Text(itemQty.toString()),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          itemQty++;
                                          if (itemMap
                                              .containsKey(item['name'])) {
                                            itemMap[item['name']]!['quantity'] =
                                                itemQty;
                                            itemMap[item['name']]!['total'] =
                                                itemMap[item['name']]![
                                                        'price'] *
                                                    itemQty;
                                          } else {
                                            itemMap[item['name']] = {
                                              'sno': itemMap.length + 1,
                                              'item_name': item['name'],
                                              'quantity': itemQty,
                                              'price': double.tryParse(
                                                      item['rate'] ?? '0.0') ??
                                                  0.0,
                                              'tax': double.tryParse(
                                                      item['tax'] ?? '0.0') ??
                                                  0.0,
                                              'total': double.tryParse(
                                                      item['rate']!)! *
                                                  itemQty,
                                              'discountable':
                                                  item['discountable']
                                                          .toString() ==
                                                      'true',
                                            };
                                          }
                                          orderItems = itemMap.values.toList();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  setState(() {});
                                },
                              );
                            },
                          ),
                        ),
                      if (searchResults.isEmpty)
                        SizedBox(
                          height: 400,
                          width: double.maxFinite,
                          child: ListView.builder(
                            itemCount: topItems.length,
                            itemBuilder: (context, index) {
                              var item = topItems[index];
                              int itemQty = itemMap.containsKey(item['name'])
                                  ? itemMap[item['name']]!['quantity']
                                  : 0;

                              return ListTile(
                                title: Text(item['name']),
                                subtitle: Text(
                                    'Rate: ₹${item['rate']} | Tax: ${item['tax']}%'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        setState(() {
                                          if (itemQty > 1) {
                                            itemQty--;
                                            itemMap[item['name']]!['quantity'] =
                                                itemQty;
                                            itemMap[item['name']]!['total'] =
                                                itemMap[item['name']]![
                                                        'price'] *
                                                    itemQty;
                                          }
                                          orderItems = itemMap.values.toList();
                                        });
                                      },
                                    ),
                                    Text(itemQty.toString()),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          itemQty++;
                                          if (itemMap
                                              .containsKey(item['name'])) {
                                            itemMap[item['name']]!['quantity'] =
                                                itemQty;
                                            itemMap[item['name']]!['total'] =
                                                itemMap[item['name']]![
                                                        'price'] *
                                                    itemQty;
                                          } else {
                                            itemMap[item['name']] = {
                                              'sno': itemMap.length + 1,
                                              'item_name': item['name'],
                                              'quantity': itemQty,
                                              'price': double.tryParse(
                                                      item['rate'] ?? '0.0') ??
                                                  0.0,
                                              'tax': double.tryParse(
                                                      item['tax'] ?? '0.0') ??
                                                  0.0,
                                              'total': double.tryParse(
                                                      item['rate']!)! *
                                                  itemQty,
                                              'discountable':
                                                  item['discountable']
                                                          .toString() ==
                                                      'true',
                                            };
                                          }
                                          orderItems = itemMap.values.toList();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Save changes to the main state
                  //  orderItems = itemMap.values.toList();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order List')),
      body: FutureBuilder<Map<String, List<Map<String, String>>>>(
          future: _menuItemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator while waiting for data
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Handle error
              return Center(
                  child: Text('Error loading menu items: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              return Row(
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
                                  selectedOrderId =
                                      order['order_id'].toString();
                                  ordernumber =
                                      order['order_number'].toString();
                                  _fetchOrderItems([selectedOrderId as String]);
                                });
                              },
                              selected: selectedOrderId ==
                                  order['order_id'].toString(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Colors.white,
                      child: selectedOrderId != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Order Details',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text('Order No: $ordernumber'),
                                const Divider(),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: itemMap.length,
                                    itemBuilder: (context, index) {
                                      final item =
                                          itemMap.values.toList()[index];
                                      return ListTile(
                                        title: Text(item["item_name"]),
                                        subtitle: Text(
                                            'Quantity: ${item["quantity"]}'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('₹${item["total"]}'),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                // Confirm deletion with the user
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Delete Item'),
                                                      content: Text(
                                                          'Are you sure you want to delete "${item["item_name"]}" from the order?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                              'Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            // Remove the item from the map
                                                            setState(() {
                                                              itemMap.remove(item[
                                                                  "item_name"]);
                                                              orderItems.removeWhere((orderItem) =>
                                                                  orderItem[
                                                                          "item_name"]
                                                                      .toString() ==
                                                                  item["item_name"]
                                                                      .toString());
                                                            });
                                                            // _saveOrder(
                                                            //     selectedOrderId
                                                            //         .toString());
                                                            // Close the dialog
                                                            Navigator.pop(
                                                                context);
                                                            // Show a confirmation message
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    '"${item["item_name"]}" has been removed from the order.'),
                                                              ),
                                                            );
                                                          },
                                                          child: const Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
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
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _showModifyDialog,
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Modify'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _showAddItemDialog,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add Item'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          orders.removeWhere((order) =>
                                              order['order_id'].toString() ==
                                              selectedOrderId.toString());
                                          itemMap.remove(selectedOrderId);
                                          orderApiService.deleteOrder(
                                              selectedOrderId.toString());
                                          selectedOrderId = null;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Order deleted'),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.delete),
                                      label: const Text('Delete'),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _saveOrder(selectedOrderId.toString());
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Printing order $selectedOrderId'),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.print),
                                      label: const Text('Save'),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : const Center(
                              child: Text(
                                'Select an Order from the left panel',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                    ),
                  ),
                ],
              );
            }
            return const CircularProgressIndicator();
          }),
    );
  }
}
