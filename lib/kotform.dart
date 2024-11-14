import 'package:flutter/material.dart';
import 'dart:math'; // For generating random order numbers

class KOTFormScreen extends StatefulWidget {
  const KOTFormScreen({Key? key}) : super(key: key);

  @override
  _KOTFormScreenState createState() => _KOTFormScreenState();
}

class _KOTFormScreenState extends State<KOTFormScreen> {
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

  final Map<String, Map<String, int>> _orderItems = {}; // Keeps track of selected items and their quantities
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  String _selectedCategory = 'Starters';
  int _tableNumber = 1;
  String _waiterName = '';
  int _personCount = 1;
  final double taxRate = 0.1; // 10% tax rate, adjust as needed
  
  // Generating a random order number using the current time and random component
  late String _orderNumber;

  @override
  void initState() {
    super.initState();
    _orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch % 10000}-${Random().nextInt(1000)}';
  }

void _addItem(String item) {
  setState(() {
    if (_orderItems[_selectedCategory] == null) {
      _orderItems[_selectedCategory] = {};
    }
    if (_orderItems[_selectedCategory]![item] == null) {
      _orderItems[_selectedCategory]![item] = 1; // Start with 1 item by default
    } else {
      _orderItems[_selectedCategory]![item] = _orderItems[_selectedCategory]![item]! + 1;
    }
  });
}

void _removeItem(String item) {
  setState(() {
    if (_orderItems[_selectedCategory] != null &&
        _orderItems[_selectedCategory]![item] != null &&
        _orderItems[_selectedCategory]![item]! > 0) {
      _orderItems[_selectedCategory]![item] = _orderItems[_selectedCategory]![item]! - 1;
      
      if (_orderItems[_selectedCategory]![item] == 0) {
        // Remove the item completely when its quantity is 0
        _orderItems[_selectedCategory]!.remove(item);
      }
    }
  });
}


  void _saveOrder() {
    // Logic for saving the order including additional details (order type, table, etc.)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order Saved Successfully')),
    );
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
        backgroundColor: Colors.purple,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Order Number: $_orderNumber', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    items: _categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: _menuItems[_selectedCategory]!
                          .where((item) => item['name']!.toLowerCase().contains(_searchController.text.toLowerCase()))
                          .map((item) => ListTile(
                                title: Row(
                                  children: [
                                    Text(item['name']!),
                                    const SizedBox(width: 10),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: item['tag'] == 'Veg' ? Colors.green : Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text('₹${item['rate']}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () => _removeItem(item['name']!),
                                    ),
                                    Text('${_orderItems[_selectedCategory]?[item['name']!] ?? 0}'),
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
                    onChanged: (value) => setState(() => _tableNumber = int.tryParse(value) ?? 1),
                    decoration: const InputDecoration(
                      labelText: 'Table Number',
                      prefixIcon: Icon(Icons.table_bar),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: _personCount.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() => _personCount = int.tryParse(value) ?? 1),
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
        Text('Ordered Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      .firstWhere((item) => item['name'] == itemName, orElse: () => {'rate': '0'})['rate']!,
                  ) ?? 0.0;

                  final itemAmount = itemRate * quantity;
                  final itemTax = itemAmount * taxRate;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Card(
                      elevation: 3.0,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(itemName, style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('₹$itemRate', style: TextStyle(fontSize: 16, color: Colors.black)),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Qty: $quantity', style: TextStyle(fontWeight: FontWeight.w500)),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: quantity > 0 ? () => _removeItem(itemName) : null,
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () => _addItem(itemName),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () => _deleteItem(itemName),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text('Amount: ₹${itemAmount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Tax: ₹${itemTax.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList();
              }).toList(),

              // Summary section for Total Amount and Total Tax
            Padding(
  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Divider(thickness: 1.5),
      Text('Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Text('Total Amount: ₹${_calculateTotalAmount().toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      Text('Total Tax: ₹${_calculateTotalTax().toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Text(
        'Grand Total: ₹${(_calculateTotalAmount() + _calculateTotalTax()).toStringAsFixed(2)}',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
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
    return total + entry.value.entries.fold(0.0, (subtotal, itemEntry) {
      final itemName = itemEntry.key;
      final quantity = itemEntry.value;
      final itemRate = double.tryParse(
        _menuItems.values
          .expand((categoryItems) => categoryItems)
          .firstWhere((item) => item['name'] == itemName, orElse: () => {'rate': '0'})['rate']!,
      ) ?? 0.0;
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
      _orderItems[_selectedCategory]!.remove(item); // Completely remove the item from the order
    }
  });
}

}
