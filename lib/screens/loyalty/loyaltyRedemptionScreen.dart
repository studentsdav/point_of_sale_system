import 'package:flutter/material.dart';

class LoyaltyRedemptionScreen extends StatefulWidget {
  const LoyaltyRedemptionScreen({super.key});

  @override
  _LoyaltyRedemptionScreenState createState() =>
      _LoyaltyRedemptionScreenState();
}

class _LoyaltyRedemptionScreenState extends State<LoyaltyRedemptionScreen> {
  String? selectedProgram;
  final TextEditingController minSpendController = TextEditingController();
  final TextEditingController maxDailyController = TextEditingController();
  final TextEditingController maxMonthlyController = TextEditingController();

  List<Map<String, dynamic>> redemptionLimits = [
    {
      'program': 'Gold Membership',
      'minSpend': 1000,
      'maxDaily': 500,
      'maxMonthly': 5000,
    },
    {
      'program': 'Silver Membership',
      'minSpend': 800,
      'maxDaily': 400,
      'maxMonthly': 4000,
    },
  ];

  void addRedemptionLimit() {
    setState(() {
      redemptionLimits.add({
        'program': selectedProgram ?? 'Unknown',
        'minSpend': double.tryParse(minSpendController.text) ?? 0,
        'maxDaily': int.tryParse(maxDailyController.text) ?? 0,
        'maxMonthly': int.tryParse(maxMonthlyController.text) ?? 0,
      });
    });
    minSpendController.clear();
    maxDailyController.clear();
    maxMonthlyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loyalty Redemption Limits')),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: 'Select Loyalty Program'),
                    value: selectedProgram,
                    items: ['Gold Membership', 'Silver Membership']
                        .map((program) => DropdownMenuItem(
                              value: program,
                              child: Text(program),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedProgram = value;
                      });
                    },
                  ),
                  TextField(
                    controller: minSpendController,
                    decoration:
                        const InputDecoration(labelText: 'Min Spend Amount'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: maxDailyController,
                    decoration:
                        const InputDecoration(labelText: 'Max Daily Redeem'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: maxMonthlyController,
                    decoration:
                        const InputDecoration(labelText: 'Max Monthly Redeem'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: addRedemptionLimit,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Redemption Limits',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Program')),
                        DataColumn(label: Text('Min Spend')),
                        DataColumn(label: Text('Max Daily')),
                        DataColumn(label: Text('Max Monthly')),
                      ],
                      rows: redemptionLimits
                          .map(
                            (data) => DataRow(cells: [
                              DataCell(Text(data['program'])),
                              DataCell(Text(data['minSpend'].toString())),
                              DataCell(Text(data['maxDaily'].toString())),
                              DataCell(Text(data['maxMonthly'].toString())),
                            ]),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
