import 'package:flutter/material.dart';
import '../../backend/api_config.dart';
import '../../backend/payroll/employee_api_service.dart';
import '../../backend/payroll/salary_advance_service.dart';

class SalaryAdvanceScreen extends StatefulWidget {
  const SalaryAdvanceScreen({super.key});

  @override
  _SalaryAdvanceScreenState createState() => _SalaryAdvanceScreenState();
}

class _SalaryAdvanceScreenState extends State<SalaryAdvanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController advanceDateController = TextEditingController();

  int? selectedEmployeeId;
  int selectedPaymentMethodId = 1;
  List<dynamic> employees = [];
  final List<Map<String, dynamic>> paymentMethods = [
    {'id': 1, 'name': 'Cash'},
    {'id': 2, 'name': 'Bank Transfer'},
    {'id': 3, 'name': 'Cheque'}
  ];

  List<dynamic> salaryAdvances = [];

  final SalaryAdvanceService _salaryAdvanceService = SalaryAdvanceService();
  final EmployeeApiService _employeeService = EmployeeApiService();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      employees = await _employeeService.getAllEmployees();
      if (employees.isNotEmpty) {
        selectedEmployeeId = employees.first['employee_id'];
      }
      final data = await _salaryAdvanceService.getAllSalaryAdvances();
      if (data != null) {
        salaryAdvances = data;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate() && selectedEmployeeId != null) {
      try {
        await _salaryAdvanceService.addSalaryAdvance(
          employeeId: selectedEmployeeId!,
          amount: double.tryParse(amountController.text) ?? 0,
          paymentMethodId: selectedPaymentMethodId,
          advanceDate: advanceDateController.text,
          repaid: false,
        );
        _fetchInitialData();
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      }
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
                        buildDropdownField('Employee', selectedEmployeeId,
                            employees, (value) {
                          setState(() {
                            selectedEmployeeId = value;
                          });
                        }),
                        buildDatePickerField(),
                        buildTextField(amountController, 'Advance Amount',
                            Icons.attach_money),
                        buildDropdownField('Payment Method', selectedPaymentMethodId,
                            paymentMethods, (value) {
                          setState(() {
                            if (value != null) selectedPaymentMethodId = value;
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
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : _error != null
                                ? Center(child: Text(_error!))
                                : DataTable(
                                    columns: const [
                                      DataColumn(label: Text('Employee')),
                                      DataColumn(label: Text('Amount')),
                                      DataColumn(label: Text('Payment Method')),
                                      DataColumn(label: Text('Advance Date')),
                                    ],
                                    rows: salaryAdvances.map((record) {
                                      return DataRow(cells: [
                                        DataCell(
                                            Text('${record['employee_id']}')),
                                        DataCell(Text(record['amount'].toString())),
                                        DataCell(Text(record['payment_method_id'].toString())),
                                        DataCell(Text(record['advance_date'] ?? '')),
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

  Widget buildDropdownField(
      String label, int? value, List<dynamic> items, Function(int?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<int>(
        value: value,
        onChanged: onChanged,
        items: items
            .map((item) => DropdownMenuItem<int>(
                  value: item['id'],
                  child: Text(item['name']),
                ))
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
