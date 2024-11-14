import 'package:flutter/material.dart';
import 'dart:math';

class ItemMasterScreen extends StatefulWidget {
  const ItemMasterScreen({Key? key}) : super(key: key);

  @override
  _ItemMasterScreenState createState() => _ItemMasterScreenState();
}

class _ItemMasterScreenState extends State<ItemMasterScreen> {
  final List<String> _categories = ['Starters', 'Main Course', 'Desserts'];
  final List<String> _brands = ['Brand A', 'Brand B', 'Brand C'];
  final List<String> _subcategories = ['Vegetarian', 'Non-Vegetarian', 'Vegan'];
  final List<String> _outlets = ['Outlet A', 'Outlet B', 'Outlet C'];
 final _itemNameController = TextEditingController();
  final _searchController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _taxRateController = TextEditingController();
  final _discountController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _reorderLevelController = TextEditingController();
  final _itemCodeController = TextEditingController(); // For item code, default non-editable
  String? _selectedCategory = 'Starters';
  String? _selectedBrand = 'Brand A';
  String? _selectedSubcategory = 'Vegetarian';
  String? _selectedOutlet = 'Outlet A';
  bool _isActive = true;
  bool _isOnSale = false;
  bool _isHappyHour = false;
  bool _isDiscountable = true;
  List<Map<String, dynamic>> _items = [];
    bool _happyHour = false;
  bool _discountable = true;
  int _qtyDebitFromSale = 1;


  // Function to generate a random item code
  String _generateItemCode() {
    Random random = Random();
    return 'ITEM${random.nextInt(10000)}';
  }

  // Function to generate random 50 items
  void _generateRandomItems() {
    final random = Random();
    final outlets = ['Outlet A', 'Outlet B', 'Outlet C'];
    final categories = ['Starters', 'Main Course', 'Desserts'];
    final subcategories = ['Vegetarian', 'Non-Vegetarian', 'Vegan'];
    final brands = ['Brand A', 'Brand B', 'Brand C'];

    for (var i = 0; i < 50; i++) {
      _items.add({
        'item_code': _generateItemCode(),
        'item_name': 'Item $i',
        'category': categories[random.nextInt(categories.length)],
        'brand': brands[random.nextInt(brands.length)],
        'subcategory': subcategories[random.nextInt(subcategories.length)],
        'outlet': outlets[random.nextInt(outlets.length)],
        'description': 'Description for Item $i',
        'price': (random.nextDouble() * 500).toStringAsFixed(2),
        'tax_rate': (random.nextDouble() * 20).toStringAsFixed(2),
        'discount_percentage': (random.nextDouble() * 50).toStringAsFixed(2),
        'stock_quantity': random.nextInt(100),
        'reorder_level': random.nextInt(50),
        'is_active': random.nextBool(),
        'on_sale': random.nextBool(),
        'happy_hour': random.nextBool(),
        'discountable': random.nextBool(),
      });
    }
  }

  // Function to add or modify an item
  void _addItem() {
    if (_itemNameController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      setState(() {
        _items.add({
          'item_code': _generateItemCode(),
          'item_name': _itemNameController.text,
          'category': _selectedCategory,
          'brand': _selectedBrand,
          'subcategory': _selectedSubcategory,
          'outlet': _selectedOutlet,
          'description': _descriptionController.text,
          'price': double.parse(_priceController.text),
          'tax_rate': double.tryParse(_taxRateController.text) ?? 0.0,
          'discount_percentage': double.tryParse(_discountController.text) ?? 0.0,
          'stock_quantity': int.tryParse(_stockQuantityController.text) ?? 0,
          'reorder_level': int.tryParse(_reorderLevelController.text) ?? 0,
          'is_active': _isActive,
          'on_sale': _isOnSale,
          'happy_hour': _isHappyHour,
          'discountable': _isDiscountable,
        });
      });
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added successfully')),
      );
    }
  }

  // Function to delete an item
  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item deleted successfully')),
    );
  }

  // Function to clear the form
  void _clearForm() {
    _itemNameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _taxRateController.clear();
    _discountController.clear();
    _stockQuantityController.clear();
    _reorderLevelController.clear();
  }

  // Function to handle item search
  List<Map<String, dynamic>> _searchItems() {
    String query = _searchController.text.toLowerCase();
    return _items.where((item) {
      return item['item_name'].toLowerCase().contains(query) ||
             item['category'].toLowerCase().contains(query);
    }).toList();
  }

  // Function to filter items by outlet
  List<Map<String, dynamic>> _filterItemsByOutlet() {
    return _items.where((item) {
      return item['outlet'] == _selectedOutlet;
    }).toList();
  }

  @override
  void initState() {
        _itemCodeController.text = 'ITEM${DateTime.now().millisecondsSinceEpoch}';

    super.initState();
    _generateRandomItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Master'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Left Panel - Item Form
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      // Item Name
         TextFormField(
  controller: _itemNameController,
  decoration: const InputDecoration(
    labelText: 'Item Name',
    prefixIcon: Icon(Icons.food_bank), // Example icon for item name
  ),
),

              const SizedBox(height: 10),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories
                    .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                    .toList(),
              ),
              const SizedBox(height: 10),

              // Subcategory Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSubcategory,
                onChanged: (value) {
                  setState(() {
                    _selectedSubcategory = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Subcategory'),
                items: _subcategories
                    .map((subcategory) => DropdownMenuItem(value: subcategory, child: Text(subcategory)))
                    .toList(),
              ),
              const SizedBox(height: 10),

              // Brand Dropdown
              DropdownButtonFormField<String>(
                value: _selectedBrand,
                onChanged: (value) {
                  setState(() {
                    _selectedBrand = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Brand'),
                items: _brands
                    .map((brand) => DropdownMenuItem(value: brand, child: Text(brand)))
                    .toList(),
              ),
              const SizedBox(height: 10),

              // Outlet Dropdown
              DropdownButtonFormField<String>(
                value: _selectedOutlet,
                onChanged: (value) {
                  setState(() {
                    _selectedOutlet = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Outlet'),
                items: _outlets
                    .map((outlet) => DropdownMenuItem(value: outlet, child: Text(outlet)))
                    .toList(),
              ),
              const SizedBox(height: 10),

              // Item Code (Auto Generated)
              TextFormField(
                controller: _itemCodeController,
                decoration: const InputDecoration(labelText: 'Item Code'),
                enabled: false, // Disable editing of item code
              ),
              const SizedBox(height: 10),

              // Description
             TextFormField(
  controller: _descriptionController,
  decoration: const InputDecoration(
    labelText: 'Description',
    prefixIcon: Icon(Icons.description), // Example icon for description
  ),
),

              const SizedBox(height: 10),

              // Price
          TextFormField(
  controller: _priceController,
  decoration: const InputDecoration(
    labelText: 'Price',
    prefixIcon: Icon(Icons.attach_money), // Example icon for price
  ),
  keyboardType: TextInputType.number,
),
              const SizedBox(height: 10),

              // Tax Rate
            TextFormField(
  controller: _taxRateController,
  decoration: const InputDecoration(
    labelText: 'Tax Rate',
    prefixIcon: Icon(Icons.percent), // Example icon for tax rate
  ),
  keyboardType: TextInputType.number,
),
              const SizedBox(height: 10),

              // Discount Percentage
            TextFormField(
  controller: _discountController,
  decoration: const InputDecoration(
    labelText: 'Discount Percentage',
    prefixIcon: Icon(Icons.discount), // Example icon for discount
  ),
  keyboardType: TextInputType.number,
),
              const SizedBox(height: 10),

              // Stock Quantity
            TextFormField(
  controller: _stockQuantityController,
  decoration: const InputDecoration(
    labelText: 'Stock Quantity',
    prefixIcon: Icon(Icons.shopping_cart), // Example icon for stock quantity
  ),
  keyboardType: TextInputType.number,
),
              const SizedBox(height: 10),

              // Reorder Level
         TextFormField(
  controller: _reorderLevelController,
  decoration: const InputDecoration(
    labelText: 'Reorder Level',
    prefixIcon: Icon(Icons.refresh), // Example icon for reorder level
  ),
  keyboardType: TextInputType.number,
),
              const SizedBox(height: 10),

              // Is Active Checkbox
              CheckboxListTile(
                title: const Text('Is Active'),
                value: _isActive,
                onChanged: (bool? value) {
                  setState(() {
                    _isActive = value!;
                  });
                },
              ),
              const SizedBox(height: 10),

              // Happy Hour Checkbox
              CheckboxListTile(
                title: const Text('Happy Hour'),
                value: _happyHour,
                onChanged: (bool? value) {
                  setState(() {
                    _happyHour = value!;
                  });
                },
              ),
              const SizedBox(height: 10),

              // Discountable Checkbox
              CheckboxListTile(
                title: const Text('Discountable'),
                value: _discountable,
                onChanged: (bool? value) {
                  setState(() {
                    _discountable = value!;
                  });
                },
              ),
              const SizedBox(height: 10),

              // Quantity Debit From Sale
              TextFormField(
                controller: TextEditingController(text: _qtyDebitFromSale.toString()),
                decoration: const InputDecoration(labelText: 'How Much Qty Debit From 1 Sale'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _qtyDebitFromSale = int.tryParse(value) ?? 1; // Default 1 if invalid input
                  });
                },
              ),
              const SizedBox(height: 20),
                    // Add Item Button
                    ElevatedButton(
                      onPressed: _addItem,
                      child: const Text('Add Item'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Right Panel - Item List & Search
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextFormField(
                    controller: _searchController,
                    decoration: const InputDecoration(labelText: 'Search'),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 10),
                  // Outlet Filter
                  DropdownButtonFormField<String>(
                    value: _selectedOutlet,
                    onChanged: (value) {
                      setState(() {
                        _selectedOutlet = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Filter by Outlet'),
                    items: _outlets
                        .map((outlet) => DropdownMenuItem(value: outlet, child: Text(outlet)))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  // Item List
                Expanded(
  child: ListView.builder(
    itemCount: 10, // This can be the source of error
    itemBuilder: (context, index) {
      var item = _filterItemsByOutlet()[index];  // Ensure this list's length is properly handled
      return ListTile(
        title: Text(item['item_name']),
        subtitle: Text('Category: ${item['category']} | Price: ₹${item['price']}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _deleteItem(index),
        ),
      );
    },
  ),
)

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: ItemMasterScreen()));
}
