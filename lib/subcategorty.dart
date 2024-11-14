import 'package:flutter/material.dart';

class SubcategoryForm extends StatefulWidget {
  @override
  _SubcategoryFormState createState() => _SubcategoryFormState();
}

class _SubcategoryFormState extends State<SubcategoryForm> {
  final _formKey = GlobalKey<FormState>();
  String subcategoryName = '';
  String subcategoryDescription = '';
  String? selectedCategory;
  
  // Example categories (These would be fetched from the database)
  List<Map<String, dynamic>> categories = [
    {'category_id': '1', 'category_name': 'Electronics'},
    {'category_id': '2', 'category_name': 'Furniture'},
    {'category_id': '3', 'category_name': 'Groceries'},
  ];

  // Saved values for subcategories
  List<Map<String, dynamic>> savedSubcategories = [];

  // Method to save subcategory
  void _saveSubcategory() {
    if (_formKey.currentState!.validate() && selectedCategory != null) {
      _formKey.currentState!.save();

      // Save subcategory logic (e.g., saving to database)
      setState(() {
        savedSubcategories.add({
          'subcategory_name': subcategoryName,
          'subcategory_description': subcategoryDescription,
          'category_name': categories.firstWhere((category) => category['category_id'] == selectedCategory)['category_name'],
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Subcategory saved successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subcategory Form')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Entry Panel for Subcategory Details
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dropdown for category selection
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Select Category'),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['category_id'].toString(),
                          child: Text(category['category_name']),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedCategory = value),
                      validator: (value) => value == null ? 'Please select a category' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Subcategory Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a subcategory name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        subcategoryName = value!;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Subcategory Description'),
                      maxLines: 3,
                      onSaved: (value) {
                        subcategoryDescription = value!;
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveSubcategory,
                      child: Text('Save Subcategory'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              // Display Panel for Saved Subcategories
              if (savedSubcategories.isNotEmpty)
                Column(
                  children: savedSubcategories.map((subcategory) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Subcategory Name: ${subcategory['subcategory_name']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Category: ${subcategory['category_name']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Description: ${subcategory['subcategory_description']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
