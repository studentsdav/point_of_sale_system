import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LoyaltyTransactionsReport extends StatefulWidget {
  const LoyaltyTransactionsReport({super.key});

  @override
  _LoyaltyTransactionsReportState createState() =>
      _LoyaltyTransactionsReportState();
}

class _LoyaltyTransactionsReportState extends State<LoyaltyTransactionsReport> {
  List<LoyaltyTransaction> transactions = [
    LoyaltyTransaction(
        "John Doe", "Gold Program", 200, 50, "earn", "Cash", "Store A"),
    LoyaltyTransaction(
        "Alice Smith", "Silver Program", 100, 20, "redeem", "UPI", "Store B"),
    LoyaltyTransaction(
        "Bob Williams", "Gold Program", 300, 100, "earn", "Card", "Store C"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Loyalty Transactions Report")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Guest Name')),
                  DataColumn(label: Text('Program')),
                  DataColumn(label: Text('Earned')),
                  DataColumn(label: Text('Redeemed')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Payment')),
                  DataColumn(label: Text('Store')),
                ],
                rows: transactions
                    .map(
                      (t) => DataRow(
                        cells: [
                          DataCell(Text(t.guestName)),
                          DataCell(Text(t.program)),
                          DataCell(Text(t.pointsEarned.toString())),
                          DataCell(Text(t.pointsRedeemed.toString())),
                          DataCell(Text(t.transactionType)),
                          DataCell(Text(t.paymentMethod)),
                          DataCell(Text(t.store)),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(),
              title: const ChartTitle(text: 'Loyalty Points Summary'),
              series: <CartesianSeries<LoyaltyTransaction, String>>[
                ColumnSeries<LoyaltyTransaction, String>(
                  dataSource: transactions,
                  xValueMapper: (data, _) => data.guestName,
                  yValueMapper: (data, _) => data.pointsEarned,
                  name: 'Points Earned',
                  color: Colors.green,
                ),
                ColumnSeries<LoyaltyTransaction, String>(
                  dataSource: transactions,
                  xValueMapper: (data, _) => data.guestName,
                  yValueMapper: (data, _) => data.pointsRedeemed,
                  name: 'Points Redeemed',
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoyaltyTransaction {
  final String guestName;
  final String program;
  final int pointsEarned;
  final int pointsRedeemed;
  final String transactionType;
  final String paymentMethod;
  final String store;

  LoyaltyTransaction(
      this.guestName,
      this.program,
      this.pointsEarned,
      this.pointsRedeemed,
      this.transactionType,
      this.paymentMethod,
      this.store);
}
