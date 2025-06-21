import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../backend/api_config.dart';
import '../../backend/inventory/InventoryApiService.dart';
import '../../backend/inventory/closing_balance_api_service.dart';

import 'VendorScreen.dart';
import 'closingStockReport.dart';
import 'ingredientBrandsScreen.dart';
import 'ingredientCategoriesScreen.dart';
import 'ingredientManager.dart';
import 'ingredientSubcategoryScreen.dart';
import 'paymentMethodsScreen.dart';
import 'purchaseScreen.dart';
import 'recipeScreen.dart';
import 'stockAdjustmentScreen.dart';
import 'vendorPaymentScreen.dart';

class InventoryDashboard extends StatefulWidget {
  const InventoryDashboard({super.key});

  @override
  State<InventoryDashboard> createState() => _InventoryDashboardState();
}

class _InventoryDashboardState extends State<InventoryDashboard> {
  int _selectedIndex = 0;

  final InventoryApiService _inventoryService =
      InventoryApiService(baseUrl: apiBaseUrl);
  final ClosingBalanceApiService _closingService =
      ClosingBalanceApiService(apiBaseUrl);

  List<SalesData> _transactions = [];
  List<StockItem> _closingStock = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _loadClosingStock();
  }

  final List<String> menuItems = [
    "Closing Stock Report",
    "Ingredient Brands",
    "Ingredient Categories",
    "Ingredient Management",
    "Ingredient Subcategories",
    "Payment Methods",
    "Purchase",
    "Recipe",
    "Stock Adjustment",
    "Vendor Payment Report",
    "Vendor",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory Dashboard"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_forward_ios))
        ],
      ),
      drawer: buildDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildSummaryBoxes(),
            const SizedBox(height: 16),
            buildTransactionChart(),
            const SizedBox(height: 16),
            buildClosingStockReport(),
          ],
        ),
      ),
    );
  }

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Menu',
                style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ...menuItems.asMap().entries.map((entry) {
            return ListTile(
              title: Text(entry.value),
              selected: _selectedIndex == entry.key,
              onTap: () async {
                setState(() => _selectedIndex = entry.key);
                Navigator.pop(context); // Close the drawer
                await navigateToScreen(entry.key);
                _loadTransactions();
                _loadClosingStock();
              },
            );
          }),
        ],
      ),
    );
  }

  Future<void> navigateToScreen(int index) async {
    Widget screen;
    switch (index) {
      case 0:
        screen = const ClosingStockReport();
        break;
      case 1:
        screen = const IngredientBrandsScreen();
        break;
      case 2:
        screen = const IngredientCategoryScreen();
        break;
      case 3:
        screen = const IngredientManagementScreen();
        break;
      case 4:
        screen = const IngredientSubcategoryScreen();
        break;
      case 5:
        screen = const PaymentMethodsScreen();
        break;
      case 6:
        screen = const PurchaseScreen();
        break;
      case 7:
        screen = const RecipeScreen();
        break;
      case 8:
        screen = const StockAdjustmentScreen();
        break;
      case 9:
        screen = const VendorPaymentReportScreen();
        break;
      case 10:
        screen = ProviderScope(child: VendorScreen());
        break;
      default:
        return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Widget buildSummaryBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: buildInfoCard(
                'Pending Vendor Payments', '₹ 50,000', Colors.red)),
        const SizedBox(width: 16),
        Expanded(
            child:
                buildInfoCard('Paid this Month', '₹ 1,20,000', Colors.green)),
        const SizedBox(width: 16),
        Expanded(
            child: buildInfoCard(
                'Total Purchase Value', '₹ 5,00,000', Colors.blue)),
        const SizedBox(width: 16),
        Expanded(
            child:
                buildInfoCard('Total Sold Value', '₹ 7,50,000', Colors.orange)),
        const SizedBox(width: 16),
        Expanded(
            child: buildInfoCard('Closing Balance', '₹ 2,50,000', Colors.teal)),
      ],
    );
  }

  Widget buildInfoCard(String title, String value, Color color) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget buildTransactionChart() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SfCartesianChart(
        primaryXAxis: const CategoryAxis(),
        title: const ChartTitle(text: 'Last 30 Days Transactions'),
        series: <ColumnSeries>[
          ColumnSeries<SalesData, String>(
            dataSource: _transactions,
            xValueMapper: (SalesData data, _) => data.day,
            yValueMapper: (SalesData data, _) => data.value,
            color: Colors.blue,
          )
        ],
      ),
    );
  }


  Widget buildClosingStockReport() {
    return Container(
      height: 500,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Closing Stock Report',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                physics: const ClampingScrollPhysics(),
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                  columns: const [
                    DataColumn(label: Text('Item Name')),
                    DataColumn(label: Text('Purchase')),
                    DataColumn(label: Text('Sold Out')),
                    DataColumn(label: Text('Closing Balance')),
                    DataColumn(label: Text('Wasted')),
                    DataColumn(label: Text('Expired')),
                    DataColumn(label: Text('Net Value')),
                  ],
                  rows: _closingStock.map((item) {
                    return DataRow(cells: [
                      DataCell(
                          Text(item.name, style: TextStyle(color: item.color))),
                      DataCell(Text(item.purchase.toString())),
                      DataCell(Text(item.sold.toString())),
                      DataCell(Text(item.closing.toString())),
                      DataCell(Text(item.wasted.toString())),
                      DataCell(Text(item.expired.toString())),
                      DataCell(Text('₹ ${item.netValue}')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadTransactions() async {
    try {
      final data = await _inventoryService.getInventoryTransactions();
      setState(() {
        _transactions = data
            .map<SalesData>((t) =>
                SalesData(t['day'].toString(), (t['value'] ?? 0).toDouble()))
            .toList();
      });
    } catch (e) {
      // handle error
    }
  }

  Future<void> _loadClosingStock() async {
    try {
      final data = await _closingService.fetchAllClosingBalances();
      setState(() {
        _closingStock = data
            .map<StockItem>((item) => StockItem(
                  item['name'] ?? '',
                  item['purchase'] ?? 0,
                  item['sold'] ?? 0,
                  item['closing'] ?? 0,
                  item['wasted'] ?? 0,
                  item['expired'] ?? 0,
                  (item['netValue'] ?? 0).toDouble(),
                  Colors.black,
                ))
            .toList();
      });
    } catch (e) {
      // handle error
    }
  }

}

class SalesData {
  final String day;
  final double value;
  SalesData(this.day, this.value);
}

class StockItem {
  final String name;
  final int purchase, sold, closing, wasted, expired;
  final double netValue;
  final Color color;

  StockItem(this.name, this.purchase, this.sold, this.closing, this.wasted,
      this.expired, this.netValue, this.color);
}
