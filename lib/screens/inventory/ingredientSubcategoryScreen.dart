import 'package:flutter/material.dart';

class IngredientSubcategoryScreen extends StatefulWidget {
  const IngredientSubcategoryScreen({super.key});

  @override
  _IngredientSubcategoryScreenState createState() =>
      _IngredientSubcategoryScreenState();
}

class _IngredientSubcategoryScreenState
    extends State<IngredientSubcategoryScreen> {
  final TextEditingController _subcategoryController = TextEditingController();
  String? selectedCategory;
  List<String> categories = [
    'Vegetables',
    'Dairy',
    'Meat',
    'Spices'
  ]; // Mock categories
  List<Map<String, String>> subcategories = [];

  void _addSubcategory() {
    if (_subcategoryController.text.isEmpty || selectedCategory == null) return;

    final exists = subcategories.any((sub) =>
        sub['name'] == _subcategoryController.text.trim() &&
        sub['category'] == selectedCategory);

    if (!exists) {
      setState(() {
        subcategories.add({
          'name': _subcategoryController.text.trim(),
          'category': selectedCategory!,
        });
        _subcategoryController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subcategory already exists!')),
      );
    }
  }

  void _removeSubcategory(int index) {
    setState(() {
      subcategories.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingredient Subcategories')),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Subcategory',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    value: selectedCategory,
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedCategory = value),
                    hint: const Text('Select Category'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _subcategoryController,
                    decoration: const InputDecoration(
                      labelText: 'Subcategory Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addSubcategory,
                    child: const Text('Add Subcategory'),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Subcategory List',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: subcategories.length,
                      itemBuilder: (context, index) {
                        final subcategory = subcategories[index];
                        return Card(
                          child: ListTile(
                            title: Text(subcategory['name']!),
                            subtitle:
                                Text('Category: ${subcategory['category']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeSubcategory(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: IngredientSubcategoryScreen(),
  ));
}
