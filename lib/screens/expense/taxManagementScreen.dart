import 'package:flutter/material.dart';

class TaxScreen extends StatefulWidget {
  const TaxScreen({super.key});

  @override
  _TaxScreenState createState() => _TaxScreenState();
}

class _TaxScreenState extends State<TaxScreen> {
  final TextEditingController taxNameController = TextEditingController();
  final TextEditingController taxRateController = TextEditingController();
  final TextEditingController applicableOnController = TextEditingController();

  List<Map<String, dynamic>> taxList = [
    {"id": 1, "tax_name": "GST", "tax_rate": "18%", "applicable_on": "Goods"},
    {
      "id": 2,
      "tax_name": "Service Tax",
      "tax_rate": "5%",
      "applicable_on": "Services"
    },
  ];

  void addTax() {
    if (taxNameController.text.isNotEmpty &&
        taxRateController.text.isNotEmpty &&
        applicableOnController.text.isNotEmpty) {
      setState(() {
        taxList.add({
          "id": taxList.length + 1,
          "tax_name": taxNameController.text,
          "tax_rate": "${taxRateController.text}%",
          "applicable_on": applicableOnController.text,
        });

        // Clear fields
        taxNameController.clear();
        taxRateController.clear();
        applicableOnController.clear();
      });
    }
  }

  void deleteTax(int id) {
    setState(() {
      taxList.removeWhere((tax) => tax["id"] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tax Management")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Left Side: Tax Entry Form
            Expanded(
              flex: 1,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Add Tax",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      TextField(
                          controller: taxNameController,
                          decoration:
                              const InputDecoration(labelText: "Tax Name")),
                      TextField(
                          controller: taxRateController,
                          decoration:
                              const InputDecoration(labelText: "Tax Rate (%)"),
                          keyboardType: TextInputType.number),
                      TextField(
                          controller: applicableOnController,
                          decoration: const InputDecoration(
                              labelText: "Applicable On")),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: addTax,
                        child: const Text("Save Tax"),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 20),

            // Right Side: Tax List
            Expanded(
              flex: 2,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text("Tax List",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: taxList.length,
                          itemBuilder: (context, index) {
                            final tax = taxList[index];
                            return ListTile(
                              title: Text(
                                  "${tax["tax_name"]} (${tax["tax_rate"]})"),
                              subtitle: Text(
                                  "Applicable On: ${tax["applicable_on"]}"),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteTax(tax["id"]),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
