import 'package:flutter/material.dart';
import 'package:point_of_sale_system/backend/OrderApiService.dart';
import 'package:point_of_sale_system/backend/items_api_service.dart';

class ModifyOrderList extends StatefulWidget {
  final orders;
  const ModifyOrderList({super.key, required this.orders});
  @override
  _ModifyOrderListState createState() => _ModifyOrderListState();
}

class _ModifyOrderListState extends State<ModifyOrderList> {
  OrderApiService orderApiService =
      OrderApiService(baseUrl: 'http://localhost:3000/api');
  final List<String> _categories = ['Starters', 'Main Course', 'Desserts'];
  ItemsApiService itemsApiService =
      ItemsApiService(baseUrl: 'http://localhost:3000/api');
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
  Map<String, int> _orderItems = {};
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
          title: Text('Add New Item'),
          content: StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 400),
                child: Container(
                  height: 400,
                  width: double.maxFinite,
                  child: ListView(
                    children: [
                      TextField(
                        decoration: InputDecoration(
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
                      SizedBox(height: 10),
                      if (searchResults.isNotEmpty)
                        Container(
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
                                      icon: Icon(Icons.remove),
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
                                      icon: Icon(Icons.add),
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
                        Container(
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
                                      icon: Icon(Icons.remove),
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
                                      icon: Icon(Icons.add),
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
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Save changes to the main state
                  //  orderItems = itemMap.values.toList();
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // void _showAddItemDialog() {
  //   String? selectedCategory;
  //   String? selectedItem;
  //   int quantity = 1;
  //   double rate = 0.0;
  //   double tax = 0.0;
  //   double amount = 0.0;
  //   bool discountable = false;
  //   List<String> itemNames = [];
  //   List<Map<String, dynamic>> topItems = [];
  //   List<Map<String, dynamic>> searchResults = [];

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder:
  //             (BuildContext context, void Function(void Function()) setState) {
  //           void _updateAmount() {
  //             amount = (rate * quantity) + ((rate * quantity) * (tax / 100));
  //           }

  //           // Initialize the top 10 items
  //           if (topItems.isEmpty) {
  //             topItems =
  //                 _menuItems.values.expand((items) => items).take(10).toList();
  //           }

  //           return AlertDialog(
  //             title: Column(
  //               children: [
  //                 TextField(
  //                   decoration: InputDecoration(
  //                     hintText: 'Search Items',
  //                     prefixIcon: Icon(Icons.search),
  //                   ),
  //                   onChanged: (value) {
  //                     setState(() {
  //                       searchResults = _menuItems.values
  //                           .expand((items) => items)
  //                           .where((item) => item['name']
  //                               .toString()
  //                               .toLowerCase()
  //                               .contains(value.toLowerCase()))
  //                           .toList();
  //                     });
  //                   },
  //                 ),
  //                 SizedBox(height: 10),
  //                 Text('Add New Item'),
  //               ],
  //             ),
  //             content: SingleChildScrollView(
  //               child: ConstrainedBox(
  //                 constraints:
  //                     BoxConstraints(maxHeight: 400), // Set a max height
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     // Search results list
  //                     if (searchResults.isNotEmpty)
  //                       Container(
  //                         height: 400,
  //                         width: double.maxFinite,
  //                         child: ListView.builder(
  //                           shrinkWrap: true, // Prevents infinite height
  //                           physics: NeverScrollableScrollPhysics(),
  //                           itemCount: searchResults.length,
  //                           itemBuilder: (context, index) {
  //                             var item = searchResults[index];
  //                             int itemQty = itemMap.containsKey(item['name'])
  //                                 ? itemMap[item['name']]!['quantity']
  //                                 : 0;

  //                             return ListTile(
  //                               title: Text(item['name']),
  //                               subtitle: Text(
  //                                   'Rate: ₹${item['rate']} | Tax: ${item['tax']}%'),
  //                               trailing: Row(
  //                                 mainAxisSize: MainAxisSize.min,
  //                                 children: [
  //                                   IconButton(
  //                                     icon: Icon(Icons.remove),
  //                                     onPressed: () {
  //                                       setState(() {
  //                                         if (itemQty > 0) {
  //                                           itemQty--;
  //                                           itemMap[item['name']]!['quantity'] =
  //                                               itemQty;
  //                                           _updateAmount();
  //                                         }
  //                                       });
  //                                     },
  //                                   ),
  //                                   Text(itemQty.toString()),
  //                                   IconButton(
  //                                     icon: Icon(Icons.add),
  //                                     onPressed: () {
  //                                       setState(() {
  //                                         itemQty++;
  //                                         itemMap[item['name']]!['quantity'] =
  //                                             itemQty;
  //                                         _updateAmount();
  //                                       });
  //                                     },
  //                                   ),
  //                                 ],
  //                               ),
  //                               onTap: () {
  //                                 setState(() {
  //                                   selectedItem = item['name'];
  //                                   rate = double.tryParse(
  //                                           item['rate'] ?? '0.0') ??
  //                                       0.0;
  //                                   tax =
  //                                       double.tryParse(item['tax'] ?? '0.0') ??
  //                                           0.0;
  //                                   discountable =
  //                                       item['discountable'] == 'true';
  //                                   _updateAmount();
  //                                 });
  //                               },
  //                             );
  //                           },
  //                         ),
  //                       ),
  //                     // Top items list
  //                     if (searchResults.isEmpty)
  //                       Container(
  //                         height: 400,
  //                         width: double.maxFinite,
  //                         child: ListView.builder(
  //                           shrinkWrap: true,
  //                           physics: NeverScrollableScrollPhysics(),
  //                           itemCount: topItems.length,
  //                           itemBuilder: (context, index) {
  //                             var item = topItems[index];
  //                             int itemQty = itemMap.containsKey(item['name'])
  //                                 ? itemMap[item['name']]!['quantity']
  //                                 : 0;

  //                             return ListTile(
  //                               title: Text(item['name']),
  //                               subtitle: Text(
  //                                   'Rate: ₹${item['rate']} | Tax: ${item['tax']}%'),
  //                               trailing: Row(
  //                                 mainAxisSize: MainAxisSize.min,
  //                                 children: [
  //                                   IconButton(
  //                                     icon: Icon(Icons.remove),
  //                                     onPressed: () {
  //                                       setState(() {
  //                                         if (itemQty > 0) {
  //                                           itemQty--;
  //                                           itemMap[item['name']]!['quantity'] =
  //                                               itemQty;
  //                                           _updateAmount();
  //                                         }
  //                                       });
  //                                     },
  //                                   ),
  //                                   Text(itemQty.toString()),
  //                                   IconButton(
  //                                     icon: Icon(Icons.add),
  //                                     onPressed: () {
  //                                       setState(() {
  //                                         itemQty++;
  //                                         itemMap[item['name']]!['quantity'] =
  //                                             itemQty;
  //                                         _updateAmount();
  //                                       });
  //                                     },
  //                                   ),
  //                                 ],
  //                               ),
  //                             );
  //                           },
  //                         ),
  //                       ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: Text('Cancel'),
  //               ),
  //               ElevatedButton(
  //                 onPressed: selectedItem != null
  //                     ? () {
  //                         setState(() {
  //                           if (itemMap.containsKey(selectedItem)) {
  //                             itemMap[selectedItem]!['quantity'] += quantity;
  //                             itemMap[selectedItem]!['total'] =
  //                                 itemMap[selectedItem]!['quantity'] * rate +
  //                                     (itemMap[selectedItem]!['quantity'] *
  //                                         rate *
  //                                         (tax / 100));
  //                           } else {
  //                             itemMap[selectedItem!] = {
  //                               'sno': itemMap.length + 1,
  //                               'item_name': selectedItem,
  //                               'quantity': quantity,
  //                               'price': rate,
  //                               'tax': tax,
  //                               'total': amount,
  //                               'discountable': discountable,
  //                             };
  //                           }
  //                         });
  //                         Navigator.of(context).pop();
  //                       }
  //                     : null,
  //                 child: Text('Add Item'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order List')),
      body: FutureBuilder<Map<String, List<Map<String, String>>>>(
          future: _menuItemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator while waiting for data
              return Center(child: CircularProgressIndicator());
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
                      padding: EdgeInsets.all(16.0),
                      color: Colors.white,
                      child: selectedOrderId != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order Details',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text('Order No: ${ordernumber}'),
                                Divider(),
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
                                              icon: Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                // Confirm deletion with the user
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title:
                                                          Text('Delete Item'),
                                                      content: Text(
                                                          'Are you sure you want to delete "${item["item_name"]}" from the order?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text('Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            // Remove the item from the map
                                                            setState(() {
                                                              itemMap.remove(item[
                                                                  "item_name"]);
                                                            });

                                                            // Close the dialog
                                                            Navigator.of(
                                                                    context)
                                                                .pop();

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
                                                          child: Text(
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
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _showModifyDialog,
                                      icon: Icon(Icons.edit),
                                      label: Text('Modify'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _showAddItemDialog,
                                      icon: Icon(Icons.add),
                                      label: Text('Add Item'),
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
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
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
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Printing order $selectedOrderId'),
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
              );
            }
            return CircularProgressIndicator();
          }),
    );
  }
}