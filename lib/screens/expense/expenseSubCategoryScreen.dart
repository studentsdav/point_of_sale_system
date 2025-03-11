import 'package:flutter/material.dart';

class ExpenseSubCategoryScreen extends StatefulWidget {
  const ExpenseSubCategoryScreen({super.key});

  @override
  _ExpenseSubCategoryScreenState createState() =>
      _ExpenseSubCategoryScreenState();
}

class _ExpenseSubCategoryScreenState extends State<ExpenseSubCategoryScreen> {
  final TextEditingController _subcategoryController = TextEditingController();
  String? _selectedCategory;
  List<String> categories = ['Food', 'Transport', 'Utilities'];
  List<Map<String, String>> subcategories = [];

  void _addSubcategory() {
    if (_selectedCategory != null && _subcategoryController.text.isNotEmpty) {
      setState(() {
        subcategories.add({
          'category': _selectedCategory!,
          'subcategory': _subcategoryController.text
        });
        _subcategoryController.clear();
      });
    }
  }

  void _editSubcategory(int index) {
    setState(() {
      _subcategoryController.text = subcategories[index]['subcategory']!;
      _selectedCategory = subcategories[index]['category'];
    });
  }

  void _deleteSubcategory(int index) {
    setState(() {
      subcategories.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expense Subcategories")),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    hint: const Text("Select Category"),
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                          value: category, child: Text(category));
                    }).toList(),
                  ),
                  TextField(
                    controller: _subcategoryController,
                    decoration:
                        const InputDecoration(labelText: "Subcategory Name"),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: _addSubcategory,
                      child: const Text("Add Subcategory")),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(subcategories[index]['subcategory']!),
                    subtitle:
                        Text("Category: ${subcategories[index]['category']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editSubcategory(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteSubcategory(index),
                        ),
                      ],
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
