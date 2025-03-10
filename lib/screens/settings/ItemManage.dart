import 'dart:io';
import 'dart:math';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../backend/order/items_api_service.dart';

class ItemMasterScreen extends StatefulWidget {
  const ItemMasterScreen({super.key});

  @override
  _ItemMasterScreenState createState() => _ItemMasterScreenState();
}

class _ItemMasterScreenState extends State<ItemMasterScreen> {
  final ItemsApiService _apiService = ItemsApiService(
      baseUrl: 'http://localhost:3000/api'); // Replace with actual base URL
  final List<String> _categories = ['Starters', 'Main Course', 'Desserts'];
  final List<String> tags = ['Veg', 'Non Veg'];
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
  final _itemCodeController =
      TextEditingController(); // For item code, default non-editable
  String? _selectedCategory = 'Starters';
  String? _selectedTag = 'Veg';
  String? _selectedBrand = 'Brand A';
  String? _selectedSubcategory = 'Vegetarian';
  String? _selectedOutlet = '';
  bool _isActive = true;
  final bool _isOnSale = false;
  final bool _isHappyHour = false;
  final bool _isDiscountable = true;
  List<Map<String, dynamic>> _items = [];
  bool _happyHour = false;
  bool _discountable = true;
  int _qtyDebitFromSale = 1;
  bool _isLoading = true; //
  List<String> outlets = []; // List of outlets to select from
  List<dynamic> properties = [];
  List<dynamic> outletConfigurations = [];
  @override
  void initState() {
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
        outlets = outletslist; // Set the outlets list
        _selectedOutlet = outletslist.first;
      });
    }
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      List<dynamic> fetchedItems = await _apiService.fetchAllItems();
      setState(() {
        _items = fetchedItems
            .cast<Map<String, dynamic>>(); // Cast the dynamic list to a map
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching items: $e')));
    }
  }

  // Function to delete an item from the API and local list
  Future<void> _deleteItem(String itemId, int index) async {
    try {
      await _apiService.deleteItem(itemId); // Delete from API
      setState(() {
        _items.removeAt(index); // Remove from local list
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting item: $e')));
    }
  }

  // Function to update an item via the API
  Future<void> _updateItem(
      String id, Map<String, dynamic> updatedItemData) async {
    try {
      await _apiService.updateItem(id, updatedItemData); // Update via API
      setState(() {
        int index = _items.indexWhere((item) => item['item_code'] == id);
        if (index != -1) {
          _items[index] = updatedItemData; // Update local list
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error updating item: $e')));
    }
  }

  // Function to add a new item and send it to the API
  Future<void> _addItem() async {
    if (_itemNameController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _selectedOutlet != "") {
      final itemData = {
        'item_code': _generateItemCode(),
        'item_name': _itemNameController.text,
        'category': _selectedCategory,
        'brand': _selectedBrand,
        'subcategory_id':
            _selectedSubcategory, // Assuming this is an ID or name for subcategory
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
        'property_id': properties[0][
            'property_id'], // Assuming this is the property ID (you may get it dynamically or set a default)
        'tag': _selectedTag,
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

  Future<void> _importFromExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows.skip(1)) {
          if (row.length >= 10) {
            final itemData = {
              'item_code': row[0]?.value.toString() ?? '',
              'item_name': row[1]?.value.toString() ?? '',
              'category': row[2]?.value.toString() ?? '',
              'brand': row[3]?.value.toString() ?? '',
              'subcategory_id': row[4]?.value.toString() ?? '',
              'outlet': row[5]?.value.toString() ?? '',
              'description': row[6]?.value.toString() ?? '',
              'price': double.tryParse(row[7]?.value.toString() ?? '0') ?? 0.0,
              'tax_rate':
                  double.tryParse(row[8]?.value.toString() ?? '0') ?? 0.0,
              'discount_percentage':
                  double.tryParse(row[9]?.value.toString() ?? '0') ?? 0.0,
              'stock_quantity':
                  int.tryParse(row[10]?.value.toString() ?? '0') ?? 0,
              'reorder_level':
                  int.tryParse(row[11]?.value.toString() ?? '0') ?? 0,
              'is_active': row[12]?.value.toString().toLowerCase() == 'true',
              'on_sale': row[13]?.value.toString().toLowerCase() == 'true',
              'happy_hour': row[14]?.value.toString().toLowerCase() == 'true',
              'discountable': row[15]?.value.toString().toLowerCase() == 'true',
              'property_id': row[16]?.value.toString() ?? '',
              'tag': row[17]?.value.toString() ?? '',
            };

            try {
              await _apiService.createItem(itemData);
            } catch (e) {
              print('Error adding item: $e');
            }
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Excel import completed successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  Future<void> _exportToExcel() async {
    try {
      // Fetch items from API
      List items = await _apiService.fetchAllItemsnew();

      if (items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No items to export')),
        );
        return;
      }

      // Create Excel instance
      var excel = Excel.createExcel();

      // Get the default first sheet
      String sheetName = "Items";
      excel.rename(excel.getDefaultSheet()!, sheetName);
      Sheet sheetObject = excel[sheetName];

      // Add header row
      sheetObject.appendRow([
        TextCellValue('Item Code'),
        TextCellValue('Item Name'),
        TextCellValue('Category'),
        TextCellValue('Brand'),
        TextCellValue('Subcategory ID'),
        TextCellValue('Outlet'),
        TextCellValue('Description'),
        TextCellValue('Price'),
        TextCellValue('Tax Rate'),
        TextCellValue('Discount %'),
        TextCellValue('Stock'),
        TextCellValue('Reorder Level'),
        TextCellValue('Active'),
        TextCellValue('On Sale'),
        TextCellValue('Happy Hour'),
        TextCellValue('Discountable'),
        TextCellValue('Property ID'),
        TextCellValue('Tag'),
      ]);

      // Add data rows
      for (var item in items) {
        sheetObject.appendRow([
          TextCellValue(item['item_code'] ?? ''),
          TextCellValue(item['item_name'] ?? ''),
          TextCellValue(item['category'] ?? ''),
          TextCellValue(item['brand'] ?? ''),
          TextCellValue(item['subcategory_id'] ?? ''),
          TextCellValue(item['outlet'] ?? ''),
          TextCellValue(item['description'] ?? ''),
          DoubleCellValue(
              double.tryParse(item['price']?.toString() ?? '0.0') ?? 0.0),
          DoubleCellValue(
              double.tryParse(item['tax_rate']?.toString() ?? '0.0') ?? 0.0),
          DoubleCellValue(double.tryParse(
                  item['discount_percentage']?.toString() ?? '0.0') ??
              0.0),
          IntCellValue(
              int.tryParse(item['stock_quantity']?.toString() ?? '0') ?? 0),
          IntCellValue(
              int.tryParse(item['reorder_level']?.toString() ?? '0') ?? 0),
          BoolCellValue(item['is_active'] == true),
          BoolCellValue(item['on_sale'] == true),
          BoolCellValue(item['happy_hour'] == true),
          BoolCellValue(item['discountable'] == true),
          TextCellValue(item['property_id'] ?? ''),
          TextCellValue(item['tag'] ?? ''),
        ]);
      }

      // Ensure data is written
      List<int>? excelData = excel.encode();
      if (excelData == null) {
        throw Exception("Failed to encode Excel file.");
      }

      // Get file path
      Directory directory = await getApplicationDocumentsDirectory();
      String timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
      String filePath = '${directory.path}/items_export_$timestamp.xlsx';

      // Save the Excel file
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excelData);

      // Open file after saving
      OpenFile.open(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export successful')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting: $e')),
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
  List<Map<String, dynamic>> _filteredItems =
      []; // A new list for filtered items

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
        backgroundColor: Colors.teal,
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
                        decoration: const InputDecoration(
                          labelText: 'Item Code',
                          prefixIcon: Icon(Icons.numbers),
                          enabled: false, // Disable editing of item code
                        )),
                    const SizedBox(height: 10),
                    // Item Name
                    TextFormField(
                      controller: _itemNameController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name',
                        prefixIcon:
                            Icon(Icons.food_bank), // Example icon for item name
                      ),
                    ),

                    const SizedBox(height: 10),

                    // tag Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedTag,
                      onChanged: (value) {
                        setState(() {
                          _selectedTag = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Tag'),
                      items: tags
                          .map((tag) =>
                              DropdownMenuItem(value: tag, child: Text(tag)))
                          .toList(),
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
                          .map((category) => DropdownMenuItem(
                              value: category, child: Text(category)))
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
                      decoration:
                          const InputDecoration(labelText: 'Subcategory'),
                      items: _subcategories
                          .map((subcategory) => DropdownMenuItem(
                              value: subcategory, child: Text(subcategory)))
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
                          .map((brand) => DropdownMenuItem(
                              value: brand, child: Text(brand)))
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
                          .map((outlet) => DropdownMenuItem(
                              value: outlet, child: Text(outlet)))
                          .toList(),
                    ),
                    const SizedBox(height: 10),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(
                            Icons.description), // Example icon for description
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Price
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixIcon:
                            Icon(Icons.attach_money), // Example icon for price
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Restricts input to digits only
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Tax Rate
                    TextFormField(
                      controller: _taxRateController,
                      decoration: const InputDecoration(
                        labelText: 'Tax Rate',
                        prefixIcon:
                            Icon(Icons.percent), // Example icon for tax rate
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Restricts input to digits only
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Discount Percentage
                    TextFormField(
                      controller: _discountController,
                      decoration: const InputDecoration(
                        labelText: 'Discount Percentage',
                        prefixIcon:
                            Icon(Icons.discount), // Example icon for discount
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Restricts input to digits only
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Stock Quantity
                    TextFormField(
                      controller: _stockQuantityController,
                      decoration: const InputDecoration(
                        labelText: 'Stock Quantity',
                        prefixIcon: Icon(Icons
                            .shopping_cart), // Example icon for stock quantity
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Restricts input to digits only
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Reorder Level
                    TextFormField(
                      controller: _reorderLevelController,
                      decoration: const InputDecoration(
                        labelText: 'Reorder Level',
                        prefixIcon: Icon(
                            Icons.refresh), // Example icon for reorder level
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Restricts input to digits only
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
                      controller: TextEditingController(
                          text: _qtyDebitFromSale.toString()),
                      decoration: const InputDecoration(
                          labelText: 'How Much Qty Debit From 1 Sale'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Restricts input to digits only
                      ],
                      onChanged: (value) {
                        setState(() {
                          _qtyDebitFromSale = int.tryParse(value) ??
                              1; // Default 1 if invalid input
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
                    decoration:
                        const InputDecoration(labelText: 'Filter by Outlet'),
                    items: outlets
                        .map((outlet) => DropdownMenuItem(
                            value: outlet, child: Text(outlet)))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  // Item List
                  _filteredItems.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: _filteredItems
                                .length, // This can be the source of error
                            itemBuilder: (context, index) {
                              var item = _filteredItems[
                                  index]; // Ensure this list's length is properly handled
                              return ListTile(
                                title: Text(item['item_name']),
                                subtitle: Text(
                                    'Category: ${item['category']} | Price: ₹${item['price']}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteItem(
                                      item['item_id'].toString(), index),
                                ),
                              );
                            },
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _items
                                .length, // This can be the source of error
                            itemBuilder: (context, index) {
                              var item = _items[
                                  index]; // Ensure this list's length is properly handled
                              return ListTile(
                                title: Text(item['item_name']),
                                subtitle: Text(
                                    'Category: ${item['category']} | Price: ₹${item['price']}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteItem(
                                      item['item_id'].toString(), index),
                                ),
                              );
                            },
                          ),
                        ),

                  SafeArea(
                      child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: _importFromExcel,
                        child: const Text("Import from Excel"),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                        onPressed: _exportToExcel,
                        child: const Text("Export"),
                      ),
                    ],
                  ))
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
