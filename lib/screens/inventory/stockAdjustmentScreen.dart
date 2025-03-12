import 'package:flutter/material.dart';

class StockAdjustmentScreen extends StatefulWidget {
  const StockAdjustmentScreen({super.key});

  @override
  _StockAdjustmentScreenState createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  final List<Map<String, dynamic>> _adjustments =
      []; // Stores stock adjustments

  String? _selectedIngredient;
  String? _selectedReason;
  final TextEditingController _quantityController = TextEditingController();

  void _submitAdjustment() {
    if (_selectedIngredient != null &&
        _selectedReason != null &&
        _quantityController.text.isNotEmpty) {
      setState(() {
        _adjustments.add({
          "ingredient": _selectedIngredient,
          "quantity": _quantityController.text,
          "reason": _selectedReason,
          "adjustedBy": "John Doe",
          "date": DateTime.now().toString().substring(0, 16) // Short date
        });

        // Reset fields after submission
        _selectedIngredient = null;
        _selectedReason = null;
        _quantityController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stock Adjustment")),
      body: Row(
        children: [
          // Left Panel - Stock Adjustment Entry
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Adjust Stock",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Ingredient"),
                    value: _selectedIngredient,
                    items: const [
                      DropdownMenuItem(value: "Flour", child: Text("Flour")),
                      DropdownMenuItem(value: "Cheese", child: Text("Cheese")),
                      DropdownMenuItem(value: "Tomato", child: Text("Tomato")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedIngredient = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _quantityController,
                    decoration:
                        const InputDecoration(labelText: "Adjusted Quantity"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: "Adjustment Reason"),
                    value: _selectedReason,
                    items: const [
                      DropdownMenuItem(
                          value: "Spoilage", child: Text("Spoilage")),
                      DropdownMenuItem(
                          value: "Stock Correction",
                          child: Text("Stock Correction")),
                      DropdownMenuItem(
                          value: "Expired", child: Text("Expired")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedReason = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Adjusted By: John Doe",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: _submitAdjustment,
                        child: const Text("Submit Adjustment")),
                  ),
                ],
              ),
            ),
          ),

          // Right Panel - Display Adjusted Stock Records
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Adjustment Records",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _adjustments.isEmpty
                        ? const Center(
                            child: Text(
                              "No adjustments yet",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _adjustments.length,
                            itemBuilder: (context, index) {
                              final adjustment = _adjustments[index];
                              return Card(
                                child: ListTile(
                                  title: Text(
                                      "${adjustment['ingredient']} - ${adjustment['quantity']}kg"),
                                  subtitle: Text(
                                      "Reason: ${adjustment['reason']} | Adjusted By: ${adjustment['adjustedBy']} | Date: ${adjustment['date']}"),
                                ),
                              );
                            },
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
