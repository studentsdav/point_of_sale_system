import 'package:flutter/material.dart';

class IngredientBrandsScreen extends StatefulWidget {
  const IngredientBrandsScreen({super.key});

  @override
  _IngredientBrandsScreenState createState() => _IngredientBrandsScreenState();
}

class _IngredientBrandsScreenState extends State<IngredientBrandsScreen> {
  final TextEditingController _brandController = TextEditingController();
  List<String> brands = ['Brand A', 'Brand B', 'Brand C']; // Dummy data

  void _addBrand() {
    if (_brandController.text.isNotEmpty &&
        !brands.contains(_brandController.text)) {
      setState(() {
        brands.add(_brandController.text);
      });
      _brandController.clear();
    }
  }

  void _deleteBrand(int index) {
    setState(() {
      brands.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Brands'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          // Left-side form
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Brand',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _brandController,
                    decoration: const InputDecoration(
                      labelText: 'Brand Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addBrand,
                    child: const Text('Add Brand'),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(),
          // Right-side display
          Expanded(
            flex: 2,
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: brands.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(brands[index],
                        style: const TextStyle(fontSize: 18)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteBrand(index),
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

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: IngredientBrandsScreen(),
  ));
}
