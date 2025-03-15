import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'attendanceEntryScreen.dart';
import 'attendanceReportScreen.dart';
import 'attendanceReportScreenemployee.dart';
import 'employeeBenefitsScreen.dart';
import 'employeeEntryScreen.dart';
import 'salaryAdvanceScreen.dart';
import 'salaryReportScreen.dart';
import 'salarySummaryScreen.dart';
import 'staffEarningsScreen.dart';

class PayrollDashboard extends StatefulWidget {
  const PayrollDashboard({super.key});

  @override
  _PayrollDashboardState createState() => _PayrollDashboardState();
}

class _PayrollDashboardState extends State<PayrollDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AttendanceEntryScreen(),
    const AttendanceReportScreen(),
    const AttendanceReportEmployee(),
    const EmployeeBenefitsScreen(),
    const EmployeeEntryScreen(),
    const SalaryAdvanceScreen(),
    const SalaryReportScreen(),
    const StaffEarningsScreen(),
    const SalarySummaryScreen()
  ];

  final List<String> _titles = [
    "Dashboard",
    "Attendance Entry",
    "Attendance Report",
    "Employee Attendance Report",
    "Employee Benefits",
    "Employee Entry",
    "Salary Advance",
    "Salary Report",
    "Staff Earnings",
    "Salary Summery",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex],
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_forward_ios))
        ],
      ),
      body: _selectedIndex == 0
          ? const DashboardScreen()
          : _screens[_selectedIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Text(
                'Payroll System',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...List.generate(_titles.length, (index) {
              return ListTile(
                title: Text(_titles[index]),
                onTap: () => _onItemTapped(index),
              );
            })
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: buildDashboardCard(
                      'Total Employees', Icons.group, '100', Colors.blue)),
              const SizedBox(width: 16),
              Expanded(
                  child: buildDashboardCard(
                      'Present', Icons.check_circle, '80', Colors.green)),
              const SizedBox(width: 16),
              Expanded(
                  child: buildDashboardCard(
                      'Absent', Icons.cancel, '15', Colors.red)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: buildDashboardCard(
                      'Late', Icons.timer, '5', Colors.orange)),
              const SizedBox(width: 16),
              Expanded(
                  child: buildDashboardCard(
                      'On Leave', Icons.beach_access, '10', Colors.purple)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: buildDashboardCard(
                      'Day Shift', Icons.wb_sunny, '60', Colors.cyan)),
              const SizedBox(width: 16),
              Expanded(
                  child: buildDashboardCard('Night Shift',
                      Icons.nightlight_round, '20', Colors.indigo)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: buildDashboardCard('Overtime Hours',
                      Icons.access_alarm, '50 hrs', Colors.teal)),
              const SizedBox(width: 16),
              Expanded(
                  child: buildDashboardCard('Underworked Hours',
                      Icons.hourglass_empty, '30 hrs', Colors.brown)),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(),
              title: const ChartTitle(text: 'Attendance Percentage (Day Wise)'),
              legend: const Legend(isVisible: true),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ColumnSeries<dynamic, dynamic>>[
                ColumnSeries<_AttendanceData, String>(
                  dataSource: getChartData(),
                  xValueMapper: (_AttendanceData data, _) => data.day,
                  yValueMapper: (_AttendanceData data, _) => data.percentage,
                  name: 'Attendance %',
                  color: Colors.blue,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDashboardCard(
      String title, IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  List<_AttendanceData> getChartData() {
    return [
      _AttendanceData('Mon', 80),
      _AttendanceData('Tue', 85),
      _AttendanceData('Wed', 78),
      _AttendanceData('Thu', 90),
      _AttendanceData('Fri', 88),
      _AttendanceData('Sat', 70),
    ];
  }
}

class _AttendanceData {
  final String day;
  final double percentage;
  _AttendanceData(this.day, this.percentage);
}
