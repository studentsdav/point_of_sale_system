import 'package:flutter/material.dart';

class ExpenseApprovalScreen extends StatefulWidget {
  const ExpenseApprovalScreen({super.key});

  @override
  _ExpenseApprovalScreenState createState() => _ExpenseApprovalScreenState();
}

class _ExpenseApprovalScreenState extends State<ExpenseApprovalScreen> {
  List<Map<String, dynamic>> pendingExpenses = [
    {
      "id": 1,
      "category": "Food",
      "amount": 500,
      "created_by": "John Doe",
      "created_at": "2024-03-10 10:00 AM"
    },
    {
      "id": 2,
      "category": "Transport",
      "amount": 300,
      "created_by": "Jane Smith",
      "created_at": "2024-03-10 11:30 AM"
    }
  ];

  List<Map<String, dynamic>> approvedExpenses = [];

  void approveExpense(int index) {
    setState(() {
      Map<String, dynamic> approved = pendingExpenses.removeAt(index);
      approved["approved_by"] = "Manager";
      approved["approved_at"] =
          "${DateTime.now().hour}:${DateTime.now().minute} PM";
      approvedExpenses.add(approved);
    });
  }

  void rejectExpense(int index) {
    setState(() {
      pendingExpenses.removeAt(index);
    });
  }

  Widget buildExpenseCard(
      Map<String, dynamic> expense, bool isPending, int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              expense["category"],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text("Amount: ₹${expense["amount"]}",
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            Text("Created By: ${expense["created_by"]}",
                style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
            Text("Created At: ${expense["created_at"]}",
                style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
            if (!isPending) ...[
              const Divider(),
              Text("Approved By: ${expense["approved_by"]}",
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
              Text("Approved At: ${expense["approved_at"]}",
                  style: const TextStyle(fontSize: 14, color: Colors.green)),
            ],
            if (isPending) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => approveExpense(index),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text("Approve"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => rejectExpense(index),
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text("Reject"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expense Approval")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Pending Approvals",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: pendingExpenses.length,
                      itemBuilder: (context, index) =>
                          buildExpenseCard(pendingExpenses[index], true, index),
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Approved Expenses",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: approvedExpenses.length,
                      itemBuilder: (context, index) => buildExpenseCard(
                          approvedExpenses[index], false, index),
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
