import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  _AttendanceReportScreenState createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  String filter = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Report')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: filter,
              onChanged: (String? newValue) {
                setState(() {
                  filter = newValue!;
                });
              },
              items: ['All', 'Present', 'Absent', 'Leave', 'Late']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Employee Name')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Shift')),
                  DataColumn(label: Text('Entry Time')),
                  DataColumn(label: Text('Exit Time')),
                  DataColumn(label: Text('Working Hours')),
                  DataColumn(label: Text('Overtime')),
                  DataColumn(label: Text('Under Time')),
                ],
                rows: getFilteredEmployeeData().map((employee) {
                  return DataRow(cells: [
                    DataCell(Text(employee.name)),
                    DataCell(Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: getStatusColor(employee.status),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(employee.status,
                          style: const TextStyle(color: Colors.white)),
                    )),
                    DataCell(Text(employee.shift)),
                    DataCell(Text(employee.entryTime)),
                    DataCell(Text(employee.exitTime)),
                    DataCell(Text(employee.workingHours.toString())),
                    DataCell(Text(employee.overtimeHours.toString())),
                    DataCell(Text(employee.underTimeHours.toString())),
                  ]);
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 400,
              child: SfCircularChart(
                title: const ChartTitle(text: 'Attendance Breakdown'),
                legend: const Legend(
                    isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
                series: <CircularSeries<ChartData, String>>[
                  PieSeries<ChartData, String>(
                    dataSource: getAttendanceData(),
                    xValueMapper: (ChartData data, _) => data.label,
                    yValueMapper: (ChartData data, _) => data.value,
                    dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside,
                        showZeroValue: false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: const DateTimeAxis(),
                title: const ChartTitle(text: 'Date-wise Attendance Trend'),
                legend: const Legend(isVisible: true),
                series: <CartesianSeries<dynamic, dynamic>>[
                  ColumnSeries<AttendanceTrendData, DateTime>(
                    dataSource: getAttendanceTrendData(),
                    xValueMapper: (AttendanceTrendData data, _) => data.date,
                    yValueMapper: (AttendanceTrendData data, _) => data.present,
                    name: 'Present',
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                  ColumnSeries<AttendanceTrendData, DateTime>(
                    dataSource: getAttendanceTrendData(),
                    xValueMapper: (AttendanceTrendData data, _) => data.date,
                    yValueMapper: (AttendanceTrendData data, _) => data.absent,
                    name: 'Absent',
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SfCartesianChart(
              title: const ChartTitle(text: 'Overtime & Late Summary'),
              primaryXAxis: const CategoryAxis(),
              primaryYAxis: const NumericAxis(),
              legend: const Legend(isVisible: true),
              series: <CartesianSeries<dynamic, dynamic>>[
                ColumnSeries<ChartData, String>(
                  dataSource: getOvertimeData(),
                  xValueMapper: (ChartData data, _) => data.label,
                  yValueMapper: (ChartData data, _) => data.value,
                  name: 'Overtime Hours',
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
                ColumnSeries<ChartData, String>(
                  dataSource: getLateData(),
                  xValueMapper: (ChartData data, _) => data.label,
                  yValueMapper: (ChartData data, _) => data.value,
                  name: 'Late Employees',
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<ChartData> getAttendanceData() {
    return [
      ChartData('Present', 70),
      ChartData('Absent', 10),
      ChartData('Leave', 15),
      ChartData('Late', 5),
    ];
  }

  List<ChartData> getOvertimeData() {
    return [
      ChartData('Overtime', 30),
    ];
  }

  List<ChartData> getLateData() {
    return [
      ChartData('Late', 10),
    ];
  }

  List<EmployeeData> getFilteredEmployeeData() {
    List<EmployeeData> data = [
      EmployeeData('John Doe', 'Present', 'Day Shift', '08:30 AM', '05:00 PM',
          8.5, 0.5, 0.0),
      EmployeeData('Jane Smith', 'Absent', 'Night Shift', '', '', 0, 0, 8.0),
      EmployeeData('Alice Johnson', 'Leave', 'Day Shift', '', '', 0, 0, 8.0),
      EmployeeData('Bob Brown', 'Late', 'Night Shift', '09:30 AM', '06:00 PM',
          7.5, 0, 0.5),
    ];
    if (filter == 'All') return data;
    return data.where((emp) => emp.status == filter).toList();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Absent':
        return Colors.red;
      case 'Leave':
        return Colors.orange;
      case 'Late':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class ChartData {
  final String label;
  final double value;
  ChartData(this.label, this.value);
}

class AttendanceTrendData {
  final DateTime date;
  final double present;
  final double absent;
  AttendanceTrendData(this.date, this.present, this.absent);
}

List<AttendanceTrendData> getAttendanceTrendData() {
  return [
    AttendanceTrendData(DateTime(2025, 3, 10), 50, 10),
    AttendanceTrendData(DateTime(2025, 3, 11), 55, 8),
    AttendanceTrendData(DateTime(2025, 3, 12), 60, 5),
    AttendanceTrendData(DateTime(2025, 3, 13), 65, 4),
  ];
}

class EmployeeData {
  final String name;
  final String status;
  final String shift;
  final String entryTime;
  final String exitTime;
  final double workingHours;
  final double overtimeHours;
  final double underTimeHours;
  EmployeeData(
      this.name,
      this.status,
      this.shift,
      this.entryTime,
      this.exitTime,
      this.workingHours,
      this.overtimeHours,
      this.underTimeHours);
}
