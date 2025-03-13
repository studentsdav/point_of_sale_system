import 'package:flutter/material.dart';

class SalaryAdvanceScreen extends StatefulWidget {
  const SalaryAdvanceScreen({super.key});

  @override
  _SalaryAdvanceScreenState createState() => _SalaryAdvanceScreenState();
}

class _SalaryAdvanceScreenState extends State<SalaryAdvanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController advanceDateController = TextEditingController();

  String selectedEmployee = 'Employee 1';
  String selectedPaymentMethod = 'Cash';
  final List<String> employees = ['Employee 1', 'Employee 2', 'Employee 3'];
  final List<String> paymentMethods = ['Cash', 'Bank Transfer', 'Cheque'];

  List<Map<String, dynamic>> salaryAdvances = [];

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        salaryAdvances.add({
          "Employee": selectedEmployee,
          "Amount": amountController.text,
          "Payment Method": selectedPaymentMethod,
          "Advance Date": advanceDateController.text,
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
        advanceDateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salary Advance Entry Form')),
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
                        const Text('Enter Salary Advance Details',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        buildDropdownField(
                            'Employee', selectedEmployee, employees, (value) {
                          setState(() {
                            selectedEmployee = value!;
                          });
                        }),
                        buildDatePickerField(),
                        buildTextField(amountController, 'Advance Amount',
                            Icons.attach_money),
                        buildDropdownField('Payment Method',
                            selectedPaymentMethod, paymentMethods, (value) {
                          setState(() {
                            selectedPaymentMethod = value!;
                          });
                        }),
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
                      const Text('Salary Advance Records',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Expanded(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Employee')),
                            DataColumn(label: Text('Amount')),
                            DataColumn(label: Text('Payment Method')),
                            DataColumn(label: Text('Advance Date')),
                          ],
                          rows: salaryAdvances.map((record) {
                            return DataRow(cells: [
                              DataCell(Text(record["Employee"]!)),
                              DataCell(Text(record["Amount"]!)),
                              DataCell(Text(record["Payment Method"]!)),
                              DataCell(Text(record["Advance Date"]!)),
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
        controller: advanceDateController,
        readOnly: true,
        onTap: () => _selectDate(context),
        decoration: InputDecoration(
          labelText: 'Advance Date',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => value!.isEmpty ? 'Select Advance Date' : null,
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
