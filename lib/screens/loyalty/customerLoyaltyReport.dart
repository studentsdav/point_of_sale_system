import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../backend/api_config.dart';
import '../../backend/loyalty/loyalty_api_service.dart';

class CustomerLoyaltyReport extends StatefulWidget {
  const CustomerLoyaltyReport({super.key});

  @override
  State<CustomerLoyaltyReport> createState() => _CustomerLoyaltyReportState();
}

class _CustomerLoyaltyReportState extends State<CustomerLoyaltyReport> {
  final LoyaltyApiService _apiService =
      LoyaltyApiService(baseUrl: '$apiBaseUrl/loyalty');

  List<LoyaltyData> records = [];

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    try {
      final data = await _apiService.fetchAllLoyaltyRecords();
      setState(() {
        records = data
            .map<LoyaltyData>((d) => LoyaltyData(
                  d['guest_name'] ?? '',
                  d['program_name'] ?? '',
                  d['points'] ?? 0,
                  d['expiry_date'] ?? '',
                  false,
                  Colors.blue,
                ))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching loyalty data: $e')),
      );
    }
  }

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
                rows: records
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
                    dataSource: records,
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
