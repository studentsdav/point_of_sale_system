import 'package:flutter/material.dart';

class PrinterConfigForm extends StatefulWidget {
  @override
  _PrinterConfigFormState createState() => _PrinterConfigFormState();
}

class _PrinterConfigFormState extends State<PrinterConfigForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController printerNumberController = TextEditingController();
  String printerName = '';
  String printerType = 'receipt';
  String ipAddress = '';
  int port = 9100;
  String status = 'active';

  // List to store printer configurations
  List<Map<String, String>> printers = [];

  // Save printer configuration logic
  void _savePrinterConfig() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Check if the entered printer number already exists, if so, replace it
      String printerNumber = printerNumberController.text.trim();

      // Replace the printer if it already exists in the list
      setState(() {
        bool exists = false;
        for (int i = 0; i < printers.length; i++) {
          if (printers[i]['printerNumber'] == printerNumber) {
            printers[i] = {
              'printerNumber': printerNumber,
              'printerName': printerName,
              'printerType': printerType,
              'ipAddress': ipAddress,
              'port': port.toString(),
              'status': status,
            };
            exists = true;
            break;
          }
        }

        // If the printer number doesn't exist, add a new entry
        if (!exists) {
          printers.add({
            'printerNumber': printerNumber,
            'printerName': printerName,
            'printerType': printerType,
            'ipAddress': ipAddress,
            'port': port.toString(),
            'status': status,
          });
        }
      });

      // Clear the form fields after saving
      printerNumberController.clear();
      setState(() {
        printerName = '';
        printerType = 'receipt';
        ipAddress = '';
        port = 9100;
        status = 'active';
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Printer configuration saved')));
    }
  }

  // Delete printer from list
  void _deletePrinter(int index) {
    setState(() {
      printers.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Printer deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Printer Configuration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Printer configuration form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: printerNumberController,
                    decoration: InputDecoration(labelText: 'Printer Number'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a printer number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      // Saving the entered value
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Printer Name'),
                    onSaved: (value) {
                      printerName = value!;
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: printerType,
                    onChanged: (value) {
                      setState(() {
                        printerType = value!;
                      });
                    },
                    items: ['receipt', 'bill'].map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Printer Type'),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'IP Address'),
                    onSaved: (value) {
                      ipAddress = value!;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Port'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      port = int.parse(value!);
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: status,
                    onChanged: (value) {
                      setState(() {
                        status = value!;
                      });
                    },
                    items: ['active', 'inactive'].map((statusOption) {
                      return DropdownMenuItem<String>(
                        value: statusOption,
                        child: Text(statusOption),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Status'),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _savePrinterConfig,
                    child: Text('Save Printer Configuration'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Display saved printers in a list
            Expanded(
              child: ListView.builder(
                itemCount: printers.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.print, color: Colors.blue),
                      title: Text('Printer ${printers[index]['printerNumber']} - ${printers[index]['printerName']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Type: ${printers[index]['printerType']}'),
                          Text('IP: ${printers[index]['ipAddress']}'),
                          Text('Port: ${printers[index]['port']}'),
                          Text('Status: ${printers[index]['status']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePrinter(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
