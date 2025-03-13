import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AttendanceReportEmployee extends StatefulWidget {
  const AttendanceReportEmployee({super.key});

  @override
  _AttendanceReportEmployeeState createState() =>
      _AttendanceReportEmployeeState();
}

class _AttendanceReportEmployeeState extends State<AttendanceReportEmployee> {
  String selectedEmployee = 'John Doe';
  List<String> employees = ['John Doe', 'Jane Smith', 'Michael Brown'];

  Map<String, List<DailyAttendance>> generateRandomAttendance() {
    final random = Random();
    final now = DateTime.now();
    Map<String, List<DailyAttendance>> data = {};

    for (var employee in employees) {
      data[employee] = List.generate(30, (index) {
        DateTime date = now.subtract(Duration(days: index));
        String formattedDate = "${date.month}/${date.day}";
        int chance = random.nextInt(100);
        double hours = chance < 10
            ? 0 // 10% chance of being absent
            : (chance < 20
                ? -1 // 10% chance of leave
                : random.nextDouble() * 4 + 6); // 6 to 10 hours
        return DailyAttendance(formattedDate, hours);
      }).reversed.toList();
    }
    return data;
  }

  late Map<String, List<DailyAttendance>> employeeAttendanceData;

  @override
  void initState() {
    super.initState();
    employeeAttendanceData = generateRandomAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Attendance Analysis Report')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButton<String>(
                value: selectedEmployee,
                items: employees
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedEmployee = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: SfCartesianChart(
                  title:
                      const ChartTitle(text: 'Last 30 Days Attendance Hours'),
                  primaryXAxis: const CategoryAxis(),
                  series: <CartesianSeries<dynamic, dynamic>>[
                    ColumnSeries<DailyAttendance, String>(
                      dataSource:
                          employeeAttendanceData[selectedEmployee] ?? [],
                      xValueMapper: (DailyAttendance data, _) => data.date,
                      yValueMapper: (DailyAttendance data, _) =>
                          data.hours >= 0 ? data.hours : null,
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Metric')),
                          DataColumn(label: Text('Value')),
                        ],
                        rows: [
                          _buildSummaryRow(
                              'Total Hours (30 Days)', '240', Colors.blue),
                          _buildSummaryRow(
                              'Required Hours', '240', Colors.green),
                          _buildSummaryRow('Overtime', '10', Colors.orange),
                          _buildSummaryRow('Leave', '5', Colors.red),
                          _buildSummaryRow('Absent', '3', Colors.purple),
                          _buildSummaryRow('Present Days', '22', Colors.teal),
                          _buildSummaryRow('Net Hours After Adjustment', '250',
                              Colors.deepOrange),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    height: 300,
                    width: 300,
                    child: SfCircularChart(
                      title: const ChartTitle(text: 'Attendance Breakdown'),
                      legend: const Legend(isVisible: true),
                      series: <PieSeries<AttendanceSummary, String>>[
                        PieSeries<AttendanceSummary, String>(
                          dataSource: [
                            AttendanceSummary('Present', 22, Colors.teal),
                            AttendanceSummary('Leave', 5, Colors.red),
                            AttendanceSummary('Absent', 3, Colors.purple),
                            AttendanceSummary('Overtime', 10, Colors.orange),
                          ],
                          xValueMapper: (AttendanceSummary data, _) =>
                              data.category,
                          yValueMapper: (AttendanceSummary data, _) =>
                              data.value,
                          pointColorMapper: (AttendanceSummary data, _) =>
                              data.color,
                          dataLabelSettings:
                              const DataLabelSettings(isVisible: true),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildSummaryRow(String label, String value, Color color) {
    return DataRow(cells: [
      DataCell(Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold))),
      DataCell(Text(value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold))),
    ]);
  }
}

class DailyAttendance {
  final String date;
  final double hours;
  DailyAttendance(this.date, this.hours);
}

class AttendanceSummary {
  final String category;
  final double value;
  final Color color;
  AttendanceSummary(this.category, this.value, this.color);
}
