import 'package:flutter/material.dart';

class CategoryForm extends StatefulWidget {
  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _categoryFormKey = GlobalKey<FormState>();
  final _subcategoryFormKey = GlobalKey<FormState>();

  String categoryName = '';
  String categoryDescription = '';
  String subCategoryName = '';
  String subCategoryDescription = '';

  // Lists to store saved categories and subcategories
  List<Map<String, String>> savedCategories = [];
  List<Map<String, String>> savedSubCategories = [];

  // Method to save category
  void _saveCategory() {
    if (_categoryFormKey.currentState!.validate()) {
      _categoryFormKey.currentState!.save();

      // Save category logic (e.g., saving to database)
      setState(() {
        savedCategories.add({
          'name': categoryName,
          'description': categoryDescription,
        });
      });

      // Clear form fields for the next category
      _categoryFormKey.currentState!.reset();

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Category saved successfully')));
    }
  }

  // Method to save subcategory
  void _saveSubCategory() {
    if (_subcategoryFormKey.currentState!.validate()) {
      _subcategoryFormKey.currentState!.save();

      // Save subcategory logic (e.g., saving to database)
      setState(() {
        savedSubCategories.add({
          'name': subCategoryName,
          'description': subCategoryDescription,
        });
      });

      // Clear form fields for the next subcategory
      _subcategoryFormKey.currentState!.reset();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subcategory saved successfully')));
    }
  }

  // Method to edit a category
  void _editCategory(int index) {
    categoryName = savedCategories[index]['name']!;
    categoryDescription = savedCategories[index]['description']!;

    _categoryFormKey.currentState!.reset();

    setState(() {
      savedCategories.removeAt(index);
    });
  }

  // Method to delete a category
  void _deleteCategory(int index) {
    setState(() {
      savedCategories.removeAt(index);
    });
  }

  // Method to edit a subcategory
  void _editSubCategory(int index) {
    subCategoryName = savedSubCategories[index]['name']!;
    subCategoryDescription = savedSubCategories[index]['description']!;

    _subcategoryFormKey.currentState!.reset();

    setState(() {
      savedSubCategories.removeAt(index);
    });
  }

  // Method to delete a subcategory
  void _deleteSubCategory(int index) {
    setState(() {
      savedSubCategories.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Category and Subcategory Form')),
      body: Center(
        child: Container(
          width: 400, // Set a fixed width for the form
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Entry Panel for Category Details
                Form(
                  key: _categoryFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Name
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Category Name',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a category name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          categoryName = value!;
                        },
                      ),
                      SizedBox(height: 8),
                      // Category Description
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Category Description',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        ),
                        maxLines: 2,
                        onSaved: (value) {
                          categoryDescription = value!;
                        },
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _saveCategory,
                        child: Text('Save Category'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),

                // Entry Panel for Subcategory Details
                Form(
                  key: _subcategoryFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subcategory Name
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Subcategory Name',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a subcategory name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          subCategoryName = value!;
                        },
                      ),
                      SizedBox(height: 8),
                      // Subcategory Description
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Subcategory Description',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        ),
                        maxLines: 2,
                        onSaved: (value) {
                          subCategoryDescription = value!;
                        },
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _saveSubCategory,
                        child: Text('Save Subcategory'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),

                // Display Panel for Saved Categories
                if (savedCategories.isNotEmpty)
                  Column(
                    children: savedCategories.map((category) {
                      int index = savedCategories.indexOf(category);
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category Name: ${category['name']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Category Description: ${category['description']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _editCategory(index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteCategory(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                SizedBox(height: 16),

                // Display Panel for Saved Subcategories
                if (savedSubCategories.isNotEmpty)
                  Column(
                    children: savedSubCategories.map((subCategory) {
                      int index = savedSubCategories.indexOf(subCategory);
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Subcategory Name: ${subCategory['name']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Subcategory Description: ${subCategory['description']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _editSubCategory(index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteSubCategory(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
