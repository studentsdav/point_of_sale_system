import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe Management',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const RecipeScreen(),
    );
  }
}

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final TextEditingController quantityController = TextEditingController();
  String? selectedMenuItem;
  String? selectedIngredient;
  String? selectedCategory;
  String? selectedSubcategory;
  String? selectedBrand;
  String? selectedUnit;

  List<Map<String, dynamic>> recipes = [];
  List<String> menuItems = ['Pizza', 'Burger', 'Pasta'];
  List<String> ingredients = ['Cheese', 'Tomato', 'Bread'];
  List<String> categories = ['Dairy', 'Vegetable', 'Grain'];
  List<String> subcategories = ['Soft Cheese', 'Fresh Veggies'];
  List<String> brands = ['Brand A', 'Brand B'];
  List<String> units = ['kg', 'g', 'ml', 'L', 'pcs'];

  void addRecipe() {
    double quantity = double.tryParse(quantityController.text) ?? 0.0;
    String createdAt = DateFormat('yyyy-MM-dd').format(DateTime.now());

    setState(() {
      recipes.add({
        'ID': recipes.length + 1,
        'Menu Item': selectedMenuItem ?? 'Unknown',
        'Ingredient': selectedIngredient ?? 'Unknown',
        'Category': selectedCategory ?? 'Unknown',
        'Subcategory': selectedSubcategory ?? 'Unknown',
        'Brand': selectedBrand ?? 'Unknown',
        'Quantity Used': quantity,
        'Unit': selectedUnit ?? 'Unknown',
        'Created At': createdAt,
      });
      quantityController.clear();
      selectedMenuItem = null;
      selectedIngredient = null;
      selectedCategory = null;
      selectedSubcategory = null;
      selectedBrand = null;
      selectedUnit = null;
    });
  }

  Map<String, List<Map<String, dynamic>>> groupRecipesByMenuItem() {
    Map<String, List<Map<String, dynamic>>> groupedRecipes = {};
    for (var recipe in recipes) {
      String menuItem = recipe['Menu Item'];
      if (!groupedRecipes.containsKey(menuItem)) {
        groupedRecipes[menuItem] = [];
      }
      groupedRecipes[menuItem]!.add(recipe);
    }
    return groupedRecipes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Management')),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField(
                          value: selectedMenuItem,
                          decoration: const InputDecoration(
                              labelText: 'Select Menu Item'),
                          items: menuItems
                              .map((v) =>
                                  DropdownMenuItem(value: v, child: Text(v)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedMenuItem = value),
                        ),
                        DropdownButtonFormField(
                          value: selectedIngredient,
                          decoration: const InputDecoration(
                              labelText: 'Select Ingredient'),
                          items: ingredients
                              .map((v) =>
                                  DropdownMenuItem(value: v, child: Text(v)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedIngredient = value),
                        ),
                        DropdownButtonFormField(
                          value: selectedCategory,
                          decoration: const InputDecoration(
                              labelText: 'Select Category'),
                          items: categories
                              .map((v) =>
                                  DropdownMenuItem(value: v, child: Text(v)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedCategory = value),
                        ),
                        DropdownButtonFormField(
                          value: selectedUnit,
                          decoration:
                              const InputDecoration(labelText: 'Select Unit'),
                          items: units
                              .map((v) =>
                                  DropdownMenuItem(value: v, child: Text(v)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedUnit = value),
                        ),
                        TextField(
                          controller: quantityController,
                          decoration:
                              const InputDecoration(labelText: 'Quantity Used'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: addRecipe,
                          child: const Text('Add Recipe'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: groupRecipesByMenuItem().entries.map((entry) {
                  return Column(
                    children: [
                      Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 3,
                        child: ExpansionTile(
                          title: Text(entry.key,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          children: entry.value.map((recipe) {
                            return ListTile(
                                title: Text(recipe['Ingredient']),
                                subtitle: Text(
                                    "${recipe['Quantity Used']} ${recipe['Unit']} | ${recipe['Created At']}"));
                          }).toList(),
                        ),
                      ),
                      SfCircularChart(
                          title:
                              ChartTitle(text: '${entry.key} Ingredient Usage'),
                          legend: const Legend(
                              isVisible: true, position: LegendPosition.bottom),
                          series: <CircularSeries>[
                            PieSeries<Map<String, dynamic>, String>(
                              dataSource: entry.value,
                              xValueMapper: (data, _) => data['Ingredient'],
                              yValueMapper: (data, _) => data['Quantity Used'],
                              dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  labelPosition:
                                      ChartDataLabelPosition.outside),
                            )
                          ]),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
