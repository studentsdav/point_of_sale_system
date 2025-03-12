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
      title: 'Purchase Management',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const PurchaseScreen(),
    );
  }
}

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController costPerUnitController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();

  String? selectedVendor;
  String? selectedItem;
  String? selectedCategory;
  String? selectedSubcategory;
  String? selectedBrand;

  List<Map<String, dynamic>> purchases = [];
  List<String> vendors = ['Vendor 1', 'Vendor 2', 'Vendor 3'];
  List<String> items = ['Item 1', 'Item 2', 'Item 3'];
  List<String> categories = ['Category 1', 'Category 2', 'Category 3'];
  List<String> subcategories = ['Subcategory 1', 'Subcategory 2'];
  List<String> brands = ['Brand 1', 'Brand 2'];

  void addPurchase() {
    int quantity = int.tryParse(quantityController.text) ?? 0;
    double costPerUnit = double.tryParse(costPerUnitController.text) ?? 0.0;
    String expiryDate = expiryDateController.text;
    double totalCost = quantity * costPerUnit;

    setState(() {
      purchases.add({
        'ID': purchases.length + 1,
        'Vendor': selectedVendor ?? 'Unknown',
        'Item': selectedItem ?? 'Unknown',
        'Category': selectedCategory ?? 'Unknown',
        'Subcategory': selectedSubcategory ?? 'Unknown',
        'Brand': selectedBrand ?? 'Unknown',
        'Quantity': quantity,
        'Cost Per Unit': costPerUnit,
        'Expiry Date': expiryDate,
        'Total Cost': totalCost,
        'Purchase Date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      });
      quantityController.clear();
      costPerUnitController.clear();
      expiryDateController.clear();
      selectedVendor = null;
      selectedItem = null;
      selectedCategory = null;
      selectedSubcategory = null;
      selectedBrand = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField(
                            value: selectedVendor,
                            decoration: const InputDecoration(
                                labelText: 'Select Vendor'),
                            items: vendors
                                .map((v) =>
                                    DropdownMenuItem(value: v, child: Text(v)))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => selectedVendor = value),
                          ),
                          DropdownButtonFormField(
                            value: selectedItem,
                            decoration:
                                const InputDecoration(labelText: 'Select Item'),
                            items: items
                                .map((v) =>
                                    DropdownMenuItem(value: v, child: Text(v)))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => selectedItem = value),
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
                            value: selectedSubcategory,
                            decoration: const InputDecoration(
                                labelText: 'Select Subcategory'),
                            items: subcategories
                                .map((v) =>
                                    DropdownMenuItem(value: v, child: Text(v)))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => selectedSubcategory = value),
                          ),
                          DropdownButtonFormField(
                            value: selectedBrand,
                            decoration: const InputDecoration(
                                labelText: 'Select Brand'),
                            items: brands
                                .map((v) =>
                                    DropdownMenuItem(value: v, child: Text(v)))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => selectedBrand = value),
                          ),
                          TextField(
                            controller: quantityController,
                            decoration:
                                const InputDecoration(labelText: 'Quantity'),
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            controller: costPerUnitController,
                            decoration: const InputDecoration(
                                labelText: 'Cost Per Unit'),
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            controller: expiryDateController,
                            decoration: const InputDecoration(
                                labelText: 'Expiry Date (YYYY-MM-DD)'),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: addPurchase,
                            child: const Text('Create Purchase'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: DataTable(
                              columnSpacing: 16.0,
                              columns: const [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('Vendor')),
                                DataColumn(label: Text('Item')),
                                DataColumn(label: Text('Total Cost')),
                                DataColumn(label: Text('Purchase Date')),
                              ],
                              rows: purchases
                                  .map((purchase) => DataRow(cells: [
                                        DataCell(
                                            Text(purchase['ID'].toString())),
                                        DataCell(Text(purchase['Vendor'])),
                                        DataCell(Text(purchase['Item'])),
                                        DataCell(Text(
                                            purchase['Total Cost'].toString())),
                                        DataCell(
                                            Text(purchase['Purchase Date'])),
                                      ]))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(8.0),
                        child: SfCartesianChart(
                          primaryXAxis: const CategoryAxis(),
                          title:
                              const ChartTitle(text: 'Total Purchases by Date'),
                          series: <CartesianSeries<_PurchaseData, String>>[
                            ColumnSeries<_PurchaseData, String>(
                              dataSource: getTotalPurchaseByDate(),
                              xValueMapper: (data, _) => data.date,
                              yValueMapper: (data, _) => data.totalCost,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<_PurchaseData> getTotalPurchaseByDate() {
    Map<String, double> totalByDate = {};
    for (var purchase in purchases) {
      String date = purchase['Purchase Date'];
      totalByDate[date] = (totalByDate[date] ?? 0) + purchase['Total Cost'];
    }
    return totalByDate.entries
        .map((e) => _PurchaseData(e.key, e.value))
        .toList();
  }
}

class _PurchaseData {
  final String date;
  final double totalCost;

  _PurchaseData(this.date, this.totalCost);
}
