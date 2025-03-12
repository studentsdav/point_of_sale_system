import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CustomerLoyaltyReport extends StatelessWidget {
  const CustomerLoyaltyReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customer Loyalty Report")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Loyalty Program Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Guest Name")),
                  DataColumn(label: Text("Program")),
                  DataColumn(label: Text("Total Points")),
                  DataColumn(label: Text("Expiry Date")),
                ],
                rows: getLoyaltyData()
                    .map(
                      (data) => DataRow(
                        color:
                            WidgetStateProperty.resolveWith<Color?>((states) {
                          if (data.isExpiringSoon) {
                            return Colors.red.withOpacity(0.3);
                          }
                          return null;
                        }),
                        cells: [
                          DataCell(Text(data.guestName)),
                          DataCell(Text(data.programName)),
                          DataCell(Text(data.totalPoints.toString())),
                          DataCell(Text(data.expiryDate)),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Loyalty Points Overview",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(),
                title: const ChartTitle(text: 'Loyalty Points Distribution'),
                legend: const Legend(isVisible: true),
                series: <CartesianSeries<LoyaltyData, String>>[
                  ColumnSeries<LoyaltyData, String>(
                    dataSource: getLoyaltyData(),
                    xValueMapper: (data, _) => data.guestName,
                    yValueMapper: (data, _) => data.totalPoints,
                    pointColorMapper: (data, _) => data.color,
                    name: "Loyalty Points",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<LoyaltyData> getLoyaltyData() {
    return [
      LoyaltyData("John Doe", "Gold", 1200, "2025-03-12", false, Colors.blue),
      LoyaltyData(
          "Jane Smith", "Silver", 800, "2025-02-10", true, Colors.orange),
      LoyaltyData(
          "Mark Taylor", "Platinum", 2000, "2026-01-15", false, Colors.green),
    ];
  }
}

class LoyaltyData {
  final String guestName;
  final String programName;
  final int totalPoints;
  final String expiryDate;
  final bool isExpiringSoon;
  final Color color;

  LoyaltyData(this.guestName, this.programName, this.totalPoints,
      this.expiryDate, this.isExpiringSoon, this.color);
}
