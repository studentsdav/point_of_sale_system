import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class FeedbackReportScreen extends StatelessWidget {
  final List<FeedbackData> feedbackList = [
    FeedbackData(rating: 1, count: 5),
    FeedbackData(rating: 2, count: 10),
    FeedbackData(rating: 3, count: 20),
    FeedbackData(rating: 4, count: 30),
    FeedbackData(rating: 5, count: 35),
  ];

  final List<FeedbackLog> feedbackLogs = [
    FeedbackLog(guestId: 101, rating: 5, comment: "Great service!"),
    FeedbackLog(guestId: 102, rating: 4, comment: "Good experience."),
    FeedbackLog(guestId: 103, rating: 3, comment: "Average service."),
    FeedbackLog(guestId: 104, rating: 2, comment: "Could be better."),
    FeedbackLog(guestId: 105, rating: 1, comment: "Very bad experience."),
  ];

  FeedbackReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int totalFeedbacks = feedbackList.fold(0, (sum, item) => sum + item.count);

    return Scaffold(
      appBar: AppBar(title: const Text("Customer Feedback Report")),
      body: Row(
        children: [
          // Left Side: Bar Chart + Pie Chart
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Bar Chart
                Expanded(
                  child: SfCartesianChart(
                    title: const ChartTitle(text: 'Customer Feedback Ratings'),
                    primaryXAxis:
                        const CategoryAxis(title: AxisTitle(text: 'Rating')),
                    primaryYAxis:
                        const NumericAxis(title: AxisTitle(text: 'Count')),
                    series: <CartesianSeries<dynamic, dynamic>>[
                      ColumnSeries<FeedbackData, String>(
                        dataSource: feedbackList,
                        xValueMapper: (FeedbackData feedback, _) =>
                            feedback.rating.toString(),
                        yValueMapper: (FeedbackData feedback, _) =>
                            feedback.count,
                        pointColorMapper: (FeedbackData feedback, _) =>
                            _getColor(feedback.rating),
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),

                // Pie Chart
                Expanded(
                  child: SfCircularChart(
                    title:
                        const ChartTitle(text: 'Feedback Rating Distribution'),
                    legend: const Legend(
                        isVisible: true, position: LegendPosition.right),
                    series: <PieSeries<FeedbackData, String>>[
                      PieSeries<FeedbackData, String>(
                        dataSource: feedbackList,
                        xValueMapper: (FeedbackData data, _) =>
                            "⭐ ${data.rating}",
                        yValueMapper: (FeedbackData data, _) => data.count,
                        pointColorMapper: (FeedbackData data, _) =>
                            _getColor(data.rating),
                        dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right Side: Summary + Feedback Log
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Summary Table
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Rating')),
                      DataColumn(label: Text('Count')),
                      DataColumn(label: Text('Percentage')),
                    ],
                    rows: feedbackList.map((feedback) {
                      double percentage =
                          (feedback.count / totalFeedbacks) * 100;
                      return DataRow(cells: [
                        DataCell(Text('⭐ ${feedback.rating}')),
                        DataCell(Text('${feedback.count}')),
                        DataCell(Text('${percentage.toStringAsFixed(1)}%')),
                      ]);
                    }).toList(),
                  ),
                ),

                // Feedback Log
                Expanded(
                  child: ListView.builder(
                    itemCount: feedbackLogs.length,
                    itemBuilder: (context, index) {
                      final log = feedbackLogs[index];
                      return Card(
                        color: _getColor(log.rating).withOpacity(0.2),
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getColor(log.rating),
                            child: Text(log.rating.toString(),
                                style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text("Guest ID: ${log.guestId}"),
                          subtitle: Text(log.comment),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to get color based on rating
  Color _getColor(int rating) {
    switch (rating) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

// Feedback Data Model
class FeedbackData {
  final int rating;
  final int count;

  FeedbackData({required this.rating, required this.count});
}

// Feedback Log Model
class FeedbackLog {
  final int guestId;
  final int rating;
  final String comment;

  FeedbackLog(
      {required this.guestId, required this.rating, required this.comment});
}
