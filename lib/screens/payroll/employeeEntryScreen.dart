import 'package:flutter/material.dart';
import '../../backend/payroll/employee_api_service.dart';

class EmployeeEntryScreen extends StatefulWidget {
  const EmployeeEntryScreen({super.key});

  @override
  _EmployeeEntryScreenState createState() => _EmployeeEntryScreenState();
}

class _EmployeeEntryScreenState extends State<EmployeeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController currencyController = TextEditingController();
  final TextEditingController houseAllowanceController =
      TextEditingController();
  final TextEditingController insuranceController = TextEditingController();
  final TextEditingController pfController = TextEditingController();

  String selectedPosition = 'Software Engineer';
  final List<String> positions = [
    'Software Engineer',
    'Project Manager',
    'HR Manager',
    'Data Analyst',
    'Sales Executive'
  ];

  final EmployeeApiService _employeeService = EmployeeApiService();

  List<dynamic> employees = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _employeeService.getAllEmployees();
      setState(() {
        employees = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _employeeService.createEmployee({
          'name': nameController.text,
          'phone': phoneController.text,
          'email': emailController.text,
          'position': selectedPosition,
          'base_salary': double.tryParse(salaryController.text) ?? 0,
          'currency': currencyController.text,
          'country_code': 'IN',
          'hire_date': DateTime.now().toIso8601String(),
        });
        _fetchEmployees();
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Entry Form')),
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
                        const Text('Enter Employee Details',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        buildTextField(nameController, 'Name', Icons.person),
                        buildTextField(phoneController, 'Phone', Icons.phone),
                        buildTextField(emailController, 'Email', Icons.email),
                        buildDropdownField(),
                        buildTextField(salaryController, 'Base Salary',
                            Icons.attach_money),
                        buildTextField(
                            currencyController, 'Currency', Icons.money),
                        buildTextField(houseAllowanceController,
                            'House Allowance', Icons.home),
                        buildTextField(insuranceController,
                            'Insurance Contribution', Icons.health_and_safety),
                        buildTextField(
                            pfController, 'PF Contribution', Icons.savings),
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
            // Right Side Display Output using DataTable
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
                      const Text('Employee Details',
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
                                      DataColumn(label: Text('Name')),
                                      DataColumn(label: Text('Phone')),
                                      DataColumn(label: Text('Email')),
                                      DataColumn(label: Text('Position')),
                                      DataColumn(label: Text('Salary')),
                                    ],
                                    rows: employees.map((employee) {
                                      return DataRow(cells: [
                                        DataCell(Text(employee['name'] ?? '')),
                                        DataCell(Text(employee['phone'] ?? '')),
                                        DataCell(Text(employee['email'] ?? '')),
                                        DataCell(
                                            Text(employee['position'] ?? '')),
                                        DataCell(Text(
                                            '${employee['base_salary']} ${employee['currency'] ?? ''}')),
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

  Widget buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => value!.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Widget buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedPosition,
        items: positions.map((String position) {
          return DropdownMenuItem<String>(
            value: position,
            child: Text(position),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedPosition = newValue!;
          });
        },
        decoration: InputDecoration(
          labelText: 'Position',
          prefixIcon: const Icon(Icons.work),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
