import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:point_of_sale_system/screens/payroll/payrollDashboard.dart';

import '../../backend/billing/bill_service.dart';
import '../billing/billconfig.dart';
import '../billing/guest_info.dart';
import '../expense/expenseDashboard.dart';
import '../inventory/inventoryDashboard.dart';
import '../loyalty/loyaltyProgramDashboard.dart';
import '../orders/waiters.dart';
import '../rservation/reservation.dart';
import '../settings/ItemManage.dart';
import '../settings/category.dart';
import '../settings/dateconfig.dart';
import '../settings/deliveryCharge.dart';
import '../settings/discountConfig.dart';
import '../settings/forgot_password.dart';
import '../settings/happyhour.dart';
import '../settings/kotconfig.dart';
import '../settings/outletconfig.dart';
import '../settings/packingCharge.dart';
import '../settings/platformfe.dart';
import '../settings/printer.dart';
import '../settings/propertyinfo.dart';
import '../settings/servicecharge.dart';
import '../settings/tablemaster.dart';
import '../settings/taxconfig.dart';
import '../settings/usermaster.dart';
import '../settings/userpermission.dart';

enum ChartType { line, bar, pie }

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboard createState() => _AdminDashboard();
}

class _AdminDashboard extends State {
  String selectedOutlet = 'Restaurant';
  final List<String> outlets = ['Outlet1', 'Outlet2'];
  ChartType chartType = ChartType.line;
  final BillingApiService billingApiService = BillingApiService();
  String today_growth = "0";
  String today_sales = "0";
  String this_week_sales = "0";
  String weekly_growth = "0";
  String this_month_sales = "0";
  String monthly_growth = "0";
  String this_year_sales = "0";
  String yearly_growth = "0";
  List categoriesData = [
    {"item_category": "Electronics", "total_sales": 500000},
  ];
  @override
  void initState() {
    super.initState();
    getTodayStatus();
  }

  Future<void> getTodayStatus() async {
    final todayDashboard = await billingApiService.getAdminDashboardStatus();

    today_sales = todayDashboard['sales']['today_sales'].toString();
    today_growth = todayDashboard['sales']['today_growth'].toString();
    this_week_sales = todayDashboard['sales']['this_week_sales'].toString();
    weekly_growth = todayDashboard['sales']['weekly_growth'].toString();
    this_month_sales = todayDashboard['sales']['this_month_sales'].toString();
    monthly_growth = todayDashboard['sales']['monthly_growth'].toString();
    this_year_sales = todayDashboard['sales']['this_year_sales'].toString();
    yearly_growth = todayDashboard['sales']['yearly_growth'].toString();
    categoriesData = todayDashboard['top_categories'];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_forward_ios))
        ],
      ),
      drawer: buildDrawer(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for floating button
        },
        tooltip: 'Add New Item',
        child: const Icon(Icons.add),
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
                const SizedBox(height: 16),
                buildActiveTimeSection(),
                const SizedBox(height: 16),
                buildSalesCards(),
                const SizedBox(height: 16),
                buildTopCategorySales(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  child: buildChartTypeSelection(),
                ),
                buildGrowthSection('Daily Sales Growth',
                    generateDailySalesData(7), 'Day'), // Added Daily Graph
                const SizedBox(height: 16),
                buildGrowthSection('Weekly Sales Growth',
                    generateWeeklySalesData(4), 'Week'), // Added Weekly Graph
                const SizedBox(height: 16),
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
        const Text(
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
              const Text('Line Chart'),
              Radio<ChartType>(
                value: ChartType.bar,
                groupValue: chartType,
                onChanged: (ChartType? value) {
                  setState(() {
                    chartType = value!;
                  });
                },
              ),
              const Text('Bar Chart'),
              Radio<ChartType>(
                value: ChartType.pie,
                groupValue: chartType,
                onChanged: (ChartType? value) {
                  setState(() {
                    chartType = value!;
                  });
                },
              ),
              const Text('Pie Chart'),
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
          const UserAccountsDrawerHeader(
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
          buildDrawerItem(Icons.category, 'Category'),
          buildDrawerItem(Icons.person_pin, 'Waiter Master'),
          buildDrawerItem(Icons.info, 'Guest Info Add'),
          buildDrawerItem(Icons.book, 'Reservation'),
          buildDrawerItem(Icons.fastfood, 'KOT Config'),
          buildDrawerItem(Icons.calendar_today, 'Date Config'),
          buildDrawerItem(Icons.print, 'Printer Config'),
          buildDrawerItem(Icons.toll, 'Tax Config'),
          buildDrawerItem(Icons.local_offer, 'Service Charge Config'),
          buildDrawerItem(Icons.percent, 'Packing Charge Config'),
          buildDrawerItem(Icons.local_shipping, 'Delivery Charge Config'),
          buildDrawerItem(Icons.redeem, 'Discount Manage'),
          buildDrawerItem(Icons.add_business, 'Platform Fee'),
          buildDrawerItem(Icons.access_alarm, 'Happy Hour Config'),
          buildDrawerItem(Icons.inventory, 'Inventory'),
          buildDrawerItem(Icons.lock, 'Password Reset'),
          buildDrawerItem(Icons.settings, 'Settings'),
          buildDrawerItem(Icons.local_offer, 'Loyalty'),
          buildDrawerItem(Icons.shop, 'Expense'),
          buildDrawerItem(Icons.corporate_fare, 'Payroll'),
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
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const TableManagementPage()));
        } else if (title == 'Bill Config') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const BillConfigurationForm()));
        } else if (title == 'Category') {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => CategoryForm()));
        } else if (title == 'Date Config') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SoftwareDateConfigForm()));
        } else if (title == 'Password Reset') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ForgotPasswordScreen()));
        } else if (title == 'Happy Hour Config') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HappyHourConfigForm()));
        } else if (title == 'Inventory') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const InventoryDashboard()));
        } else if (title == 'Item Master') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ItemMasterScreen()));
        } else if (title == 'KOT Config') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const KOTConfigForm()));
        } else if (title == 'Add Module') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const OutletConfigurationForm()));
        } else if (title == 'Printer Config') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PrinterConfigForm()));
        } else if (title == 'Property Config') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PropertyConfigurationForm()));
        } else if (title == 'Reservation') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ReservationFormScreen()));
        } else if (title == 'Service Charge Config') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ServiceChargeConfigForm()));
        } else if (title == 'Packing Charge Config') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PackingChargeConfigForm()));
        } else if (title == 'Tax Config') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const TaxConfigForm()));
        } else if (title == 'User Master') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const UserProfilePage()));
        } else if (title == 'User Permission') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const UserPermissionForm()));
        } else if (title == 'Waiter Master') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WaiterConfigurationForm()));
        } else if (title == 'Guest Info Add') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const GuestRegistrationScreen()));
        } else if (title == 'Reservation') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ReservationFormScreen()));
        } else if (title == 'Delivery Charge Config') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DeliveryChargeConfigForm()));
        } else if (title == 'Discount Manage') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DiscountConfigForm()));
        } else if (title == 'Platform Fee') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const platformFeeConfigForm()));
        } else if (title == 'Payroll') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PayrollDashboard()));
        } else if (title == 'Expense') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ExpenseDashboard()));
        } else if (title == 'Loyalty') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const LoyaltyProgramDashboard()));
        }
      },
    );
  }

  Widget buildUserProfileSection() {
    return Card(
      elevation: 0,
      color: Colors.blueAccent.withOpacity(0.1),
      child: const Padding(
        padding: EdgeInsets.all(12.0),
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
          const Text('Active Time Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
            },
            children: const [
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('User',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Active Time'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Admin'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
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
    String categoryDisplay = 'n/a';

    if (categoriesData.isNotEmpty) {
      if (categoriesData.length == 1) {
        categoryDisplay = categoriesData[0]['item_category'];
      } else if (categoriesData.length == 2) {
        categoryDisplay =
            '${categoriesData[0]['item_category']}, ${categoriesData[1]['item_category']}';
      } else {
        categoryDisplay =
            '${categoriesData[0]['item_category']}, ${categoriesData[1]['item_category']}, ${categoriesData[2]['item_category']}';
      }
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: buildSalesCard('Today\'s Sale', Icons.today,
                    '₹ $today_sales', Colors.green, today_growth)),
            const SizedBox(width: 16),
            Expanded(
                child: buildSalesCard('Weekly Sale', Icons.date_range,
                    '₹ $this_week_sales', Colors.blue, weekly_growth)),
            const SizedBox(width: 16),
            Expanded(
                child: buildSalesCard('Monthly Sale', Icons.calendar_today,
                    '₹ $this_month_sales', Colors.orange, monthly_growth)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: buildSalesCard('Yearly Sale', Icons.assessment,
                    '₹ $this_year_sales', Colors.teal, yearly_growth)),
            const SizedBox(width: 16),
            Expanded(
                child: buildSalesCard('YoY Growth', Icons.trending_up,
                    yearly_growth, Colors.green, yearly_growth)),
            const SizedBox(width: 16),
            Expanded(
                child: buildSalesCard('Top 5 Categories', Icons.category,
                    '$categoryDisplay, etc...', Colors.teal, '')),
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
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14)),
              if (growthPercentage.isNotEmpty) const SizedBox(height: 4),
              if (title != "Top 5 Categories")
                Text('Growth: $growthPercentage',
                    style: const TextStyle(fontSize: 12, color: Colors.black)),
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
        const Text('Top Category Sales for This Month',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: categoriesData.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('${categoriesData[index]['item_category']}'),
                subtitle:
                    Text('Sales: ₹ ${categoriesData[index]['total_sales']}'),
                trailing: const Icon(Icons.trending_up),
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 250,
          child: AnimatedSwitcher(
            duration: const Duration(seconds: 1),
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
            gridData: const FlGridData(show: true),
            titlesData: const FlTitlesData(
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
            gridData: const FlGridData(show: true),
            titlesData: const FlTitlesData(
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
                title: spot.y.toStringAsFixed(0),
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
