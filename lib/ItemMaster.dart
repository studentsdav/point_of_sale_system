import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:point_of_sale_system/backend/items_api_service.dart';

class ItemMasterScreen extends StatefulWidget {
  const ItemMasterScreen({Key? key}) : super(key: key);

  @override
  _ItemMasterScreenState createState() => _ItemMasterScreenState();
}

class _ItemMasterScreenState extends State<ItemMasterScreen> {
   final ItemsApiService _apiService = ItemsApiService(baseUrl: 'http://localhost:3000/api'); // Replace with actual base URL
  final List<String> _categories = ['Starters', 'Main Course', 'Desserts'];
  final List<String> _brands = ['Brand A', 'Brand B', 'Brand C'];
  final List<String> _subcategories = ['Vegetarian', 'Non-Vegetarian', 'Vegan'];
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
  String? _selectedOutlet = '';
  bool _isActive = true;
  bool _isOnSale = false;
  bool _isHappyHour = false;
  bool _isDiscountable = true;
  List<Map<String, dynamic>> _items = [];
    bool _happyHour = false;
  bool _discountable = true;
  int _qtyDebitFromSale = 1;
 bool _isLoading = true;
 List<String> outlets = []; // List of outlets to select from
  List<dynamic> properties = [];
  List<dynamic> outletConfigurations = [];
@override
void initState(){

    _loadDataFromHive();

  super.initState();

 _itemCodeController.text = _generateItemCode();

}

 // Load data from Hive
Future<void> _loadDataFromHive() async {
  var box = await Hive.openBox('appData');
  
  // Retrieve the data
  var properties = box.get('properties');
  var outletConfigurations = box.get('outletConfigurations');
  
  // Check if outletConfigurations is not null
  if (outletConfigurations != null) {
    // Extract the outlet names into the outlets list
    List<String> outletslist = [];
    for (var outlet in outletConfigurations) {
      if (outlet['outlet_name'] != null) {
        outletslist.add(outlet['outlet_name'].toString());
      }
    }

    setState(() {
      this.properties = properties ?? [];
      this.outletConfigurations = outletConfigurations ?? [];
      this.outlets = outletslist; // Set the outlets list
      _selectedOutlet = outletslist.first;
    });
  }
 _loadItems();
}



  Future<void> _loadItems() async {
    try {
      List<dynamic> fetchedItems = await _apiService.fetchAllItems();
      setState(() {
        _items = fetchedItems.cast<Map<String, dynamic>>();  // Cast the dynamic list to a map
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching items: $e')));
    }
  }

  // Function to delete an item from the API and local list
  Future<void> _deleteItem(String itemId, int index) async {
    try {
      await _apiService.deleteItem(itemId);  // Delete from API
      setState(() {
        _items.removeAt(index);  // Remove from local list
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting item: $e')));
    }
  }

  // Function to update an item via the API
  Future<void> _updateItem(String id, Map<String, dynamic> updatedItemData) async {
    try {
      await _apiService.updateItem(id, updatedItemData);  // Update via API
      setState(() {
        int index = _items.indexWhere((item) => item['item_code'] == id);
        if (index != -1) {
          _items[index] = updatedItemData;  // Update local list
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating item: $e')));
    }
  }

  // Function to add a new item and send it to the API
  Future<void> _addItem() async {
    if (_itemNameController.text.isNotEmpty && _priceController.text.isNotEmpty && _selectedOutlet!="") {
      final itemData = {
        'item_code': _generateItemCode(),
        'item_name': _itemNameController.text,
        'category': _selectedCategory,
        'brand': _selectedBrand,
        'subcategory_id': _selectedSubcategory,  // Assuming this is an ID or name for subcategory
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
        'property_id': properties[0]['property_id']  // Assuming this is the property ID (you may get it dynamically or set a default)
      };

      try {
        // Call the API to add the item
        await _apiService.createItem(itemData);
        // If successful, clear the form and show a success message
        _clearForm();
        _loadItems();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding item: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }

  // Function to generate a random item code (customized as per your needs)
  String _generateItemCode() {
    Random random = Random();
    return 'ITEM${random.nextInt(100)}';
  }

  // Function to clear the form fields after item is added
  void _clearForm() {
    _itemNameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _taxRateController.clear();
    _discountController.clear();
    _stockQuantityController.clear();
    _reorderLevelController.clear();
  }

  // Search Items function
List<Map<String, dynamic>> _filteredItems = []; // A new list for filtered items

// Function to search items based on the query
void _searchItems(String query) {
  setState(() {
    _filteredItems = _items.where((item) {
      return item['item_name'].toLowerCase().contains(query.toLowerCase()) ||
             item['category'].toLowerCase().contains(query.toLowerCase());
    }).toList();
  });
}
//   // Function to generate a random item code
//   String _generateItemCode() {
//     Random random = Random();
//     return 'ITEM${random.nextInt(10000)}';
//   }

//   // Function to generate random 50 items
//  Future <void> _generateRandomItems() async {
//     final random = Random();
//     final categories = ['Starters', 'Main Course', 'Desserts'];
//     final subcategories = ['Vegetarian', 'Non-Vegetarian', 'Vegan'];
//     final brands = ['Brand A', 'Brand B', 'Brand C'];

//     for (var i = 0; i < 50; i++) {
//       _items.add({
//         'item_code': _generateItemCode(),
//         'item_name': 'Item $i',
//         'category': categories[random.nextInt(categories.length)],
//         'brand': brands[random.nextInt(brands.length)],
//         'subcategory': subcategories[random.nextInt(subcategories.length)],
//         'outlet': outlets.first,
//         'description': 'Description for Item $i',
//         'price': (random.nextDouble() * 500).toStringAsFixed(2),
//         'tax_rate': (random.nextDouble() * 20).toStringAsFixed(2),
//         'discount_percentage': (random.nextDouble() * 50).toStringAsFixed(2),
//         'stock_quantity': random.nextInt(100),
//         'reorder_level': random.nextInt(50),
//         'is_active': random.nextBool(),
//         'on_sale': random.nextBool(),
//         'happy_hour': random.nextBool(),
//         'discountable': random.nextBool(),
//       });
//     }
//   }

//   // Function to add or modify an item
//   void _addItem() {
//     if (_itemNameController.text.isNotEmpty && _priceController.text.isNotEmpty) {
//       setState(() {
//         _items.add({
//           'item_code': _generateItemCode(),
//           'item_name': _itemNameController.text,
//           'category': _selectedCategory,
//           'brand': _selectedBrand,
//           'subcategory': _selectedSubcategory,
//           'outlet': _selectedOutlet,
//           'description': _descriptionController.text,
//           'price': double.parse(_priceController.text),
//           'tax_rate': double.tryParse(_taxRateController.text) ?? 0.0,
//           'discount_percentage': double.tryParse(_discountController.text) ?? 0.0,
//           'stock_quantity': int.tryParse(_stockQuantityController.text) ?? 0,
//           'reorder_level': int.tryParse(_reorderLevelController.text) ?? 0,
//           'is_active': _isActive,
//           'on_sale': _isOnSale,
//           'happy_hour': _isHappyHour,
//           'discountable': _isDiscountable,
//         });
//       });
//       _clearForm();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Item added successfully')),
//       );
//     }
//   }

//   // Function to delete an item
//   void _deleteItem(int index) {
//     setState(() {
//       _items.removeAt(index);
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Item deleted successfully')),
//     );
//   }

//   // Function to clear the form
//   void _clearForm() {
//     _itemNameController.clear();
//     _descriptionController.clear();
//     _priceController.clear();
//     _taxRateController.clear();
//     _discountController.clear();
//     _stockQuantityController.clear();
//     _reorderLevelController.clear();
//   }

//   // Function to handle item search
//   List<Map<String, dynamic>> _searchItems() {
//     String query = _searchController.text.toLowerCase();
//     return _items.where((item) {
//       return item['item_name'].toLowerCase().contains(query) ||
//              item['category'].toLowerCase().contains(query);
//     }).toList();
//   }

  // Function to filter items by outlet
  List<Map<String, dynamic>> _filterItemsByOutlet() {
    return _items.where((item) {
      return item['outlet'] == outlets.first;
    }).toList();
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
                          // Item Code (Auto Generated)
              TextFormField(
                controller: _itemCodeController,
                decoration: const InputDecoration(labelText: 'Item Code',  prefixIcon: Icon(Icons.numbers),
                enabled: false, // Disable editing of item code
                
              )),
              const SizedBox(height: 10),
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
                items: outlets
                    .map((outlet) => DropdownMenuItem(value: outlet, child: Text(outlet)))
                    .toList(),
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
  keyboardType: TextInputType.number,                  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,  // Restricts input to digits only
  ],
),
              const SizedBox(height: 10),

              // Tax Rate
            TextFormField(
  controller: _taxRateController,
  decoration: const InputDecoration(
    labelText: 'Tax Rate',
    prefixIcon: Icon(Icons.percent), // Example icon for tax rate
  ),
  keyboardType: TextInputType.number,                  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,  // Restricts input to digits only
  ],
),
              const SizedBox(height: 10),

              // Discount Percentage
            TextFormField(
  controller: _discountController,
  decoration: const InputDecoration(
    labelText: 'Discount Percentage',
    prefixIcon: Icon(Icons.discount), // Example icon for discount
  ),
  keyboardType: TextInputType.number,                  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,  // Restricts input to digits only
  ],
),
              const SizedBox(height: 10),

              // Stock Quantity
            TextFormField(
  controller: _stockQuantityController,
  decoration: const InputDecoration(
    labelText: 'Stock Quantity',
    prefixIcon: Icon(Icons.shopping_cart), // Example icon for stock quantity
  ),
  keyboardType: TextInputType.number,                  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,  // Restricts input to digits only
  ],
),
              const SizedBox(height: 10),

              // Reorder Level
         TextFormField(
  controller: _reorderLevelController,
  decoration: const InputDecoration(
    labelText: 'Reorder Level',
    prefixIcon: Icon(Icons.refresh), // Example icon for reorder level
  ),
  keyboardType: TextInputType.number,                  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,  // Restricts input to digits only
  ],
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
                  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,  // Restricts input to digits only
  ],
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
                      setState(() {
                        _searchItems(value);
                      });
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
                    items: outlets
                        .map((outlet) => DropdownMenuItem(value: outlet, child: Text(outlet)))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  // Item List
              _filteredItems.length>0?  Expanded(
  child: ListView.builder(
    itemCount: _filteredItems.length, // This can be the source of error
    itemBuilder: (context, index) {
      var item = _filteredItems[index];  // Ensure this list's length is properly handled
      return ListTile(
        title: Text(item['item_name']),
        subtitle: Text('Category: ${item['category']} | Price: ₹${item['price']}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _deleteItem(item['item_id'].toString(), index),
        ),
      );
    },
  ),
): Expanded(
  child: ListView.builder(
    itemCount: _items.length, // This can be the source of error
    itemBuilder: (context, index) {
      var item = _items[index];  // Ensure this list's length is properly handled
      return ListTile(
        title: Text(item['item_name']),
        subtitle: Text('Category: ${item['category']} | Price: ₹${item['price']}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _deleteItem(item['item_id'].toString(), index),
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
