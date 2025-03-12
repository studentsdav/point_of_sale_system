import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class VendorPaymentReportScreen extends StatefulWidget {
  const VendorPaymentReportScreen({super.key});

  @override
  _VendorPaymentReportScreenState createState() =>
      _VendorPaymentReportScreenState();
}

class _VendorPaymentReportScreenState extends State<VendorPaymentReportScreen> {
  List<Map<String, dynamic>> payments = [
    {'Vendor': 'Vendor A', 'Amount Paid': 5000, 'Due Amount': 2000},
    {'Vendor': 'Vendor B', 'Amount Paid': 3000, 'Due Amount': 1000},
    {'Vendor': 'Vendor C', 'Amount Paid': 7000, 'Due Amount': 500},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Payments Report')),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Payment Details',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView(
                          children: payments.map((payment) {
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 3,
                              child: ListTile(
                                title: Text(payment['Vendor']),
                                subtitle: Text(
                                    "Paid: ₹${payment['Amount Paid']} | Due: ₹${payment['Due Amount']}",
                                    style: TextStyle(
                                        color: payment['Due Amount'] > 0
                                            ? Colors.red
                                            : Colors.green)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SfCircularChart(
                title: const ChartTitle(text: 'Payment Distribution'),
                legend: const Legend(
                    isVisible: true, position: LegendPosition.bottom),
                series: <CircularSeries>[
                  PieSeries<Map<String, dynamic>, String>(
                    dataSource: payments,
                    xValueMapper: (data, _) => data['Vendor'],
                    yValueMapper: (data, _) => data['Amount Paid'],
                    dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
