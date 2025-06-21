import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../backend/loyalty/loyalty_api_service.dart';
import '../../backend/api_config.dart';

class AppliedDiscountReport extends StatefulWidget {
  const AppliedDiscountReport({super.key});

  @override
  _AppliedDiscountReportState createState() => _AppliedDiscountReportState();
}

class _AppliedDiscountReportState extends State<AppliedDiscountReport> {
  List<DiscountData> discountData = [
    DiscountData("Mar 10", 200),
    DiscountData("Mar 11", 350),
    DiscountData("Mar 12", 500),
    DiscountData("Mar 13", 150),
  ];

  List<Map<String, dynamic>> discountRecords = [
    {
      "date": "Mar 10",
      "guest": "John Doe",
      "amount": 200,
      "promo": "WELCOME10"
    },
    {
      "date": "Mar 11",
      "guest": "Jane Smith",
      "amount": 350,
      "promo": "FESTIVE20"
    },
    {
      "date": "Mar 12",
      "guest": "Mike Johnson",
      "amount": 500,
      "promo": "NEWYEAR50"
    },
    {
      "date": "Mar 13",
      "guest": "Emily Davis",
      "amount": 150,
      "promo": "SPRING15"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Applied Discount Report")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Discount Records",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("Date")),
                    DataColumn(label: Text("Guest")),
                    DataColumn(label: Text("Amount")),
                    DataColumn(label: Text("Promo Code")),
                  ],
                  rows: discountRecords.map((record) {
                    return DataRow(cells: [
                      DataCell(Text(record["date"])),
                      DataCell(Text(record["guest"])),
                      DataCell(Text("₹${record["amount"]}")),
                      DataCell(Text(record["promo"])),
                    ]);
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Discounts Over Time",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              flex: 1,
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(),
                title: const ChartTitle(text: 'Discounts Over Time'),
                series: <CartesianSeries<DiscountData, String>>[
                  ColumnSeries<DiscountData, String>(
                    dataSource: discountData,
                    xValueMapper: (DiscountData data, _) => data.date,
                    yValueMapper: (DiscountData data, _) => data.amount,
                    color: Colors.blue,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiscountData {
  final String date;
  final int amount;
  DiscountData(this.date, this.amount);
}
