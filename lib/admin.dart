import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:point_of_sale_system/ItemMaster.dart';
import 'package:point_of_sale_system/billconfig.dart';
import 'package:point_of_sale_system/category.dart';
import 'package:point_of_sale_system/dateconfig.dart';
import 'package:point_of_sale_system/forgot_password.dart';
import 'package:point_of_sale_system/guest_info.dart';
import 'package:point_of_sale_system/happyhour.dart';
import 'package:point_of_sale_system/inventory.dart';
import 'package:point_of_sale_system/kotconfig.dart';
import 'package:point_of_sale_system/outletconfig.dart';
import 'package:point_of_sale_system/printer.dart';
import 'package:point_of_sale_system/propertyinfo.dart';
import 'package:point_of_sale_system/reservation.dart';
import 'package:point_of_sale_system/servicecharge.dart';
import 'package:point_of_sale_system/tablemaster.dart';
import 'package:point_of_sale_system/taxconfig.dart';
import 'package:point_of_sale_system/usermaster.dart';
import 'package:point_of_sale_system/userpermission.dart';
import 'package:point_of_sale_system/waiters.dart';

enum ChartType { line, bar, pie }

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboard createState() => _AdminDashboard();
}

class _AdminDashboard extends State {
  String selectedOutlet = 'Restaurant';
  final List<String> outlets = ['BISTRO', 'SUNSET'];
  ChartType chartType = ChartType.line;

  @override
  void initState() {
    ;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_forward_ios))
        ],
      ),
      drawer: buildDrawer(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for floating button
        },
        child: Icon(Icons.add),
        tooltip: 'Add New Item',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: outlets.map((outlet) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: selectedOutlet == outlet
                                ? Colors.white
                                : Colors.black,
                            backgroundColor: selectedOutlet == outlet
                                ? Colors.green
                                : Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedOutlet = outlet;
                            });
                          },
                          child: Text(outlet),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                buildUserProfileSection(),
                SizedBox(height: 16),
                buildActiveTimeSection(),
                SizedBox(height: 16),
                buildSalesCards(),
                SizedBox(height: 16),
                buildTopCategorySales(),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  child: buildChartTypeSelection(),
                ),
                buildGrowthSection('Daily Sales Growth',
                    generateDailySalesData(7), 'Day'), // Added Daily Graph
                SizedBox(height: 16),
                buildGrowthSection('Weekly Sales Growth',
                    generateWeeklySalesData(4), 'Week'), // Added Weekly Graph
                SizedBox(height: 16),
                // Chart type selection

                buildGrowthSection(
                    'Monthly Sales Growth',
                    generateMonthlySalesData(6),
                    'Month'), // Added Monthly Graph
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildChartTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Chart Type:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
          child: Row(
            children: [
              Radio<ChartType>(
                value: ChartType.line,
                groupValue: chartType,
                onChanged: (ChartType? value) {
                  setState(() {
                    chartType = value!;
                  });
                },
              ),
              Text('Line Chart'),
              Radio<ChartType>(
                value: ChartType.bar,
                groupValue: chartType,
                onChanged: (ChartType? value) {
                  setState(() {
                    chartType = value!;
                  });
                },
              ),
              Text('Bar Chart'),
              Radio<ChartType>(
                value: ChartType.pie,
                groupValue: chartType,
                onChanged: (ChartType? value) {
                  setState(() {
                    chartType = value!;
                  });
                },
              ),
              Text('Pie Chart'),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Admin Name'),
            accountEmail: Text('admin@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Colors.blue),
            ),
          ),
          buildDrawerItem(Icons.settings_applications, 'Property Config'),
          buildDrawerItem(Icons.add_box, 'Add Module'),
          buildDrawerItem(Icons.table_rows, 'Table Master'),
          buildDrawerItem(Icons.person_add, 'User Master'),
          buildDrawerItem(Icons.perm_identity_sharp, 'User Permission'),
          buildDrawerItem(Icons.receipt, 'Bill Config'),
          buildDrawerItem(Icons.layers, 'Item Master'),
          buildDrawerItem(Icons.person_pin, 'Waiter Master'),
          buildDrawerItem(Icons.info, 'Guest Info Add'),
          buildDrawerItem(Icons.book, 'Reservation'),
          buildDrawerItem(Icons.fastfood, 'KOT Config'),
          buildDrawerItem(Icons.calendar_today, 'Date Config'),
          buildDrawerItem(Icons.print, 'Printer Config'),
          buildDrawerItem(Icons.toll, 'Tax Config'),
          buildDrawerItem(Icons.local_offer, 'Service Charge Config'),
          buildDrawerItem(Icons.access_alarm, 'Happy Hour Config'),
          buildDrawerItem(Icons.inventory, 'Inventory'),
          buildDrawerItem(Icons.lock, 'Password Reset'),
          buildDrawerItem(Icons.settings, 'Settings'),
          buildDrawerItem(Icons.exit_to_app, 'Logout'),
        ],
      ),
    );
  }

  Widget buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (title == 'Table Master') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => TableManagementPage()));
        } else if (title == 'Bill Config') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => BillConfigurationForm()));
        } else if (title == 'Category') {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => CategoryForm()));
        } else if (title == 'Date Config') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SoftwareDateConfigForm()));
        } else if (title == 'Password Reset') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
        } else if (title == 'Happy Hour Config') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HappyHourConfigForm()));
        } else if (title == 'Inventory') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => StockEntryForm()));
        } else if (title == 'Item Master') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ItemMasterScreen()));
        } else if (title == 'KOT Config') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => KOTConfigForm()));
        } else if (title == 'Add Module') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OutletConfigurationForm()));
        } else if (title == 'Printer Config') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PrinterConfigForm()));
        } else if (title == 'Property Config') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PropertyConfigurationForm()));
        } else if (title == 'Reservation') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ReservationFormScreen()));
        } else if (title == 'Service Charge Config') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ServiceChargeConfigForm()));
        } else if (title == 'Tax Config') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => TaxConfigForm()));
        } else if (title == 'User Master') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => UserProfilePage()));
        } else if (title == 'User Permission') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => UserPermissionForm()));
        } else if (title == 'Waiter Master') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WaiterConfigurationForm()));
        } else if (title == 'Guest Info Add') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GuestRegistrationScreen()));
        } else if (title == 'Reservation') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ReservationFormScreen()));
        }
      },
    );
  }

  Widget buildUserProfileSection() {
    return Card(
      elevation: 0,
      color: Colors.blueAccent.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin Profile',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Active: 2 hours ago', style: TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActiveTimeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active Time Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Table(
            columnWidths: {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
            },
            children: [
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('User',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Active Time'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Admin'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('2 hours ago'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSalesCards() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: buildSalesCard('Today\'s Sale', Icons.today, '₹ 12,000',
                    Colors.green, '15%')),
            SizedBox(width: 16),
            Expanded(
                child: buildSalesCard('Weekly Sale', Icons.date_range,
                    '₹ 50,000', Colors.blue, '10%')),
            SizedBox(width: 16),
            Expanded(
                child: buildSalesCard('Monthly Sale', Icons.calendar_today,
                    '₹ 1,20,000', Colors.orange, '8%')),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: buildSalesCard('Yearly Sale', Icons.assessment,
                    '₹ 5,00,000', Colors.teal, '20%')),
            SizedBox(width: 16),
            Expanded(
                child: buildSalesCard(
                    'YoY Growth', Icons.trending_up, '15%', Colors.red, '10%')),
            SizedBox(width: 16),
            Expanded(
                child: buildSalesCard('Top 5 Categories', Icons.category,
                    'Electronics, Groceries, etc.', Colors.teal, '')),
          ],
        ),
      ],
    );
  }

  Widget buildSalesCard(String title, IconData icon, String value, Color color,
      String growthPercentage) {
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
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 14)),
              if (growthPercentage.isNotEmpty) SizedBox(height: 4),
              Text('Growth: $growthPercentage',
                  style: TextStyle(fontSize: 12, color: Colors.black45)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTopCategorySales() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Category Sales for This Month',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Category $index'),
                subtitle: Text('Sales: ₹ 25,000'),
                trailing: Icon(Icons.trending_up),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildGrowthSection(String title, List<FlSpot> data, String period) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          height: 250,
          child: AnimatedSwitcher(
            duration: Duration(seconds: 1),
            child: _buildChart(
                data, period), // Pass data to the respective chart renderer
          ),
        ),
      ],
    );
  }

  Widget _buildChart(List<FlSpot> data, String period) {
    switch (chartType) {
      case ChartType.line:
        return LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: true)),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: data,
                isCurved: true,
                color: Colors.blue,
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        );
      case ChartType.bar:
        return BarChart(
          BarChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
            ),
            borderData: FlBorderData(show: true),
            barGroups: data.map((spot) {
              return BarChartGroupData(
                x: spot.x.toInt(),
                barRods: [
                  BarChartRodData(
                    toY: spot.y,
                    color: Colors.blue,
                    width: 16,
                  ),
                ],
              );
            }).toList(),
          ),
        );
      case ChartType.pie:
        return PieChart(
          PieChartData(
            sections: data.map((spot) {
              return PieChartSectionData(
                value: spot.y,
                color: Colors.blue,
                title: '${spot.y.toStringAsFixed(0)}',
              );
            }).toList(),
          ),
        );
      default:
        return Container();
    }
  }

  List<FlSpot> generateDailySalesData(int count) {
    List<FlSpot> data = [];
    double value = 1000; // Starting value
    for (int i = 0; i < count; i++) {
      value += Random().nextBool()
          ? Random().nextInt(500).toDouble()
          : -Random().nextInt(500).toDouble();
      value = value < 0 ? 0 : value;
      data.add(FlSpot(i.toDouble(), value)); // Each point corresponds to a day
    }
    return data;
  }

  List<FlSpot> generateWeeklySalesData(int count) {
    List<FlSpot> data = [];
    double value = 5000; // Starting value
    for (int i = 0; i < count; i++) {
      value += Random().nextBool()
          ? Random().nextInt(1000).toDouble()
          : -Random().nextInt(1000).toDouble();
      value = value < 0 ? 0 : value;
      data.add(FlSpot(i.toDouble(), value)); // Each point corresponds to a week
    }
    return data;
  }

  List<FlSpot> generateMonthlySalesData(int count) {
    List<FlSpot> data = [];
    double value = 20000; // Starting value
    for (int i = 0; i < count; i++) {
      value += Random().nextBool()
          ? Random().nextInt(5000).toDouble()
          : -Random().nextInt(5000).toDouble();
      value = value < 0 ? 0 : value;
      data.add(
          FlSpot(i.toDouble(), value)); // Each point corresponds to a month
    }
    return data;
  }
}
