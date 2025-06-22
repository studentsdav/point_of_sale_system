import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../backend/order/OrderApiService.dart';
import '../../backend/order/items_api_service.dart';
import '../../backend/order/waiterApiService.dart';

class KOTFormScreen extends StatefulWidget {
  final tableno;
  final propertyid;
  final outlet;
  const KOTFormScreen(
      {super.key,
      required this.propertyid,
      required this.outlet,
      required this.tableno});

  @override
  _KOTFormScreenState createState() => _KOTFormScreenState();
}

class _KOTFormScreenState extends State<KOTFormScreen> {
  OrderApiService orderApiService = OrderApiService();
  ItemsApiService itemsApiService = ItemsApiService();
  WaiterApiService waiterApiService = WaiterApiService();
  final List<String> _categories = ['Starters', 'Main Course', 'Desserts'];
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

  final Map<String, Map<String, int>> _orderItems =
      {}; // Keeps track of selected items and their quantities
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  String _selectedCategory = "Main Course";
  String _tableNumber = "";
  String _waiterName = '';
  int _personCount = 1;
  List<Map<String, dynamic>> _waiters = []; // Store waiter list
  // final double taxRate = 0.1; // 10% tax rate, adjust as needed

  // Generating a random order number using the current time and random component
  String _orderNumber = "";
  List<Map<String, String>> searchResults = [];

  @override
  void initState() {
    _tableNumber = widget.tableno;
    _menuItemsFuture = fetchMenuItems();
    _searchController.addListener(() {
      _updateSearchResults();
    });
    fetchWaiters();
    super.initState();
    getOrderNumber();
  }

  Future<void> getOrderNumber() async {
    final ordernumber = await orderApiService.getMaxOrderNo(widget.outlet);
    setState(() {
      _orderNumber = ordernumber['nextOrderNumber'].toString();
    });
  }

  void _addItem(String item) {
    setState(() {
      if (_orderItems[_selectedCategory] == null) {
        _orderItems[_selectedCategory] = {};
      }
      if (_orderItems[_selectedCategory]![item] == null) {
        _orderItems[_selectedCategory]![item] =
            1; // Start with 1 item by default
      } else {
        _orderItems[_selectedCategory]![item] =
            _orderItems[_selectedCategory]![item]! + 1;
      }
    });
  }

  void _removeItem(String item) {
    setState(() {
      if (_orderItems[_selectedCategory] != null &&
          _orderItems[_selectedCategory]![item] != null &&
          _orderItems[_selectedCategory]![item]! > 0) {
        _orderItems[_selectedCategory]![item] =
            _orderItems[_selectedCategory]![item]! - 1;

        if (_orderItems[_selectedCategory]![item] == 0) {
          // Remove the item completely when its quantity is 0
          _orderItems[_selectedCategory]!.remove(item);
        }
      }
    });
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

  void _saveOrder() async {
    try {
      double totalAmount = 0;
      double totaltaxvalue = 0;
      List<Map<String, dynamic>> items = [];

      // Collect items and calculate total amounts
      for (var category in _orderItems.keys) {
        for (var itemName in _orderItems[category]!.keys) {
          final qty = _orderItems[category]![itemName]!;
          final itemDetails = _menuItems[category]!
              .firstWhere((item) => item['name'] == itemName);
          final rate = double.parse(itemDetails['rate']!);
          final taxRate = double.parse(itemDetails['tax']!);
          final discountable = bool.parse(itemDetails['discountable']!);
          final amount = rate * qty;
          final tax = (amount * taxRate) / 100;

          // Prepare item data
          final itemData = {
            'item_name': itemName,
            'item_category': category,
            'item_quantity': qty,
            'item_rate': rate,
            'item_amount': amount,
            'taxRate': taxRate,
            'item_tax': tax,
            'total_item_value': amount + tax,
            'discountable': discountable
          };

          // Add item data to the list of items
          items.add(itemData);

          // Calculate total amount (including tax)
          totalAmount += amount;
          totaltaxvalue += tax;
        }
      }

      // Prepare the main order data (only required fields)
      final orderData = {
        'order_number': _orderNumber,
        'table_number': _tableNumber,
        'waiter_name': _waiterName,
        'person_count': _personCount,
        'remarks': _remarksController.text,
        'property_id': widget.propertyid, // Use actual property_id if needed
        'guest_id': 0, // Use actual guest_id if needed
        'customer_name': '',
        'customer_contact': '',
        'payment_method': '',
        'payment_status': '',
        'payment_date':
            DateTime.now().toIso8601String(), // Use actual timestamp here
        'transaction_id': '',
        'tax_percentage': 0,
        'tax_value': totaltaxvalue,
        'total_amount': totalAmount,
        'discount_percentage': 0,
        'total_discount_value': 0,
        'service_charge_per': 0,
        'total_service_charge': 0,
        'total_happy_hour_discount': 0,
        'subtotal': totalAmount,
        'total': totalAmount,
        'cashier': '',
        'status': 'Pending',
        'order_type': 'Dine-in',
        'order_notes': '',
        'is_priority_order': false,
        'customer_feedback': '',
        'staff_id': 0,
        'order_cancelled_by': 0,
        'cancellation_reason': '',
        'created_by': 0,
        'updated_by': 0,
        'delivery_address': '',
        'delivery_time': DateTime.now().toIso8601String(), // Timestamp
        'order_received_time': DateTime.now().toIso8601String(), // Timestamp
        'order_ready_time': DateTime.now().toIso8601String(), // Timestamp
        'served_by': '',
        'payment_method_details': '',
        'dining_case': true,
        'packing_case': false,
        'complimentary_case': false,
        'cancelled_case': false,
        'modified_case': false,
        'bill_generated': false,
        'bill_generated_at': DateTime.now().toIso8601String(), // Timestamp
        'bill_payment_status': '',
        'partial_payment': 0,
        'final_payment': 0,
        'order_type_change': false,
        'modified_by': 0,
        'modify_reason': '',
        'refund_status': '',
        'refund_amount': 0,
        'refund_date': DateTime.now().toIso8601String(), // Timestamp
        'refund_processed_by': 0,
        'refund_reason': '',
        'outlet_name': widget.outlet,
        'items': items
      };

      // Send the order data with all items
      await orderApiService.createOrder(orderData);
      await _generateAndSavePdf();

      setState(() {
        _orderItems.clear();
        _orderNumber = '';
        _tableNumber = '';
        _waiterName = '';
        _personCount = 0;
        _remarksController.text = "";
      });

      // Notify user once the order is saved successfully
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order saved successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      // Show error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving order: $e')),
      );
    }
  }

  Future<void> _generateAndSavePdf() async {
    final pdf = pw.Document();

    // Set page format for 80mm width paper
    const pageWidth = 80.0 * PdfPageFormat.mm; // 80mm
    const pageHeight = double.infinity; // Variable height for continuous roll
    const pageFormat = PdfPageFormat(pageWidth, pageHeight);

    pdf.addPage(pw.Page(
      pageFormat: pageFormat,
      margin: const pw.EdgeInsets.symmetric(
          horizontal: 5, vertical: 10), // Add margins
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header Section
            pw.Text('Order Receipt',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black)),
            pw.SizedBox(height: 5),
            pw.Text('Order Number: $_orderNumber',
                style:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.Text(
                'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
            pw.Divider(thickness: 0.8, color: PdfColors.grey),
            pw.SizedBox(height: 5),

            // Order Items Section
            for (var category in _orderItems.entries) ...[
              pw.Text(category.key.toUpperCase(),
                  style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black)),
              pw.SizedBox(height: 5),
              ...category.value.entries.map((entry) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(entry.key, style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('x ${entry.value}',
                        style: const pw.TextStyle(fontSize: 9)),
                  ],
                );
              }),
              pw.SizedBox(height: 10),
            ],
            pw.Divider(thickness: 0.8, color: PdfColors.grey),

            // Footer Section
            pw.SizedBox(height: 10),
            pw.Text('Thank you for your order!',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.green)),
            pw.SizedBox(height: 5),
            pw.Text('Contact Us: contact@business.com',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
          ],
        );
      },
    ));

    // Save the receipt
    final directory = Directory(
        'C:\\Users\\Public\\Documents'); // Specify the path for saving
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }

    final file = File('${directory.path}\\order_$_orderNumber.pdf');
    await file.writeAsBytes(await pdf.save());

    print("PDF saved at: ${file.path}");
    Process.run('explorer', [file.path]).then((result) {
      print("Opened PDF in default viewer: ${result.stdout}");
    });
  }

  void _printOrder() {
    _generateAndSavePdf();
    // Implement print logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Printing Order...')),
    );
  }

  void _updateSearchResults() {
    setState(() {
      searchResults = _menuItems.values
          .expand((items) => items)
          .where((item) => item['name']!
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> fetchWaiters() async {
    try {
      final responseData = await waiterApiService.getAllWaiters();

      setState(() {
        _waiters = List<Map<String, dynamic>>.from(responseData);
        if (_waiters.isNotEmpty) {
          _waiterName = _waiters.first['waiter_name'];
        }
      });
    } catch (error) {
      print('Error fetching waiters: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<Map<String, String>>>>(
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
            // Data is available

            // If no category is selected, default to the first one
            return Scaffold(
              appBar: AppBar(
                title: const Text('Create KOT'),
                backgroundColor: Colors.teal,
              ),
              body: Row(
                children: [
                  // Category Strip
                  Container(
                    width: 120,
                    color: Colors.grey.shade200,
                    child: ListView.builder(
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return ListTile(
                          selected: _selectedCategory == category,
                          title: Text(category, style: const TextStyle(fontSize: 14)),
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Order Number: $_orderNumber',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search Items',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView(
                              children: _menuItems[_selectedCategory]!
                                  .where((item) => item['name']!
                                      .toLowerCase()
                                      .contains(
                                          _searchController.text.toLowerCase()))
                                  .map((item) => ListTile(
                                        title: Row(
                                          children: [
                                            Text(item['name']!),
                                            const SizedBox(width: 10),
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: item['tag'] == 'Veg'
                                                    ? Colors.green
                                                    : Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text('₹${item['rate']}',
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: () =>
                                                  _removeItem(item['name']!),
                                            ),
                                            Text(
                                                '${_orderItems[_selectedCategory]?[item['name']!] ?? 0}'),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () =>
                                                  _addItem(item['name']!),
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _remarksController,
                            decoration: const InputDecoration(
                              labelText: 'Remarks',
                              prefixIcon: Icon(Icons.comment),
                            ),
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: _waiters.isNotEmpty
                                ? _waiters.any((waiter) =>
                                        waiter['waiter_id'].toString() ==
                                        _waiterName)
                                    ? _waiterName
                                    : null
                                : null, // Ensure value is valid or null
                            decoration: const InputDecoration(
                              labelText: 'Select Waiter',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                            items: _waiters.map((waiter) {
                              return DropdownMenuItem<String>(
                                value:
                                    waiter['waiter_id'].toString(), // Store ID
                                child:
                                    Text(waiter['waiter_name']), // Display Name
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _waiterName = value!;
                              });
                              print('Selected Waiter ID: $value');
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            initialValue: _tableNumber.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (value) =>
                                setState(() => _tableNumber = value ?? "1"),
                            decoration: const InputDecoration(
                              labelText: 'Table Number',
                              prefixIcon: Icon(Icons.table_bar),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            initialValue: _personCount.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => setState(
                                () => _personCount = int.tryParse(value) ?? 1),
                            decoration: const InputDecoration(
                              labelText: 'Person Count',
                              prefixIcon: Icon(Icons.people),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: _saveOrder,
                                child: const Text('Save Order'),
                              ),
                              ElevatedButton(
                                onPressed: _printOrder,
                                child: const Text('Print Order'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ordered Items',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView(
                              children: [
                                ..._orderItems.entries.expand((entry) {
                                  return entry.value.entries.map((itemEntry) {
                                    final itemName = itemEntry.key;
                                    final quantity = itemEntry.value;
                                    final itemRate = double.tryParse(
                                          _menuItems.values
                                              .expand((categoryItems) =>
                                                  categoryItems)
                                              .firstWhere(
                                                  (item) =>
                                                      item['name'] == itemName,
                                                  orElse: () =>
                                                      {'rate': '0'})['rate']!,
                                        ) ??
                                        0.0;
                                    final itemtax = double.tryParse(
                                          _menuItems.values
                                              .expand((categoryItems) =>
                                                  categoryItems)
                                              .firstWhere(
                                                  (item) =>
                                                      item['name'] == itemName,
                                                  orElse: () =>
                                                      {'tax': '0'})['tax']!,
                                        ) ??
                                        0.0;

                                    final itemAmount = itemRate * quantity;
                                    final itemTax =
                                        (itemAmount * itemtax) / 100;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 16.0),
                                      child: Card(
                                        elevation: 3.0,
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10.0,
                                                  horizontal: 16.0),
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(itemName,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text('₹$itemRate',
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black)),
                                            ],
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('Qty: $quantity',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.remove),
                                                        onPressed: quantity > 0
                                                            ? () => _removeItem(
                                                                itemName)
                                                            : null,
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.add),
                                                        onPressed: () =>
                                                            _addItem(itemName),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.delete),
                                                        onPressed: () =>
                                                            _deleteItem(
                                                                itemName),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                  'Amount: ₹${itemAmount.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(
                                                  'Tax: ₹${itemTax.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      color: Colors.grey)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList();
                                }),

                                // Summary section for Total Amount and Total Tax
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Divider(thickness: 1.5),
                                      const Text('Summary',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 10),
                                      Text(
                                          'Total Amount: ₹${_calculateTotalAmount().toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          'Total Tax: ₹${_calculateTotalTax().toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Grand Total: ₹${(_calculateTotalAmount() + _calculateTotalTax()).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          }
          return const CircularProgressIndicator();
        });
  }

// Helper methods to calculate total amount and total tax
  double _calculateTotalAmount() {
    return _orderItems.entries.fold(0.0, (total, entry) {
      return total +
          entry.value.entries.fold(0.0, (subtotal, itemEntry) {
            final itemName = itemEntry.key;
            final quantity = itemEntry.value;
            final itemRate = double.tryParse(
                  _menuItems.values
                      .expand((categoryItems) => categoryItems)
                      .firstWhere((item) => item['name'] == itemName,
                          orElse: () => {'rate': '0'})['rate']!,
                ) ??
                0.0;
            return subtotal + (itemRate * quantity);
          });
    });
  }

  double _calculateTotalTax() {
    return _orderItems.entries.fold(0.0, (total, entry) {
      return total +
          entry.value.entries.fold(0.0, (subtotal, itemEntry) {
            final itemName = itemEntry.key;
            final itemQuantity = itemEntry.value;

            // Find the item in _menuItems and handle missing items
            final itemData = _menuItems.values
                .expand((categoryItems) => categoryItems)
                .firstWhere(
                  (item) => item['name'] == itemName,
                  orElse: () => {},
                );

            if (itemData.isEmpty || !itemData.containsKey('tax')) {
              return subtotal; // Skip if no tax info
            }

            final itemTaxRate = double.tryParse(itemData['tax'] ?? '0') ?? 0.0;
            final itemPrice = double.tryParse(itemData['rate'] ?? '0') ?? 0.0;

            // Calculate tax for this item and quantity
            final itemTax = (itemPrice * itemTaxRate / 100) * itemQuantity;
            return subtotal + itemTax;
          });
    });
  }

  void _deleteItem(String item) {
    setState(() {
      if (_orderItems[_selectedCategory] != null) {
        _orderItems[_selectedCategory]!
            .remove(item); // Completely remove the item from the order
      }
    });
  }
}
