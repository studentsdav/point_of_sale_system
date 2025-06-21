import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../backend/loyalty/loyalty_api_service.dart';
import '../../backend/api_config.dart';

import 'appliedDiscountReport.dart';
import 'customerFeedbackReport.dart';
import 'customerLoyaltyReport.dart';
import 'loyaltyProgramScreen.dart';
import 'loyaltyRedemptionScreen.dart';
import 'loyaltyTransactionsReport.dart';
import 'promoCodeScreen.dart';

class LoyaltyProgramDashboard extends StatefulWidget {
  const LoyaltyProgramDashboard({super.key});

  @override
  State<LoyaltyProgramDashboard> createState() =>
      _LoyaltyProgramDashboardState();
}

class _LoyaltyProgramDashboardState extends State<LoyaltyProgramDashboard> {
  final LoyaltyApiService _apiService =
      LoyaltyApiService('$apiBaseUrl/loyalty');

  int pointsEarned = 0;
  int pointsRedeemed = 0;
  double pointsValue = 0;
  double redeemedValue = 0;
  int feedbackReceived = 120;
  int positiveFeedback = 90;
  int negativeFeedback = 30;
  int expiredPoints = 300;
  int totalDiscountGiven = 5000;
  int promoRunning = 5;
  int promoEnded = 8;

  int _selectedIndex = 0;

  final List<String> menuItems = [
    "Applied Discount Report",
    "Feedback Report",
    "Customer Loyalty Report",
    "Loyalty Program",
    "Loyalty Redemption",
    "Loyalty Transactions Report",
    "Promo Code",
  ];

  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final data = await _apiService.fetchAllLoyaltyRecords();
      setState(() {
        transactions = List<Map<String, dynamic>>.from(data);
        pointsEarned = transactions.fold(
            0, (sum, item) => sum + (item['points_earned'] ?? 0));
        pointsRedeemed = transactions.fold(
            0, (sum, item) => sum + (item['points_redeemed'] ?? 0));
        pointsValue = pointsEarned * 0.1;
        redeemedValue = pointsRedeemed * 0.1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching loyalty records: $e')),
      );
    }
  }

  Future<void> _earnPoints(int guestId, int programId, int points) async {
    try {
      await _apiService.addOrUpdateLoyaltyPoints(guestId, programId, points);
      await _fetchTransactions();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error earning points: $e')),
      );
    }
  }

  Future<void> _redeemPoints(int guestId, int points) async {
    try {
      await _apiService.redeemLoyaltyPoints(guestId, points);
      await _fetchTransactions();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error redeeming points: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Loyalty Program Dashboard"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_forward_ios))
        ],
      ),
      drawer: buildDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryCards(),
            const SizedBox(height: 20),
            _buildChart(),
            const SizedBox(height: 20),
            _buildTransactionReport(),
          ],
        ),
      ),
    );
  }

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Menu',
                style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ...menuItems.asMap().entries.map((entry) {
            return ListTile(
              title: Text(entry.value),
              selected: _selectedIndex == entry.key,
              onTap: () {
                setState(() => _selectedIndex = entry.key);
                Navigator.pop(context); // Close the drawer
                navigateToScreen(entry.key);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: _buildCard('Points Earned', Icons.star, '$pointsEarned',
                    Colors.green)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildCard('Points Value', Icons.attach_money,
                    '₹ $pointsValue', Colors.blue)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildCard('Points Redeemed', Icons.redeem,
                    '$pointsRedeemed', Colors.orange)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: _buildCard('Redeemed Value', Icons.money,
                    '₹ $redeemedValue', Colors.teal)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildCard('Feedback Received', Icons.feedback,
                    '$feedbackReceived', Colors.purple)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildCard('Positive Feedback', Icons.thumb_up,
                    '$positiveFeedback', Colors.green)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _earnPoints(1, 1, 10),
              child: const Text('Earn 10'),
            ),
            ElevatedButton(
              onPressed: () => _redeemPoints(1, 5),
              child: const Text('Redeem 5'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(String title, IconData icon, String value, Color color) {
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

  Widget _buildChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Last 30 Days Transactions & Discounts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(),
                title: const ChartTitle(text: "Discounts Given"),
                legend: const Legend(isVisible: true),
                series: <ColumnSeries>[
                  ColumnSeries<Map<String, dynamic>, String>(
                    name: "Discounts",
                    dataSource: transactions,
                    xValueMapper: (data, _) => data['date'],
                    yValueMapper: (data, _) => data['discount'],
                    color: Colors.blue,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionReport() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Loyalty Transactions Report",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                physics: const ClampingScrollPhysics(),
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Transaction ID')),
                    DataColumn(label: Text('Guest ID')),
                    DataColumn(label: Text('Program ID')),
                    DataColumn(label: Text('Order ID')),
                    DataColumn(label: Text('Points Earned')),
                    DataColumn(label: Text('Points Redeemed')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Expiry Date')),
                    DataColumn(label: Text('Store ID')),
                    DataColumn(label: Text('Payment Method')),
                    DataColumn(label: Text('Created At')),
                  ],
                  rows: List.generate(5, (index) {
                    return DataRow(
                      color: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          if (index % 2 == 0) return Colors.grey.shade200;
                          return null;
                        },
                      ),
                      cells: [
                        DataCell(Text('${1000 + index}')),
                        DataCell(Text('${200 + index}')),
                        DataCell(Text('${300 + index}')),
                        DataCell(Text('${400 + index}')),
                        DataCell(Text('${50 * (index + 1)}')),
                        DataCell(Text('${20 * (index + 1)}')),
                        DataCell(Text(index % 2 == 0 ? 'Earn' : 'Redeem')),
                        DataCell(Text('2025-04-${10 + index}')),
                        DataCell(Text('${500 + index}')),
                        DataCell(Text(index % 2 == 0 ? 'Cash' : 'Card')),
                        DataCell(Text('2025-03-${1 + index}')),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToScreen(int index) {
    Widget screen;
    switch (index) {
      case 0:
        screen = const AppliedDiscountReport();
        break;
      case 1:
        screen = FeedbackReportScreen();
        break;
      case 2:
        screen = const CustomerLoyaltyReport();
        break;
      case 3:
        screen = const LoyaltyProgramScreen();
        break;
      case 4:
        screen = const LoyaltyRedemptionScreen();
        break;
      case 5:
        screen = const LoyaltyTransactionsReport();
        break;
      case 6:
        screen = const PromoCodeScreen();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
