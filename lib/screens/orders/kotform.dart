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
  body: LayoutBuilder(builder: (context, constraints) {
    final isWide = constraints.maxWidth > 600;
    final filteredItems = _menuItems[_selectedCategory]!
        .where((item) => item['name']!
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
        .toList();

    final tabs = CategoryTabs(
      categories: _categories,
      selected: _selectedCategory,
      onSelect: (c) => setState(() => _selectedCategory = c),
      isVertical: isWide,
    );

    final grid = MenuItemGrid(
      items: filteredItems,
      orderItems: _orderItems,
      category: _selectedCategory,
      onAdd: _addItem,
      onRemove: _removeItem,
    );

    final summary = OrderSummaryPanel(
      orderItems: _orderItems,
      menuItems: _menuItems,
      remarksController: _remarksController,
      waiters: _waiters,
      waiterName: _waiterName,
      personCount: _personCount,
      tableNumber: _tableNumber,
      onWaiterChanged: (v) => setState(() => _waiterName = v),
      onTableChanged: (v) => setState(() => _tableNumber = v),
      onPersonChanged: (v) => setState(() => _personCount = v),
      onSave: _saveOrder,
      onPrint: _printOrder,
      onAdd: _addItem,
      onRemove: _removeItem,
      onDelete: _deleteItem,
      isWide: isWide,
    );

    final content = Column(
      children: [
        Text('Order Number: \$_orderNumber',
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
        Expanded(child: grid),
      ],
    );

    if (isWide) {
      return Row(
        children: [
          tabs,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: content,
            ),
          ),
          summary,
        ],
      );
    } else {
      return Column(
        children: [
          tabs,
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(height: 230, child: content),
          ),
          summary,
        ],
      );
    }
  }),
  );
          }
          return const CircularProgressIndicator();
        });
  void _deleteItem(String item) {
    setState(() {
      if (_orderItems[_selectedCategory] != null) {
        _orderItems[_selectedCategory]!
            .remove(item); // Completely remove the item from the order
      }
    });
  }
}

// Reusable widget for displaying category tabs. Shows a vertical list on wide
// screens and a horizontal strip on narrow screens.
class CategoryTabs extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;
  final bool isVertical;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelect,
    this.isVertical = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return Container(
        width: 120,
        color: Colors.grey.shade200,
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return ListTile(
              selected: selected == category,
              title: Text(category, style: const TextStyle(fontSize: 14)),
              onTap: () => onSelect(category),
            );
          },
        ),
      );
    } else {
      return SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () => onSelect(category),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: selected == category
                      ? Colors.teal.shade200
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(category,
                    style: const TextStyle(fontSize: 14)),
              ),
            );
          },
        ),
      );
    }
  }
}

// Grid widget for menu items with icon placeholders and quantity controls.
class MenuItemGrid extends StatelessWidget {
  final List<Map<String, String>> items;
  final Map<String, Map<String, int>> orderItems;
  final String category;
  final void Function(String) onAdd;
  final void Function(String) onRemove;

  const MenuItemGrid({
    super.key,
    required this.items,
    required this.orderItems,
    required this.category,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 3 / 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(
                      child: Icon(
                        item['tag'] == 'Veg'
                            ? Icons.local_dining
                            : Icons.set_meal,
                        size: 32,
                        color: item['tag'] == 'Veg'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                  Text(item['name']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text('₹${item['rate']}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => onRemove(item['name']!),
                        visualDensity: VisualDensity.compact,
                      ),
                      Text('${orderItems[category]?[item['name']] ?? 0}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => onAdd(item['name']!),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

// Side or bottom panel that shows ordered items and actions.
class OrderSummaryPanel extends StatelessWidget {
  final Map<String, Map<String, int>> orderItems;
  final Map<String, List<Map<String, String>>> menuItems;
  final TextEditingController remarksController;
  final List<Map<String, dynamic>> waiters;
  final String waiterName;
  final int personCount;
  final String tableNumber;
  final Function(String) onWaiterChanged;
  final Function(String) onTableChanged;
  final Function(int) onPersonChanged;
  final VoidCallback onSave;
  final VoidCallback onPrint;
  final void Function(String) onAdd;
  final void Function(String) onRemove;
  final void Function(String) onDelete;
  final bool isWide;

  const OrderSummaryPanel({
    super.key,
    required this.orderItems,
    required this.menuItems,
    required this.remarksController,
    required this.waiters,
    required this.waiterName,
    required this.personCount,
    required this.tableNumber,
    required this.onWaiterChanged,
    required this.onTableChanged,
    required this.onPersonChanged,
    required this.onSave,
    required this.onPrint,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final summary = _buildSummaryList();
    final panel = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ordered Items',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Expanded(child: summary),
        const SizedBox(height: 10),
        TextFormField(
          controller: remarksController,
          decoration: const InputDecoration(
            labelText: 'Remarks',
            prefixIcon: Icon(Icons.comment),
          ),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          value: waiters.isNotEmpty &&
                  waiters.any((w) => w['waiter_id'].toString() == waiterName)
              ? waiterName
              : null,
          decoration: const InputDecoration(
            labelText: 'Select Waiter',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          items: waiters.map((waiter) {
            return DropdownMenuItem<String>(
              value: waiter['waiter_id'].toString(),
              child: Text(waiter['waiter_name']),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onWaiterChanged(value);
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: tableNumber,
          keyboardType: TextInputType.number,
          onChanged: onTableChanged,
          decoration: const InputDecoration(
            labelText: 'Table Number',
            prefixIcon: Icon(Icons.table_bar),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: personCount.toString(),
          keyboardType: TextInputType.number,
          onChanged: (v) => onPersonChanged(int.tryParse(v) ?? 1),
          decoration: const InputDecoration(
            labelText: 'Person Count',
            prefixIcon: Icon(Icons.people),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(onPressed: onSave, child: const Text('Save Order')),
            ElevatedButton(onPressed: onPrint, child: const Text('Print Order')),
          ],
        ),
      ],
    );

    return Container(
      width: isWide ? 300 : double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          left: isWide ? const BorderSide(color: Colors.grey) : BorderSide.none,
          top: !isWide ? const BorderSide(color: Colors.grey) : BorderSide.none,
        ),
      ),
      child: panel,
    );
  }

  ListView _buildSummaryList() {
    return ListView(
      children: [
        ...orderItems.entries.expand((entry) {
          return entry.value.entries.map((itemEntry) {
            final itemName = itemEntry.key;
            final quantity = itemEntry.value;
            final itemRate = double.tryParse(
                  menuItems.values
                      .expand((categoryItems) => categoryItems)
                      .firstWhere((item) => item['name'] == itemName,
                          orElse: () => {'rate': '0'})['rate']!,
                ) ??
                0.0;
            final itemTax = double.tryParse(
                  menuItems.values
                      .expand((categoryItems) => categoryItems)
                      .firstWhere((item) => item['name'] == itemName,
                          orElse: () => {'tax': '0'})['tax']!,
                ) ??
                0.0;

            final itemAmount = itemRate * quantity;
            final taxValue = (itemAmount * itemTax) / 100;

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Card(
                elevation: 2,
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(itemName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('₹$itemRate'),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Qty: $quantity'),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: quantity > 0
                                    ? () => onRemove(itemName)
                                    : null,
                                visualDensity: VisualDensity.compact,
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => onAdd(itemName),
                                visualDensity: VisualDensity.compact,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => onDelete(itemName),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          )
                        ],
                      ),
                      Text('Amount: ₹${itemAmount.toStringAsFixed(2)}'),
                      Text('Tax: ₹${taxValue.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
            );
          });
        }),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(thickness: 1.5),
              const Text('Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                'Total Amount: ₹${_calculateTotalAmount(orderItems, menuItems).toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Total Tax: ₹${_calculateTotalTax(orderItems, menuItems).toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Grand Total: ₹${(_calculateTotalAmount(orderItems, menuItems) + _calculateTotalTax(orderItems, menuItems)).toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static double _calculateTotalAmount(
      Map<String, Map<String, int>> orderItems,
      Map<String, List<Map<String, String>>> menuItems) {
    return orderItems.entries.fold(0.0, (total, entry) {
      return total + entry.value.entries.fold(0.0, (subtotal, itemEntry) {
            final itemName = itemEntry.key;
            final quantity = itemEntry.value;
            final itemRate = double.tryParse(
                  menuItems.values
                      .expand((categoryItems) => categoryItems)
                      .firstWhere((item) => item['name'] == itemName,
                          orElse: () => {'rate': '0'})['rate']!,
                ) ??
                0.0;
            return subtotal + (itemRate * quantity);
          });
    });
  }

  static double _calculateTotalTax(
      Map<String, Map<String, int>> orderItems,
      Map<String, List<Map<String, String>>> menuItems) {
    return orderItems.entries.fold(0.0, (total, entry) {
      return total + entry.value.entries.fold(0.0, (subtotal, itemEntry) {
            final itemName = itemEntry.key;
            final itemQuantity = itemEntry.value;

            final itemData = menuItems.values
                .expand((categoryItems) => categoryItems)
                .firstWhere(
                  (item) => item['name'] == itemName,
                  orElse: () => {},
                );

            if (itemData.isEmpty || !itemData.containsKey('tax')) {
              return subtotal;
            }

            final itemTaxRate =
                double.tryParse(itemData['tax'] ?? '0') ?? 0.0;
            final itemPrice =
                double.tryParse(itemData['rate'] ?? '0') ?? 0.0;

            final itemTax =
                (itemPrice * itemTaxRate / 100) * itemQuantity;
            return subtotal + itemTax;
          });
    });
  }
}
