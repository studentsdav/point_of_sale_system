import 'dart:ui';

import 'package:flutter/material.dart';

class SalarySummaryScreen extends StatefulWidget {
  const SalarySummaryScreen({super.key});

  @override
  _SalarySummaryScreenState createState() => _SalarySummaryScreenState();
}

class _SalarySummaryScreenState extends State<SalarySummaryScreen> {
  List<Map<String, dynamic>> salaryData = [];

  @override
  void initState() {
    super.initState();
    fetchSalaryData();
  }

  void fetchSalaryData() {
    setState(() {
      salaryData = List.generate(
        10,
        (index) => {
          "name": "Employee ${index + 1}",
          "base_salary": 30000 + (index * 1000),
          "present_days": 25 - index,
          "absent_days": index,
          "overtime_hours": index * 2,
          "underworked_hours": index,
          "total_leaves": index,
          "total_hours": (25 - index) * 8 + (index * 2) - index,
          "salary_deduction": index * 500,
          "overtime_bonus": index * 300,
          "required_hours": (25 - index) * 8,
          "commission_earned": index * 200,
          "tips_earned": index * 150,
          "advance_deduction": index * 250,
          "insurance": 500,
          "da": (30000 + (index * 1000)) * 0.1,
          "esi": (30000 + (index * 1000)) * 0.075,
          "epf": (30000 + (index * 1000)) * 0.12,
          "final_salary": (30000 + (index * 1000)) -
              (index * 500) +
              (index * 300) +
              (index * 200) +
              (index * 150) -
              (index * 250) -
              500 +
              (30000 + (index * 1000)) * 0.1 -
              (30000 + (index * 1000)) * 0.075 -
              (30000 + (index * 1000)) * 0.12,
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Salary Summary")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.all(Colors.grey[200]),
                      columns: const [
                        DataColumn(label: Text("Employee Name")),
                        DataColumn(label: Text("Base Salary")),
                        DataColumn(label: Text("Present Days")),
                        DataColumn(label: Text("Absent Days")),
                        DataColumn(label: Text("Overtime")),
                        DataColumn(label: Text("Underworked")),
                        DataColumn(label: Text("Total Leaves")),
                        DataColumn(label: Text("Total Hours")),
                        DataColumn(label: Text("Required Hours")),
                        DataColumn(label: Text("Deduction")),
                        DataColumn(label: Text("Bonus")),
                        DataColumn(label: Text("Commission")),
                        DataColumn(label: Text("Tips")),
                        DataColumn(label: Text("Advance Deduction")),
                        DataColumn(label: Text("Insurance")),
                        DataColumn(label: Text("DA")),
                        DataColumn(label: Text("ESI")),
                        DataColumn(label: Text("EPF")),
                        DataColumn(label: Text("Final Salary")),
                      ],
                      rows: salaryData.map((data) {
                        Color salaryColor = data['final_salary'] < 25000
                            ? Colors.red
                            : Colors.green;

                        return DataRow(cells: [
                          DataCell(Text(data['name'])), // Employee Name
                          DataCell(
                              Text("₹${data['base_salary']}")), // Base Salary
                          DataCell(
                              Text(" ${data['present_days']}")), // Present Days
                          DataCell(Text(" ${data['absent_days']}",
                              style: const TextStyle(
                                  color: Colors.red))), // Absent Days (Red)
                          DataCell(Text(" ${data['overtime_hours']} hrs",
                              style: const TextStyle(
                                  color: Colors.blue))), // Overtime (Blue)
                          DataCell(Text(" ${data['underworked_hours']} hrs",
                              style: const TextStyle(
                                  color:
                                      Colors.orange))), // Underworked (Orange)
                          DataCell(
                              Text(" ${data['total_leaves']}")), // Total Leaves
                          DataCell(Text(
                              " ${data['total_hours']} hrs")), // Total Hours
                          DataCell(Text(
                              " ${data['required_hours']} hrs")), // Required Hours
                          DataCell(Text("₹${data['salary_deduction']}",
                              style: const TextStyle(
                                  color: Colors.red))), // Deduction (Red)
                          DataCell(Text("₹${data['overtime_bonus']}",
                              style: const TextStyle(
                                  color: Colors.green))), // Bonus (Green)
                          DataCell(Text("₹${data['commission_earned']}",
                              style: const TextStyle(
                                  color:
                                      Colors.purple))), // Commission (Purple)
                          DataCell(Text("₹${data['tips_earned']}",
                              style: const TextStyle(
                                  color: Colors.teal))), // Tips (Teal)
                          DataCell(Text("₹${data['advance_deduction']}",
                              style: const TextStyle(
                                  color: Colors
                                      .brown))), // Advance Deduction (Brown)
                          DataCell(Text("₹${data['insurance']}")), // Insurance
                          DataCell(Text("₹${data['da']}")), // DA
                          DataCell(Text("₹${data['esi']}")), // ESI
                          DataCell(Text("₹${data['epf']}")), // EPF
                          DataCell(Text("₹${data['final_salary']}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      salaryColor))), // Final Salary (Green or Red)
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueAccent.shade700,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8)
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Total Salary Paid: ₹${salaryData.fold<double>(0, (sum, data) => sum + (data['final_salary'] as num)).toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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
