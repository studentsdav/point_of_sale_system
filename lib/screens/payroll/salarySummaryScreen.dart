import 'dart:ui';

import 'package:flutter/material.dart';
import '../../backend/payroll/salary_service.dart';

class SalarySummaryScreen extends StatefulWidget {
  const SalarySummaryScreen({super.key});

  @override
  _SalarySummaryScreenState createState() => _SalarySummaryScreenState();
}

class _SalarySummaryScreenState extends State<SalarySummaryScreen> {
  List<dynamic> salaryData = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchSalaryData();
  }

  Future<void> fetchSalaryData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      salaryData = await SalaryService.getAllSalaries();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _loading = false;
      });
    }
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
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(child: Text(_error!))
                            : DataTable(
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
                        double finalSalary = (data['base_salary'] as num).toDouble();
                        if (data.containsKey('commission_earned')) {
                          finalSalary +=
                              (data['commission_earned'] as num).toDouble();
                        }
                        if (data.containsKey('tips_earned')) {
                          finalSalary += (data['tips_earned'] as num).toDouble();
                        }
                        if (data.containsKey('advance_deduction')) {
                          finalSalary -=
                              (data['advance_deduction'] as num).toDouble();
                        }
                        Color salaryColor = finalSalary < 25000
                            ? Colors.red
                            : Colors.green;

                        return DataRow(cells: [
                          DataCell(Text(data['employee_id'].toString())),
                          DataCell(Text('₹${data['base_salary']}')),
                          DataCell(Text('${data['present_days']}')),
                          DataCell(Text('${data['absent_days']}',
                              style: const TextStyle(color: Colors.red))),
                          DataCell(Text('${data['overtime_hours']} hrs',
                              style: const TextStyle(color: Colors.blue))),
                          DataCell(Text('${data['underworked_hours']} hrs',
                              style: const TextStyle(color: Colors.orange))),
                          DataCell(Text('${data['total_leaves']}')),
                          DataCell(Text('${data['total_hours']} hrs')),
                          DataCell(Text('${data['required_hours']} hrs')),
                          DataCell(Text('₹${data['salary_deduction']}',
                              style: const TextStyle(color: Colors.red))),
                          DataCell(Text('₹${data['overtime_bonus']}',
                              style: const TextStyle(color: Colors.green))),
                          DataCell(Text('₹${data['commission_earned']}',
                              style: const TextStyle(color: Colors.purple))),
                          DataCell(Text('₹${data['tips_earned']}',
                              style: const TextStyle(color: Colors.teal))),
                          DataCell(Text('₹${data['advance_deduction']}',
                              style: const TextStyle(color: Colors.brown))),
                          DataCell(Text('₹${data['insurance']}')),
                          DataCell(Text('₹${data['da']}')),
                          DataCell(Text('₹${data['esi']}')),
                          DataCell(Text('₹${data['epf']}')),
                          DataCell(Text('₹${finalSalary.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: salaryColor))),
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
                    "Total Salary Paid: ₹${salaryData.fold<double>(0, (sum, data) {
                      double finalSalary = (data['base_salary'] as num).toDouble();
                      if (data.containsKey('commission_earned')) {
                        finalSalary += (data['commission_earned'] as num).toDouble();
                      }
                      if (data.containsKey('tips_earned')) {
                        finalSalary += (data['tips_earned'] as num).toDouble();
                      }
                      if (data.containsKey('advance_deduction')) {
                        finalSalary -= (data['advance_deduction'] as num).toDouble();
                      }
                      return sum + finalSalary;
                    }).toStringAsFixed(2)}",
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
