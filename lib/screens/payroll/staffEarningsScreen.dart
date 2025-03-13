import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StaffEarningsScreen extends StatefulWidget {
  const StaffEarningsScreen({super.key});

  @override
  _StaffEarningsScreenState createState() => _StaffEarningsScreenState();
}

class _StaffEarningsScreenState extends State<StaffEarningsScreen> {
  final List<Map<String, dynamic>> earningsData = [
    {
      "Employee": "John Doe",
      "Type": "Tip",
      "Amount": 500.00,
      "Order ID": "101"
    },
    {
      "Employee": "Jane Smith",
      "Type": "Commission",
      "Amount": 1200.00,
      "Order ID": "102"
    },
    {
      "Employee": "Bob Johnson",
      "Type": "Tip",
      "Amount": 750.00,
      "Order ID": "103"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Earnings Report')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Earnings Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Employee')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Order ID')),
                ],
                rows: earningsData.map((record) {
                  return DataRow(cells: [
                    DataCell(Text(record["Employee"]!)),
                    DataCell(Text(record["Type"]!)),
                    DataCell(Text(record["Amount"].toString())),
                    DataCell(Text(record["Order ID"]!)),
                  ]);
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Earnings Breakdown',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(),
                title: const ChartTitle(text: 'Earnings Report by Type'),
                legend: const Legend(isVisible: true),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<ChartData, String>>[
                  ColumnSeries<ChartData, String>(
                    dataSource: getChartData(),
                    xValueMapper: (ChartData data, _) => data.type,
                    yValueMapper: (ChartData data, _) => data.amount,
                    name: 'Earnings',
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ChartData> getChartData() {
    Map<String, double> earningsMap = {};
    for (var record in earningsData) {
      earningsMap[record["Type"]] =
          (earningsMap[record["Type"]] ?? 0) + record["Amount"];
    }
    return earningsMap.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();
  }
}

class ChartData {
  final String type;
  final double amount;
  ChartData(this.type, this.amount);
}
