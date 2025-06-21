import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../backend/payroll/salary_service.dart';

class SalaryReportScreen extends StatefulWidget {
  const SalaryReportScreen({super.key});

  @override
  _SalaryReportScreenState createState() => _SalaryReportScreenState();
}

class _SalaryReportScreenState extends State<SalaryReportScreen> {
  List<dynamic> salaryData = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSalaries();
  }

  Future<void> _fetchSalaries() async {
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
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!))
                        : DataTable(
                            columns: const [
                              DataColumn(label: Text('Employee')),
                              DataColumn(label: Text('Department')),
                              DataColumn(label: Text('Salary')),
                              DataColumn(label: Text('Month')),
                            ],
                            rows: salaryData.map((record) {
                              return DataRow(cells: [
                                DataCell(Text(record['employee_id'].toString())),
                                DataCell(Text(record['department'] ?? '')),
                                DataCell(Text(record['base_salary'].toString())),
                                DataCell(Text(record['salary_month'] ?? '')),
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
        .map((record) =>
            ChartData(record['employee_id'].toString(), (record['base_salary'] as num).toDouble()))
        .toList();
  }

  List<ChartData> getMonthlyConsumption() {
    Map<String, double> monthlySalary = {};
    for (var record in salaryData) {
      monthlySalary[record['salary_month']] =
          (monthlySalary[record['salary_month']] ?? 0) +
              (record['base_salary'] as num).toDouble();
    }
    return monthlySalary.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();
  }

  List<ChartData> getDepartmentDistribution() {
    Map<String, double> departmentSalary = {};
    for (var record in salaryData) {
      departmentSalary[record['department'] ?? 'Unknown'] =
          (departmentSalary[record['department'] ?? 'Unknown'] ?? 0) +
              (record['base_salary'] as num).toDouble();
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
