import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../backend/api_config.dart';
import '../../backend/payroll/earning_service.dart';

class StaffEarningsScreen extends StatefulWidget {
  const StaffEarningsScreen({super.key});

  @override
  _StaffEarningsScreenState createState() => _StaffEarningsScreenState();
}

class _StaffEarningsScreenState extends State<StaffEarningsScreen> {
  final EarningService _earningService = EarningService();
  List<dynamic> earningsData = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchEarnings();
  }

  Future<void> _fetchEarnings() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final data = await _earningService.getAllEarnings();
    setState(() {
      earningsData = data ?? [];
      _loading = false;
    });
  }

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
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : DataTable(
                          columns: const [
                            DataColumn(label: Text('Employee')),
                            DataColumn(label: Text('Type')),
                            DataColumn(label: Text('Amount')),
                            DataColumn(label: Text('Order ID')),
                          ],
                          rows: earningsData.map((record) {
                            return DataRow(cells: [
                              DataCell(Text('${record['employee_id']}')),
                              DataCell(Text(record['earning_type'] ?? '')),
                              DataCell(Text(record['amount'].toString())),
                              DataCell(Text(record['order_id'].toString())),
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
      earningsMap[record['earning_type']] =
          (earningsMap[record['earning_type']] ?? 0) +
              (record['amount'] as num).toDouble();
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
