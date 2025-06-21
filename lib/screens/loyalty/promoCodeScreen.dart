import 'package:flutter/material.dart';

import '../../backend/loyalty/loyalty_api_service.dart';
import '../../backend/api_config.dart';

class PromoCodeScreen extends StatefulWidget {
  const PromoCodeScreen({super.key});

  @override
  _PromoCodeScreenState createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends State<PromoCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _maxUsesController = TextEditingController();
  final TextEditingController _perUserLimitController = TextEditingController();
  String? _selectedDiscount;

  List<Map<String, dynamic>> promoCodes = [
    {
      "code": "WELCOME10",
      "discount": "10% Off",
      "maxUses": 5,
      "perUser": 1,
      "usageCount": 2,
      "isActive": true
    },
  ];

  List<String> discountOptions = ["10% Off", "20% Off", "₹50 Off"];

  void _addPromoCode() {
    setState(() {
      promoCodes.add({
        "code": _codeController.text,
        "discount": _selectedDiscount ?? "",
        "maxUses": int.tryParse(_maxUsesController.text) ?? 1,
        "perUser": int.tryParse(_perUserLimitController.text) ?? 1,
        "usageCount": 0,
        "isActive": true,
      });
      _codeController.clear();
      _maxUsesController.clear();
      _perUserLimitController.clear();
      _selectedDiscount = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Promo Code Management")),
      body: Row(
        children: [
          // Entry Form
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add Promo Code",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextField(
                      controller: _codeController,
                      decoration:
                          const InputDecoration(labelText: "Promo Code")),
                  DropdownButtonFormField<String>(
                    value: _selectedDiscount,
                    decoration:
                        const InputDecoration(labelText: "Select Discount"),
                    items: discountOptions
                        .map((discount) => DropdownMenuItem(
                            value: discount, child: Text(discount)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedDiscount = value),
                  ),
                  TextField(
                      controller: _maxUsesController,
                      decoration: const InputDecoration(labelText: "Max Uses"),
                      keyboardType: TextInputType.number),
                  TextField(
                      controller: _perUserLimitController,
                      decoration:
                          const InputDecoration(labelText: "Per User Limit"),
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: _addPromoCode,
                      child: const Text("Add Promo Code")),
                ],
              ),
            ),
          ),
          // Data Table
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Promo Code List",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text("Code")),
                          DataColumn(label: Text("Discount")),
                          DataColumn(label: Text("Max Uses")),
                          DataColumn(label: Text("Per User")),
                          DataColumn(label: Text("Used")),
                          DataColumn(label: Text("Status")),
                        ],
                        rows: promoCodes.map((promo) {
                          return DataRow(cells: [
                            DataCell(Text(promo["code"])),
                            DataCell(Text(promo["discount"])),
                            DataCell(Text(promo["maxUses"].toString())),
                            DataCell(Text(promo["perUser"].toString())),
                            DataCell(Text(promo["usageCount"].toString())),
                            DataCell(Text(
                                promo["isActive"] ? "Active" : "Inactive",
                                style: TextStyle(
                                    color: promo["isActive"]
                                        ? Colors.green
                                        : Colors.red))),
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
