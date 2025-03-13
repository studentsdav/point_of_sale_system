import 'package:flutter/material.dart';

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
  String selectedEmployee = 'Employee 1';
  final List<String> statuses = ['Present', 'Absent', 'Leave', 'Late'];
  final List<String> employees = ['Employee 1', 'Employee 2', 'Employee 3'];

  List<Map<String, String>> attendanceRecords = [];

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        attendanceRecords.add({
          "Employee": selectedEmployee,
          "Work Date": workDateController.text,
          "Shift Start": shiftStartController.text,
          "Shift End": shiftEndController.text,
          "Status": selectedStatus,
        });
      });
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
                        buildDatePickerField(),
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
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Employee')),
                            DataColumn(label: Text('Work Date')),
                            DataColumn(label: Text('Shift Start')),
                            DataColumn(label: Text('Shift End')),
                            DataColumn(label: Text('Status')),
                          ],
                          rows: attendanceRecords.map((record) {
                            Color rowColor = getStatusColor(record["Status"]!);
                            return DataRow(cells: [
                              DataCell(Text(record["Employee"]!)),
                              DataCell(Text(record["Work Date"]!)),
                              DataCell(Text(record["Shift Start"]!)),
                              DataCell(Text(record["Shift End"]!)),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: rowColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    record["Status"]!,
                                    style: const TextStyle(color: Colors.white),
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
      child: DropdownButtonFormField<String>(
        value: selectedEmployee,
        items: employees.map((String employee) {
          return DropdownMenuItem<String>(
            value: employee,
            child: Text(employee),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedEmployee = newValue!;
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

Widget buildDatePickerField() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      onTap: () => () {},
      decoration: InputDecoration(
        labelText: 'Work Date',
        prefixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) => value!.isEmpty ? 'Select Work Date' : null,
    ),
  );
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
