import 'package:flutter/material.dart';
import 'dart:math'; // For generating random order numbers
import 'dart:convert';
import 'package:point_of_sale_system/backend/OrderApiService.dart';

class KOTFormScreen extends StatefulWidget {
  final tableno;
  final propertyid;
  final outlet;
  const KOTFormScreen(
      {Key? key,
      required this.propertyid,
      required this.outlet,
      required this.tableno})
      : super(key: key);

  @override
  _KOTFormScreenState createState() => _KOTFormScreenState();
}

class _KOTFormScreenState extends State<KOTFormScreen> {
  OrderApiService orderApiService =
      OrderApiService(baseUrl: 'http://localhost:3000/api');
  final List<String> _categories = ['Starters', 'Main Course', 'Desserts'];

  // Menu items with their tags (Veg/Non-Veg) and rate
  final Map<String, List<Map<String, String>>> _menuItems = {
    'Starters': [
      {'name': 'Samosa', 'tag': 'Veg', 'rate': '50'},
      {'name': 'Spring Roll', 'tag': 'Veg', 'rate': '60'},
      {'name': 'Garlic Bread', 'tag': 'Veg', 'rate': '80'},
      {'name': 'Paneer Tikka', 'tag': 'Veg', 'rate': '120'},
      {'name': 'Hara Bhara Kebab', 'tag': 'Veg', 'rate': '100'},
      {'name': 'Chili Paneer', 'tag': 'Veg', 'rate': '140'},
      {'name': 'Methi Malai Murg', 'tag': 'Non-Veg', 'rate': '200'},
      {'name': 'Prawn Koliwada', 'tag': 'Non-Veg', 'rate': '220'},
      {'name': 'Chicken Tikka', 'tag': 'Non-Veg', 'rate': '180'},
      {'name': 'Fish Pakora', 'tag': 'Non-Veg', 'rate': '160'}
    ],
    'Main Course': [
      {'name': 'Paneer Butter Masala', 'tag': 'Veg', 'rate': '180'},
      {'name': 'Dal Tadka', 'tag': 'Veg', 'rate': '120'},
      {'name': 'Butter Chicken', 'tag': 'Non-Veg', 'rate': '250'},
      {'name': 'Makhani Dal', 'tag': 'Veg', 'rate': '140'},
      {'name': 'Chicken Biryani', 'tag': 'Non-Veg', 'rate': '250'},
      {'name': 'Vegetable Biryani', 'tag': 'Veg', 'rate': '200'}
    ],
    'Desserts': [
      {'name': 'Gulab Jamun', 'tag': 'Veg', 'rate': '60'},
      {'name': 'Ice Cream', 'tag': 'Veg', 'rate': '80'},
      {'name': 'Brownie', 'tag': 'Veg', 'rate': '100'},
      {'name': 'Ras Malai', 'tag': 'Veg', 'rate': '120'}
    ]
  };

  final Map<String, Map<String, int>> _orderItems =
      {}; // Keeps track of selected items and their quantities
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  String _selectedCategory = 'Starters';
  String _tableNumber = "";
  String _waiterName = '';
  int _personCount = 1;
  final double taxRate = 0.1; // 10% tax rate, adjust as needed

  // Generating a random order number using the current time and random component
  late String _orderNumber;

  @override
  void initState() {
    _tableNumber = widget.tableno;
    super.initState();
    _orderNumber =
        'ORD-${DateTime.now().millisecondsSinceEpoch % 10000}-${Random().nextInt(1000)}';
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

  void _saveOrder() async {
    try {
      double totalAmount = 0;
      List<Map<String, dynamic>> items = [];

      // Collect items and calculate total amounts
      for (var category in _orderItems.keys) {
        for (var itemName in _orderItems[category]!.keys) {
          final qty = _orderItems[category]![itemName]!;
          final itemDetails = _menuItems[category]!
              .firstWhere((item) => item['name'] == itemName);
          final rate = double.parse(itemDetails['rate']!);
          final amount = rate * qty;
          final tax = amount * taxRate;

          // Prepare item data
          final itemData = {
            'item_name': itemName,
            'item_category': category,
            'item_quantity': qty,
            'item_rate': rate,
            'item_amount': amount,
            'taxRate': taxRate * 100,
            'item_tax': tax,
            'total_item_value': amount + tax
          };

          // Add item data to the list of items
          items.add(itemData);

          // Calculate total amount (including tax)
          totalAmount += (amount + tax);
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
        'tax_percentage': taxRate * 100,
        'tax_value': totalAmount * taxRate,
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
        // 'order_number':
        //     _orderNumber, // int (Order number is typically an integer)
        // 'table_number':
        //     _tableNumber, // int (Table number is typically an integer)
        // 'waiter_name': _waiterName, // String (Name of the waiter)
        // 'person_count':
        //     _personCount, // int (Number of people, typically an integer)
        // 'remarks': _remarksController.text, // String (Text for remarks)
        // 'property_id': 0, // int (Property ID, assumed integer)
        // 'guest_id': 0, // int (Guest ID, assumed integer)
        // 'customer_name': '', // String (Customer's name)
        // 'customer_contact': '', // String (Customer's contact details)
        // 'payment_method': '', // String (Payment method used)
        // 'payment_status':
        //     '', // String (Payment status like "Paid" or "Pending")
        // 'payment_date': DateTime.now()
        //     .toIso8601String(), // String (Date in ISO 8601 string format)
        // 'transaction_id': '', // String (Transaction ID)
        // 'tax_percentage': taxRate * 100, // int (Tax percentage as an integer)
        // 'tax_value': totalAmount *
        //     taxRate, // double (Tax value, typically a decimal number)
        // 'total_amount':
        //     totalAmount, // double (Total amount, typically a decimal number)
        // 'discount_percentage': 0, // int (Discount percentage, assumed integer)
        // 'total_discount_value':
        //     0, // double (Total discount value, typically a decimal number)
        // 'service_charge_per':
        //     0, // int (Service charge percentage, assumed integer)
        // 'total_service_charge':
        //     0, // double (Total service charge value, typically a decimal number)
        // 'total_happy_hour_discount':
        //     0, // double (Happy hour discount, typically a decimal number)
        // 'subtotal':
        //     totalAmount, // double (Subtotal, typically a decimal number)
        // 'total':
        //     totalAmount, // double (Total after all calculations, typically a decimal number)
        // 'cashier': '', // String (Name of the cashier)
        // 'status': '', // String (Order status, e.g., "Completed", "Pending")
        // 'order_type': '', // String (Type of order, e.g., "Dine-in", "Takeaway")
        // 'order_notes': '', // String (Notes about the order)
        // 'is_priority_order':
        //     false, // bool (Whether the order is a priority or not)
        // 'customer_feedback': '', // String (Customer feedback about the order)
        // 'staff_id': 0, // int (Staff ID, assumed integer)
        // 'order_cancelled_by': '', // String (Who canceled the order)
        // 'cancellation_reason': '', // String (Reason for order cancellation)
        // 'created_by': 0, // int (ID of the user who created the order)
        // 'updated_by': 0, // int (ID of the user who updated the order)
        // 'delivery_address': '', // String (Address for delivery)
        // 'delivery_time': DateTime.now()
        //     .toIso8601String(), // String (Timestamp for delivery time)
        // 'order_received_time': DateTime.now()
        //     .toIso8601String(), // String (Timestamp for order received)
        // 'order_ready_time': DateTime.now()
        //     .toIso8601String(), // String (Timestamp for order ready time)
        // 'served_by': '', // String (Who served the order)
        // 'payment_method_details':
        //     '', // String (Details of the payment method used)
        // 'dining_case': true, // bool (Is it a dining case)
        // 'packing_case': false, // bool (Is it a packing case)
        // 'complimentary_case': false, // bool (Is it a complimentary case)
        // 'cancelled_case': false, // bool (Is it a cancelled case)
        // 'modified_case': false, // bool (Is it a modified case)
        // 'bill_generated': false, // bool (Whether the bill has been generated)
        // 'bill_generated_at': DateTime.now()
        //     .toIso8601String(), // String (Timestamp for bill generation)
        // 'bill_payment_status': '', // String (Status of bill payment)
        // 'partial_payment': 0, // double (Amount for partial payment)
        // 'final_payment': 0, // double (Amount for final payment)
        // 'order_type_change': false, // bool (Has the order type changed)
        // 'modified_by': 0, // int (ID of the user who modified the order)
        // 'modify_reason': '', // String (Reason for modifying the order)
        // 'refund_status':
        //     '', // String (Refund status, e.g., "Pending", "Completed")
        // 'refund_amount': 0, // double (Refund amount)
        // 'refund_date': DateTime.now()
        //     .toIso8601String(), // String (Timestamp for refund date)
        // 'refund_processed_by':
        //     0, // int (ID of the user who processed the refund)
        // 'refund_reason': '', // String (Reason for the refund)
        // 'outlet_name': '', // String (Name of the outlet)
        // 'items': items // List (A list of items included in the order)
      };

      // Send the order data with all items
      await orderApiService.createOrder(orderData);
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
        SnackBar(content: Text('Order saved successfully!')),
      );
    } catch (e) {
      // Show error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving order: $e')),
      );
    }
  }

  void _printOrder() {
    // Implement print logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Printing Order...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create KOT'),
        backgroundColor: Colors.teal,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Order Number: $_orderNumber',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Menu',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                    items: _categories
                        .map((category) => DropdownMenuItem(
                            value: category, child: Text(category)))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: _menuItems[_selectedCategory]!
                          .where((item) => item['name']!
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase()))
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
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () =>
                                          _removeItem(item['name']!),
                                    ),
                                    Text(
                                        '${_orderItems[_selectedCategory]?[item['name']!] ?? 0}'),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () => _addItem(item['name']!),
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
                  TextFormField(
                    initialValue: _waiterName,
                    onChanged: (value) => setState(() => _waiterName = value),
                    decoration: const InputDecoration(
                      labelText: 'Waiter Name',
                      prefixIcon: Icon(Icons.person),
                    ),
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
                    onChanged: (value) =>
                        setState(() => _personCount = int.tryParse(value) ?? 1),
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
                  Text('Ordered Items',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                      .expand((categoryItems) => categoryItems)
                                      .firstWhere(
                                          (item) => item['name'] == itemName,
                                          orElse: () => {'rate': '0'})['rate']!,
                                ) ??
                                0.0;

                            final itemAmount = itemRate * quantity;
                            final itemTax = itemAmount * taxRate;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Card(
                                elevation: 3.0,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 16.0),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(itemName,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text('₹$itemRate',
                                          style: TextStyle(
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
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Qty: $quantity',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500)),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.remove),
                                                onPressed: quantity > 0
                                                    ? () =>
                                                        _removeItem(itemName)
                                                    : null,
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.add),
                                                onPressed: () =>
                                                    _addItem(itemName),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete),
                                                onPressed: () =>
                                                    _deleteItem(itemName),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                          'Amount: ₹${itemAmount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          'Tax: ₹${itemTax.toStringAsFixed(2)}',
                                          style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList();
                        }).toList(),

                        // Summary section for Total Amount and Total Tax
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(thickness: 1.5),
                              Text('Summary',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              Text(
                                  'Total Amount: ₹${_calculateTotalAmount().toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  'Total Tax: ₹${_calculateTotalTax().toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              Text(
                                'Grand Total: ₹${(_calculateTotalAmount() + _calculateTotalTax()).toStringAsFixed(2)}',
                                style: TextStyle(
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
    return _calculateTotalAmount() * taxRate;
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
