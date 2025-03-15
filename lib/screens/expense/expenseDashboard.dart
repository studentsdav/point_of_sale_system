import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'accouts.dart';
import 'expense.dart';
import 'expenseApprovalScreen.dart';
import 'expenseCategory.dart';
import 'expenseSubCategoryScreen.dart';
import 'taxManagementScreen.dart';

class ExpenseDashboard extends StatefulWidget {
  const ExpenseDashboard({super.key});

  @override
  _ExpenseDashboardState createState() => _ExpenseDashboardState();
}

class _ExpenseDashboardState extends State<ExpenseDashboard> {
  int _selectedIndex = 0;

  final List<String> menuItems = [
    "Account Manager",
    "Expenses",
    "Expense Approval",
    "Expense Category",
    "Expense Subcategory",
    "Tax",
  ];

  void navigateToScreen(int index) {
    Widget screen;
    switch (index) {
      case 0:
        screen = const AccountManagerScreen();
        break;
      case 1:
        screen = const ExpenseScreen();
        break;
      case 2:
        screen = const ExpenseApprovalScreen();
        break;
      case 3:
        screen = const ExpenseCategoryScreen();
        break;
      case 4:
        screen = const ExpenseSubCategoryScreen();
        break;
      case 5:
        screen = const TaxScreen();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
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
              onTap: () {
                setState(() => _selectedIndex = entry.key);
                Navigator.pop(context); // Close the drawer
                navigateToScreen(entry.key);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget buildExpenseSummaryCards() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: buildExpenseCard(
                    'Salaries',
                    Icons.account_balance_wallet,
                    '₹ 500,000',
                    Colors.green,
                    "+5%")),
            const SizedBox(width: 16),
            Expanded(
                child: buildExpenseCard('Purchases', Icons.shopping_cart,
                    '₹ 300,000', Colors.blue, "+8%")),
            const SizedBox(width: 16),
            Expanded(
                child: buildExpenseCard('Other Expenses', Icons.attach_money,
                    '₹ 100,000', Colors.orange, "-3%")),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: buildExpenseCard('Total Expenses', Icons.money,
                    '₹ 900,000', Colors.red, "+4%")),
          ],
        ),
      ],
    );
  }

  Widget buildExpenseCard(
      String title, IconData icon, String value, Color color, String growth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 4),
              Text('Growth: $growth',
                  style: const TextStyle(fontSize: 12, color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildExpenseChart() {
    final List<ExpenseData> expenseData = [
      ExpenseData('01 Mar', 50000),
      ExpenseData('02 Mar', 70000),
      ExpenseData('03 Mar', 40000),
      ExpenseData('04 Mar', 65000),
      ExpenseData('05 Mar', 80000),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Last 30 Days Expenses",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SfCartesianChart(
            primaryXAxis: const CategoryAxis(),
            series: <ColumnSeries<ExpenseData, String>>[
              ColumnSeries<ExpenseData, String>(
                dataSource: expenseData,
                xValueMapper: (ExpenseData data, _) => data.date,
                yValueMapper: (ExpenseData data, _) => data.amount,
                markerSettings: const MarkerSettings(isVisible: true),
                color: Colors.blue,
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildExpenseTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Expense Report",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Payment Method')),
                DataColumn(label: Text('Spend On')),
              ],
              rows: [
                buildTableRow('01 Mar', 'Salary', '₹ 50,000', 'Bank Transfer',
                    "Employee"),
                buildTableRow(
                    '02 Mar', 'Purchase', '₹ 70,000', 'Cash', "Vendor"),
                buildTableRow(
                    '03 Mar', 'Utilities', '₹ 10,000', 'UPI', "Property"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow buildTableRow(
      String date, String category, String amount, String method, String type) {
    Color rowColor = category == 'Salary'
        ? Colors.green.withOpacity(0.2)
        : (category == 'Purchase'
            ? Colors.blue.withOpacity(0.2)
            : Colors.orange.withOpacity(0.2));

    return DataRow(
      color: WidgetStateProperty.all(rowColor),
      cells: [
        DataCell(Text(date)),
        DataCell(Text(category)),
        DataCell(Text(amount)),
        DataCell(Text(method)),
        DataCell(Text(type)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Dashboard"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_forward_ios))
        ],
      ),
      drawer: buildDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildExpenseSummaryCards(),
            const SizedBox(height: 20),
            buildExpenseChart(),
            const SizedBox(height: 20),
            buildExpenseTable(),
          ],
        ),
      ),
    );
  }
}

class ExpenseData {
  final String date;
  final double amount;
  ExpenseData(this.date, this.amount);
}
