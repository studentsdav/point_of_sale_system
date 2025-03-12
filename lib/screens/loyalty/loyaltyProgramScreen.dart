import 'package:flutter/material.dart';

class LoyaltyProgramScreen extends StatefulWidget {
  const LoyaltyProgramScreen({super.key});

  @override
  _LoyaltyProgramScreenState createState() => _LoyaltyProgramScreenState();
}

class _LoyaltyProgramScreenState extends State<LoyaltyProgramScreen> {
  final List<Map<String, dynamic>> _loyaltyPrograms = [];
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pointsPerCurrencyController =
      TextEditingController();
  final TextEditingController _redemptionValueController =
      TextEditingController();
  final TextEditingController _minPointsController = TextEditingController();
  final TextEditingController _expiryDaysController = TextEditingController();
  final TextEditingController _maxRedeemController = TextEditingController();

  String _selectedTier = 'Standard';
  final List<String> _tiers = ['Standard', 'Silver', 'Gold'];

  void _addLoyaltyProgram() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loyaltyPrograms.add({
          'name': _nameController.text,
          'pointsPerCurrency': _pointsPerCurrencyController.text,
          'redemptionValue': _redemptionValueController.text,
          'minPoints': _minPointsController.text,
          'expiryDays': _expiryDaysController.text,
          'tier': _selectedTier,
          'maxRedeem': _maxRedeemController.text,
        });
      });
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Loyalty Program Management")),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Add Loyalty Program",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: "Program Name"),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _pointsPerCurrencyController,
                      decoration: const InputDecoration(
                          labelText: "Points per Currency"),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _redemptionValueController,
                      decoration: const InputDecoration(
                          labelText: "Redemption Value per Point"),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _minPointsController,
                      decoration: const InputDecoration(
                          labelText: "Min Points Redeemable"),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _expiryDaysController,
                      decoration: const InputDecoration(
                          labelText: "Points Expiry Days"),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField(
                      value: _selectedTier,
                      decoration: const InputDecoration(labelText: "Tier"),
                      items: _tiers
                          .map((tier) =>
                              DropdownMenuItem(value: tier, child: Text(tier)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedTier = value.toString()),
                    ),
                    TextFormField(
                      controller: _maxRedeemController,
                      decoration: const InputDecoration(
                          labelText: "Max Redeemable Points"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: _addLoyaltyProgram,
                        child: const Text("Add Program")),
                  ],
                ),
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
                  const Text("Loyalty Program List",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text("Name")),
                          DataColumn(label: Text("Points/Currency")),
                          DataColumn(label: Text("Redemption Value")),
                          DataColumn(label: Text("Min Redeemable")),
                          DataColumn(label: Text("Expiry Days")),
                          DataColumn(label: Text("Tier")),
                          DataColumn(label: Text("Max Redeem")),
                        ],
                        rows: _loyaltyPrograms.map((program) {
                          return DataRow(cells: [
                            DataCell(Text(program['name'])),
                            DataCell(Text(program['pointsPerCurrency'])),
                            DataCell(Text(program['redemptionValue'])),
                            DataCell(Text(program['minPoints'])),
                            DataCell(Text(program['expiryDays'] ?? 'N/A')),
                            DataCell(Text(program['tier'])),
                            DataCell(Text(program['maxRedeem'] ?? 'N/A')),
                          ]);
                        }).toList(),
                      ),
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

void main() => runApp(const MaterialApp(home: LoyaltyProgramScreen()));
