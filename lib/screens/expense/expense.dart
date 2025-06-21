import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../backend/expense/expense_api_service.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final ExpenseApiService _apiService = ExpenseApiService();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController subcategoryController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String? selectedEmployee;
  String? selectedVendor;
  String? selectedPaymentMethod;

  List<String> employees = ["John Doe", "Jane Smith", "Alice Johnson"];
  List<String> vendors = ["Local Market", "Uber", "Supermart"];
  List<String> paymentMethods = ["Cash", "UPI", "Bank Transfer"];

  late Future<List<dynamic>> _expenseFuture;

  @override
  void initState() {
    super.initState();
    _expenseFuture = _apiService.getAllExpenses();
  }

  Future<void> addExpense() async {
    if (categoryController.text.isNotEmpty &&
        amountController.text.isNotEmpty) {
      final data = {
        'category': categoryController.text,
        'subcategory': subcategoryController.text,
        'employee': selectedEmployee,
        'vendor': selectedVendor,
        'payment_method': selectedPaymentMethod,
        'amount': double.parse(amountController.text),
        'date': selectedDate.toIso8601String(),
        'description': descriptionController.text,
      };

      try {
        await _apiService.addExpense(data);
        setState(() {
          _expenseFuture = _apiService.getAllExpenses();
        });
        categoryController.clear();
        subcategoryController.clear();
        amountController.clear();
        descriptionController.clear();
        selectedEmployee = null;
        selectedVendor = null;
        selectedPaymentMethod = null;
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: '+e.toString())));
      }
    }
  }

  List<ExpenseData> getChartData(List<dynamic> expenses) {
    Map<String, double> monthlyExpenses = {};

    for (var expense in expenses) {
      DateTime date = DateTime.parse(expense['date']);
      String month = "${date.month}-${date.year}";
      monthlyExpenses[month] =
          (monthlyExpenses[month] ?? 0) + (expense['amount'] as num).toDouble();
    }

    return monthlyExpenses.entries
        .map((e) => ExpenseData(e.key, e.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expense Manager")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Add Expense",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      TextField(
                          controller: categoryController,
                          decoration:
                              const InputDecoration(labelText: "Category")),
                      TextField(
                          controller: subcategoryController,
                          decoration:
                              const InputDecoration(labelText: "Subcategory")),
                      DropdownButtonFormField<String>(
                        value: selectedEmployee,
                        hint: const Text("Select Employee"),
                        items: employees
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => selectedEmployee = value),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedVendor,
                        hint: const Text("Select Vendor"),
                        items: vendors
                            .map((v) =>
                                DropdownMenuItem(value: v, child: Text(v)))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => selectedVendor = value),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedPaymentMethod,
                        hint: const Text("Select Payment Method"),
                        items: paymentMethods
                            .map((p) =>
                                DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => selectedPaymentMethod = value),
                      ),
                      TextField(
                          controller: amountController,
                          decoration:
                              const InputDecoration(labelText: "Amount"),
                          keyboardType: TextInputType.number),
                      TextField(
                          controller: descriptionController,
                          decoration:
                              const InputDecoration(labelText: "Description")),
                      ListTile(
                        title: Text("Expense Date: \${selectedDate.toLocal()}"
                            .split(' ')[0]),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != selectedDate) {
                            setState(() => selectedDate = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                          onPressed: addExpense,
                          child: const Text("Save Expense")),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: Column(
                children: [

                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: _expenseFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        final expenses = snapshot.data ?? [];
                        return Column(
                          children: [
                            const Text('Expense List',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: ListView.builder(
                                itemCount: expenses.length,
                                itemBuilder: (context, index) {
                                  final expense = expenses[index];
                                  return ListTile(
                                    title: Text('Category: ${expense['category']} - ₹${expense['amount']}'),
                                    subtitle: Text('Employee: ${expense['employee']}, Vendor: ${expense['vendor']}, Payment: ${expense['payment_method']}, Date: ${expense['date']}'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        await _apiService.deleteExpense(expense['id'].toString());
                                        setState(() {
                                          _expenseFuture = _apiService.getAllExpenses();
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 200,
                              child: SfCartesianChart(
                                primaryXAxis: const CategoryAxis(),
                                series: <CartesianSeries<ExpenseData, String>>[
                                  ColumnSeries<ExpenseData, String>(
                                    dataSource: getChartData(expenses),
                                    xValueMapper: (ExpenseData data, _) => data.month,
                                    yValueMapper: (ExpenseData data, _) => data.amount,
                                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseData {
  final String month;
  final double amount;
  ExpenseData(this.month, this.amount);
}
