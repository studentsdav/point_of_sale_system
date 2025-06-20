import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../backend/api_config.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final String baseUrl = '$apiBaseUrl/bill/reports';
  List<Map<String, dynamic>> reportData = [];
  String? selectedReport;

  final List<Map<String, String>> reports = [
    {"name": "Daily Sales Summary", "endpoint": "daily-sales"},
    {"name": "Hourly Sales Report", "endpoint": "hourly-sales"},
    {"name": "Item-Wise Sales Report", "endpoint": "item-wise-sales"},
    {"name": "Category-Wise Sales Report", "endpoint": "category-wise-sales"},
    {"name": "Payment Breakdown Report", "endpoint": "payment-breakdown"},
  ];

  Future<void> fetchReport(String endpoint) async {
    try {
      setState(() {
        reportData = [];
        selectedReport = endpoint;
      });

      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        if (decodedData is List) {
          setState(() {
            reportData = List<Map<String, dynamic>>.from(decodedData);
          });
        } else if (decodedData is Map<String, dynamic>) {
          // If API returns an object instead of a list, wrap it in a list
          setState(() {
            reportData = [decodedData];
          });
        } else {
          throw Exception("Unexpected response format");
        }
      } else {
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      debugPrint("Error fetching report: $e");
    }
  }

  Future<String> getDownloadPath() async {
    if (Platform.isAndroid) {
      return "/storage/emulated/0/Download";
    } else if (Platform.isWindows) {
      Directory? downloadsDir = await getDownloadsDirectory();
      return downloadsDir?.path ?? "C:\\Users\\Public\\Downloads";
    }
    return "";
  }

  void exportCSV() async {
    if (reportData.isEmpty) return;

    List<List<dynamic>> csvData = [
      reportData.first.keys.map((e) => e.replaceAll('_', ' ')).toList(),
      ...reportData.map((row) => row.values.toList())
    ];

    String csvString = const ListToCsvConverter().convert(csvData);
    String filePath = "${await getDownloadPath()}/report.csv";

    File file = File(filePath);
    await file.writeAsString(csvString);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report exported to: $filePath')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POS Reports'), centerTitle: true),
      body: Column(children: [
        // Dropdown for selecting the report
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(color: Colors.blueGrey[50]),
          child: DropdownButtonFormField(
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Select Report",
            ),
            items: reports
                .map((report) => DropdownMenuItem(
                      value: report["endpoint"],
                      child: Text(report["name"]!),
                    ))
                .toList(),
            onChanged: (value) => fetchReport(value as String),
          ),
        ),

        const SizedBox(height: 10),

        if (reportData.isNotEmpty)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scrollable Data Table (Fixing Overflow)
                  Container(
                    height: 200, // Ensures vertical scrolling
                    width: MediaQuery.sizeOf(context).width,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.white,
                    ),
                    child: ListView(
                      children: [
                        DataTable(
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columnSpacing: 20,
                          columns: reportData.first.keys.map((key) {
                            return DataColumn(
                              label: Text(
                                key.replaceAll('_', ' ').toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            );
                          }).toList(),
                          rows: reportData.map((row) {
                            return DataRow(
                              cells: row.values.map((value) {
                                return DataCell(Text(value.toString(),
                                    style: const TextStyle(fontSize: 14)));
                              }).toList(),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Total Row Styled as Table
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.grey.shade100,
                    ),
                    child: DataTable(
                      border: TableBorder.all(color: Colors.grey.shade300),
                      columnSpacing: 20,
                      columns: reportData.first.keys.map((key) {
                        return DataColumn(
                          label: Text(
                            key.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                      rows: [
                        DataRow(
                          cells: reportData.first.keys.map((key) {
                            try {
                              num total = reportData.fold(0, (sum, row) {
                                var value = row[key];
                                if (value is String) {
                                  value = num.tryParse(value) ?? 0;
                                }
                                return sum + (value is num ? value : 0);
                              });
                              return DataCell(
                                Center(
                                  child: Text(
                                    total.toStringAsFixed(2),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red),
                                  ),
                                ),
                              );
                            } catch (e) {
                              return const DataCell(Text("-"));
                            }
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        Expanded(
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(),
            title: ChartTitle(text: getChartTitle()), // Dynamic chart title
            legend: const Legend(isVisible: true),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries<dynamic, String>>[
              ColumnSeries<Map<String, dynamic>, String>(
                dataSource: reportData,
                xValueMapper: (data, _) =>
                    getXAxisValue(data), // Dynamic x-axis
                yValueMapper: (data, _) =>
                    getYAxisValue(data), // Dynamic y-axis
                name: getSeriesName(), // Dynamic legend
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ]),
    );
  }

  String getChartTitle() {
    if (selectedReport == "hourly-sales") return "Hourly Sales Report";
    if (selectedReport == "item-wise-sales") return "Item-Wise Sales Report";
    if (selectedReport == "category-wise-sales") return "Category-Wise Revenue";
    if (selectedReport == "payment-breakdown")
      return "Payment Method Breakdown";
    return "Sales Report";
  }

  String getXAxisValue(Map<String, dynamic> data) {
    if (data.containsKey("hour_range")) {
      return data["hour_range"]
          .toString(); // Updated: Hourly Sales in Range Format
    }
    if (data.containsKey("item_name")) return data["item_name"]; // Item Sales
    if (data.containsKey("item_category"))
      return data["item_category"]; // Category Sales
    if (data.containsKey("payment_method"))
      return data["payment_method"]; // Payment Breakdown
    return "";
  }

  double getYAxisValue(Map<String, dynamic> data) {
    if (data.containsKey("total_sales")) {
      return double.tryParse(data["total_sales"].toString()) ?? 0;
    }
    if (data.containsKey("total_revenue")) {
      return double.tryParse(data["total_revenue"].toString()) ?? 0;
    }
    if (data.containsKey("total_collected")) {
      return double.tryParse(data["total_collected"].toString()) ?? 0;
    }
    return 0;
  }

  String getSeriesName() {
    if (selectedReport == "hourly-sales") return "Total Sales";
    if (selectedReport == "item-wise-sales") return "Total Revenue";
    if (selectedReport == "category-wise-sales") return "Category Revenue";
    if (selectedReport == "payment-breakdown") return "Total Collected";
    return "Data";
  }
}
