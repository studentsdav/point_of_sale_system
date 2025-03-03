import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final String baseUrl = 'http://localhost:3000/api/bill/reports';
  Map<String, dynamic>? reportData;
  String? selectedReport;

  // List of Reports
  final List<Map<String, String>> reports = [
    {"name": "Daily Sales Summary", "endpoint": "daily-sales"},
    {"name": "Hourly Sales Report", "endpoint": "hourly-sales"},
    {"name": "Item-Wise Sales Report", "endpoint": "item-wise-sales"},
    {"name": "Category-Wise Sales Report", "endpoint": "category-wise-sales"},
    {"name": "Payment Breakdown Report", "endpoint": "payment-breakdown"},
  ];

  // Fetch Report Data
  Future<void> fetchReport(String endpoint) async {
    try {
      setState(() {
        reportData = null;
        selectedReport = endpoint;
      });

      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        // Handle List & Map properly
        setState(() {
          if (decodedData is Map<String, dynamic>) {
            reportData = decodedData; // Store Map data
          } else if (decodedData is List) {
            reportData = {"data": decodedData}; // Wrap List in a Map
          } else {
            throw Exception("Unexpected response format");
          }
        });
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

  // Get the proper directory based on platform
  Future<String> getDownloadPath() async {
    if (Platform.isAndroid) {
      return "/storage/emulated/0/Download";
    } else if (Platform.isWindows) {
      Directory? downloadsDir = await getDownloadsDirectory();
      return downloadsDir?.path ?? "C:\\Users\\Public\\Downloads";
    }
    return "";
  }

  // Export Report as CSV
  void exportCSV() async {
    if (reportData == null) return;

    List<List<dynamic>> csvData = [
      reportData!.keys.toList(), // Headers
      reportData!.values.toList() // Values
    ];

    String csvString = const ListToCsvConverter().convert(csvData);
    String filePath = "${await getDownloadPath()}/report.csv";

    File file = File(filePath);
    await file.writeAsString(csvString);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report exported to: $filePath')),
    );
  }

  // Print Report
  void printReport() async {
    // await Printing.layoutPdf(
    //   onLayout: (PdfPageFormat format) async {
    //     final Uint8List data =
    //         utf8.encode(jsonEncode(reportData!)) as Uint8List;
    //     return data;
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POS Reports')),
      body: Column(
        children: [
          // Report List
          Expanded(
            child: ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(reports[index]["name"]!),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => fetchReport(reports[index]["endpoint"]!),
                );
              },
            ),
          ),

          // Report Data View
          // Display report data
          if (reportData != null) ...[
            const Divider(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        selectedReport!,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (reportData!["data"] != null) // Handle List case
                        Column(
                          children: (reportData!["data"] as List)
                              .map((item) => ListTile(
                                    title: Text(item.toString()),
                                  ))
                              .toList(),
                        )
                      else // Handle Map case
                        ...reportData!.entries.map(
                          (entry) => ListTile(
                            title: Text(entry.key),
                            subtitle: Text(entry.value.toString()),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
