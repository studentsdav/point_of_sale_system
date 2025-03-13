import 'package:flutter/material.dart';

class EmployeeBenefitsScreen extends StatefulWidget {
  const EmployeeBenefitsScreen({super.key});

  @override
  _EmployeeBenefitsScreenState createState() => _EmployeeBenefitsScreenState();
}

class _EmployeeBenefitsScreenState extends State<EmployeeBenefitsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController effectiveDateController = TextEditingController();

  String selectedEmployee = 'Employee 1';
  String selectedBenefitType = 'House Allowance';
  final List<String> employees = ['Employee 1', 'Employee 2', 'Employee 3'];
  final List<String> benefitTypes = ['House Allowance', 'Insurance', 'Other'];

  List<Map<String, dynamic>> employeeBenefits = [];

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        employeeBenefits.add({
          "Employee": selectedEmployee,
          "Benefit Type": selectedBenefitType,
          "Amount": amountController.text,
          "Effective Date": effectiveDateController.text,
        });
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        effectiveDateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Benefits Entry Form')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Left Side Entry Form
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Enter Employee Benefit Details',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        buildDropdownField(
                            'Employee', selectedEmployee, employees, (value) {
                          setState(() {
                            selectedEmployee = value!;
                          });
                        }),
                        buildDropdownField(
                            'Benefit Type', selectedBenefitType, benefitTypes,
                            (value) {
                          setState(() {
                            selectedBenefitType = value!;
                          });
                        }),
                        buildDatePickerField(),
                        buildTextField(
                            amountController, 'Amount', Icons.attach_money),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: submitForm,
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Right Side Display Output using DataTable2
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: Colors.blueGrey[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Employee Benefits Records',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Expanded(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Employee')),
                            DataColumn(label: Text('Benefit Type')),
                            DataColumn(label: Text('Amount')),
                            DataColumn(label: Text('Effective Date')),
                          ],
                          rows: employeeBenefits.map((record) {
                            return DataRow(cells: [
                              DataCell(Text(record["Employee"]!)),
                              DataCell(Text(record["Benefit Type"]!)),
                              DataCell(Text(record["Amount"]!)),
                              DataCell(Text(record["Effective Date"]!)),
                            ]);
                          }).toList(),
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

  Widget buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: effectiveDateController,
        readOnly: true,
        onTap: () => _selectDate(context),
        decoration: InputDecoration(
          labelText: 'Effective Date',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => value!.isEmpty ? 'Select Effective Date' : null,
      ),
    );
  }

  Widget buildDropdownField(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => value!.isEmpty ? 'Enter $label' : null,
      ),
    );
  }
}
