import 'package:flutter/material.dart';

import '../../backend/api_config.dart';
import '../../backend/payroll/attendance_api_service.dart';
import '../../backend/payroll/employee_api_service.dart';

class AttendanceEntryScreen extends StatefulWidget {
  const AttendanceEntryScreen({super.key});

  @override
  _AttendanceEntryScreenState createState() => _AttendanceEntryScreenState();
}

class _AttendanceEntryScreenState extends State<AttendanceEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController workDateController = TextEditingController();
  final TextEditingController shiftStartController = TextEditingController();
  final TextEditingController shiftEndController = TextEditingController();

  String selectedStatus = 'Present';
  int? selectedEmployeeId;
  final List<String> statuses = ['Present', 'Absent', 'Leave', 'Late'];

  List<dynamic> employees = [];
  List<dynamic> attendanceRecords = [];

  final AttendanceApiService _attendanceService =
      AttendanceApiService(baseUrl: apiBaseUrl);
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
      attendanceRecords = await _attendanceService.fetchAllAttendance();
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
        await _attendanceService.addAttendance({
          'employee_id': selectedEmployeeId,
          'work_date': workDateController.text,
          'shift_start': shiftStartController.text,
          'shift_end': shiftEndController.text,
          'status': selectedStatus,
          'biometric_entry': '',
          'biometric_exit': ''
        });
        _fetchInitialData();
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
      appBar: AppBar(title: const Text('Attendance Entry Form')),
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
                        const Text('Enter Attendance Details',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        buildDropdownEmployeeField(),
                        buildDatePickerField(context),
                        buildTextField(shiftStartController,
                            'Shift Start (HH:MM)', Icons.access_time),
                        buildTextField(shiftEndController, 'Shift End (HH:MM)',
                            Icons.access_time),
                        buildDropdownField(),
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
                      const Text('Attendance Records',
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
                                      DataColumn(label: Text('Work Date')),
                                      DataColumn(label: Text('Shift Start')),
                                      DataColumn(label: Text('Shift End')),
                                      DataColumn(label: Text('Status')),
                                    ],
                                    rows: attendanceRecords.map((record) {
                                      Color rowColor =
                                          getStatusColor(record['status']);
                                      return DataRow(cells: [
                                        DataCell(
                                            Text('${record['employee_id']}')),
                                        DataCell(
                                            Text(record['work_date'] ?? '')),
                                        DataCell(
                                            Text(record['shift_start'] ?? '')),
                                        DataCell(
                                            Text(record['shift_end'] ?? '')),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: rowColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              record['status'] ?? '',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
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

  Widget buildDatePickerField(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: workDateController,
        readOnly: true,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            workDateController.text = picked.toIso8601String().split('T').first;
          }
        },
        decoration: InputDecoration(
          labelText: 'Work Date',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => value!.isEmpty ? 'Select Work Date' : null,
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
        value: selectedStatus,
        items: statuses.map((String status) {
          return DropdownMenuItem<String>(
            value: status,
            child: Text(status),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedStatus = newValue!;
          });
        },
        decoration: InputDecoration(
          labelText: 'Status',
          prefixIcon: const Icon(Icons.event_available),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget buildDropdownEmployeeField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<int>(
        value: selectedEmployeeId,
        items: employees.map<DropdownMenuItem<int>>((employee) {
          return DropdownMenuItem<int>(
            value: employee['employee_id'],
            child: Text(employee['name'] ?? ''),
          );
        }).toList(),
        onChanged: (int? newValue) {
          setState(() {
            selectedEmployeeId = newValue;
          });
        },
        decoration: InputDecoration(
          labelText: 'Select Employee',
          prefixIcon: const Icon(Icons.person),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

Color getStatusColor(String status) {
  switch (status) {
    case 'Present':
      return Colors.green;
    case 'Absent':
      return Colors.red;
    case 'Leave':
      return Colors.orange;
    case 'Late':
      return Colors.yellow;
    default:
      return Colors.grey;
  }
}
