import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SalaryReportScreen extends StatefulWidget {
  const SalaryReportScreen({super.key});

  @override
  _SalaryReportScreenState createState() => _SalaryReportScreenState();
}

class _SalaryReportScreenState extends State<SalaryReportScreen> {
  final List<Map<String, dynamic>> salaryData = [
    {
      "Employee": "John Doe",
      "Department": "Sales",
      "Amount": 50000.00,
      "Month": "Jan"
    },
    {
      "Employee": "Jane Smith",
      "Department": "Marketing",
      "Amount": 60000.00,
      "Month": "Jan"
    },
    {
      "Employee": "Bob Johnson",
      "Department": "IT",
      "Amount": 75000.00,
      "Month": "Feb"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salary Report')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Employee Salary Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Employee')),
                    DataColumn(label: Text('Department')),
                    DataColumn(label: Text('Salary')),
                    DataColumn(label: Text('Month')),
                  ],
                  rows: salaryData.map((record) {
                    return DataRow(cells: [
                      DataCell(Text(record["Employee"]!)),
                      DataCell(Text(record["Department"]!)),
                      DataCell(Text(record["Amount"].toString())),
                      DataCell(Text(record["Month"]!)),
                    ]);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Top Paying Staff',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: SfCartesianChart(
                  primaryXAxis: const CategoryAxis(),
                  title: const ChartTitle(text: 'Top Paying Staff'),
                  legend: const Legend(isVisible: true),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries<ChartData, String>>[
                    ColumnSeries<ChartData, String>(
                      dataSource: getTopPayingStaff(),
                      xValueMapper: (ChartData data, _) => data.type,
                      yValueMapper: (ChartData data, _) => data.amount,
                      name: 'Salary',
                      pointColorMapper: (ChartData data, _) =>
                          Colors.blueAccent,
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Monthly Salary Consumption',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: SfCartesianChart(
                  primaryXAxis: const CategoryAxis(),
                  title: const ChartTitle(text: 'Monthly Salary Consumption'),
                  legend: const Legend(isVisible: true),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries<ChartData, String>>[
                    LineSeries<ChartData, String>(
                      dataSource: getMonthlyConsumption(),
                      xValueMapper: (ChartData data, _) => data.type,
                      yValueMapper: (ChartData data, _) => data.amount,
                      name: 'Total Salary',
                      color: Colors.green,
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Salary Distribution by Department',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 400,
                child: SfCircularChart(
                  title: const ChartTitle(text: 'Salary Distribution'),
                  legend: const Legend(isVisible: true),
                  series: <CircularSeries<ChartData, String>>[
                    PieSeries<ChartData, String>(
                      dataSource: getDepartmentDistribution(),
                      xValueMapper: (ChartData data, _) => data.type,
                      yValueMapper: (ChartData data, _) => data.amount,
                      pointColorMapper: (ChartData data, _) => Colors.primaries[
                          data.type.hashCode % Colors.primaries.length],
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ChartData> getTopPayingStaff() {
    return salaryData
        .map((record) => ChartData(record["Employee"], record["Amount"]))
        .toList();
  }

  List<ChartData> getMonthlyConsumption() {
    Map<String, double> monthlySalary = {};
    for (var record in salaryData) {
      monthlySalary[record["Month"]] =
          (monthlySalary[record["Month"]] ?? 0) + record["Amount"];
    }
    return monthlySalary.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();
  }

  List<ChartData> getDepartmentDistribution() {
    Map<String, double> departmentSalary = {};
    for (var record in salaryData) {
      departmentSalary[record["Department"]] =
          (departmentSalary[record["Department"]] ?? 0) + record["Amount"];
    }
    return departmentSalary.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();
  }
}

class ChartData {
  final String type;
  final double amount;
  ChartData(this.type, this.amount);
}
