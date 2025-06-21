import 'package:flutter/material.dart';
import '../../backend/api_config.dart';
import '../../backend/inventory/ingredient_api_service.dart';

class IngredientManagementScreen extends StatefulWidget {
  const IngredientManagementScreen({super.key});

  @override
  _IngredientManagementScreenState createState() =>
      _IngredientManagementScreenState();
}

class _IngredientManagementScreenState
    extends State<IngredientManagementScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController minStockController = TextEditingController();
  final TextEditingController reorderController = TextEditingController();
  final IngredientApiService ingredientService = IngredientApiService();

  String? selectedCategory;
  String? selectedSubcategory;
  String? selectedBrand;
  String? selectedUnit;

  List<String> categories = ['Dairy', 'Grains', 'Vegetables'];
  List<String> subcategories = [
    'Milk Products',
    'Whole Grains',
    'Leafy Greens'
  ];
  List<String> brands = ['Brand A', 'Brand B', 'Brand C'];
  List<String> units = ['Kg', 'Liters', 'Packets'];

  List<Map<String, String>> ingredients = [];

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  Future<void> _loadIngredients() async {
    try {
      final data = await ingredientService.getAllIngredients();
      setState(() {
        ingredients = data
            .map<Map<String, String>>((item) => {
                  'id': item['id'].toString(),
                  'name': item['name'] ?? '',
                  'category': item['category'] ?? '',
                  'subcategory': item['subcategory'] ?? '',
                  'brand': item['brand'] ?? '',
                  'stock': item['stock'].toString(),
                  'unit': item['unit'] ?? '',
                  'minStock': item['minStock'].toString(),
                  'reorderLevel': item['reorderLevel'].toString(),
                })
            .toList();
      });
    } catch (e) {
      // handle error
    }
  }

  Future<void> addIngredient() async {
    if (nameController.text.isNotEmpty &&
        selectedCategory != null &&
        selectedSubcategory != null &&
        selectedBrand != null &&
        selectedUnit != null) {
      await ingredientService.addIngredient({
        'name': nameController.text,
        'category': selectedCategory,
        'subcategory': selectedSubcategory,
        'brand': selectedBrand,
        'stock': stockController.text,
        'unit': selectedUnit,
        'minStock': minStockController.text,
        'reorderLevel': reorderController.text,
      });
      await _loadIngredients();
      nameController.clear();
      stockController.clear();
      minStockController.clear();
      reorderController.clear();
    }
  }

  Future<void> deleteIngredient(int index) async {
    final id = ingredients[index]['id'];
    if (id != null) {
      await ingredientService.deleteIngredient(id);
    }
    await _loadIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingredient Management')),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Ingredient Name')),
                  DropdownButtonFormField(
                    decoration: const InputDecoration(labelText: 'Category'),
                    value: selectedCategory,
                    items: categories
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedCategory = value),
                  ),
                  DropdownButtonFormField(
                    decoration: const InputDecoration(labelText: 'Subcategory'),
                    value: selectedSubcategory,
                    items: subcategories
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedSubcategory = value),
                  ),
                  DropdownButtonFormField(
                    decoration: const InputDecoration(labelText: 'Brand'),
                    value: selectedBrand,
                    items: brands
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedBrand = value),
                  ),
                  TextField(
                      controller: stockController,
                      decoration:
                          const InputDecoration(labelText: 'Stock Quantity')),
                  DropdownButtonFormField(
                    decoration: const InputDecoration(labelText: 'Unit'),
                    value: selectedUnit,
                    items: units
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedUnit = value),
                  ),
                  TextField(
                      controller: minStockController,
                      decoration:
                          const InputDecoration(labelText: 'Min Stock Level')),
                  TextField(
                      controller: reorderController,
                      decoration:
                          const InputDecoration(labelText: 'Reorder Level')),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: () => addIngredient(),
                      child: const Text('Add Ingredient')),
                ],
              ),
            ),
          ),
          const VerticalDivider(),
          Expanded(
            flex: 5,
            child: ListView.builder(
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final item = ingredients[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(item['name']!),
                    subtitle: Text(
                        '${item['category']} - ${item['subcategory']} \nBrand: ${item['brand']} | Stock: ${item['stock']} ${item['unit']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteIngredient(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
