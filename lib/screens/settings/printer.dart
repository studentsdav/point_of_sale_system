import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../backend/settings/printerApiService.dart';

class PrinterConfigForm extends StatefulWidget {
  const PrinterConfigForm({super.key});

  @override
  _PrinterConfigFormState createState() => _PrinterConfigFormState();
}

class _PrinterConfigFormState extends State<PrinterConfigForm> {
  final _formKey = GlobalKey<FormState>();
  PrinterApiService printerApiService = PrinterApiService();
  TextEditingController printerNumberController = TextEditingController();
  String printerName = '';
  String printerType = 'receipt';
  String ipAddress = '';
  int port = 9100;
  String status = 'active';
  String? _selectedOutlet; // Default selected outlet

  // List to store printer configurations
  List<Map<String, dynamic>> printers = [];
  List<String> outlets = [];
  List<dynamic> properties = [];
  List<dynamic> outletConfigurations = [];
  @override
  void initState() {
    super.initState();
    _loadDataFromHive();
  }

  // Load data from Hive
  Future<void> _loadDataFromHive() async {
    var box = await Hive.openBox('appData');

    // Retrieve the data
    var properties = box.get('properties');
    var outletConfigurations = box.get('outletConfigurations');

    // Check if outletConfigurations is not null
    if (outletConfigurations != null) {
      // Extract the outlet names into the outlets list
      List<String> outletslist = [];
      for (var outlet in outletConfigurations) {
        if (outlet['outlet_name'] != null) {
          outletslist.add(outlet['outlet_name'].toString());
        }
      }

      setState(() {
        this.properties = properties ?? [];
        this.outletConfigurations = outletConfigurations ?? [];
        outlets = outletslist; // Set the outlets list
      });
    }
    _fetchPrinters();
  }

  // Save printer configuration logic
  void _savePrinterConfig() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final printerData = {
        'printer_number': printerNumberController.text.trim(),
        'printer_name': printerName,
        'printer_type': printerType,
        'ip_address': ipAddress,
        'port': port,
        'status': status,
        'property_id': properties[0]
            ['property_id'], // Replace with dynamic property ID
        'outlet_name': _selectedOutlet,
      };

      try {
        // // Check if printer already exists
        // final existingPrinter = printers.firstWhere(
        //   (printer) =>
        //       printer['printer_number'] == printerData['printer_number'],
        // );

        // if (existingPrinter != null) {
        //   // Update printer configuration
        //   await printerApiService.updatePrinter(
        //     existingPrinter['printer_number']!,
        //     printerData,
        //   );
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Printer configuration updated successfully')),
        //   );
        // } else {
        //   // Add new printer configuration
        //   await printerApiService.createPrinter(printerData);
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Printer configuration saved successfully')),
        //   );
        // }

        // Add new printer configuration
        await printerApiService.createPrinter(printerData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Printer configuration saved successfully')),
        );
        // Refresh the printer list and reset the form
        _fetchPrinters();
        _resetForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving printer configuration: $e')),
        );
      }
    }
  }

  void _deletePrinter(String printerNumber) async {
    try {
      await printerApiService.deletePrinter(printerNumber);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Printer deleted successfully')),
      );
      // Refresh the printer list
      setState(() {
        printers.removeWhere(
            (item) => item['id'].toString() == printerNumber.toString());
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting printer: $e')),
      );
    }
  }

  void _fetchPrinters() async {
    try {
      final fetchedPrinters = await printerApiService.getPrinters();
      setState(() {
        printers = fetchedPrinters;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching printers: $e')),
      );
    }
  }

  void _resetForm() {
    printerNumberController.clear();
    setState(() {
      printerName = '';
      printerType = 'receipt';
      ipAddress = '';
      port = 9100;
      status = 'active';
      _selectedOutlet = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Printer Configuration')),
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
                  // Outlet Selection Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedOutlet,
                    onChanged: (value) {
                      setState(() {
                        _selectedOutlet = value!;
                      });
                    },
                    items: outlets.map((outlet) {
                      return DropdownMenuItem<String>(
                        value: outlet,
                        child: Text(outlet),
                      );
                    }).toList(),
                    decoration:
                        const InputDecoration(labelText: 'Select Outlet'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: printerNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Printer Number'),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Printer Name'),
                    onSaved: (value) {
                      printerName = value!;
                    },
                  ),
                  const SizedBox(height: 16),
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
                    decoration:
                        const InputDecoration(labelText: 'Printer Type'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    maxLength: 15,
                    decoration: const InputDecoration(labelText: 'IP Address'),
                    onSaved: (value) {
                      ipAddress = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    maxLength: 5,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // Restricts input to digits only
                    ],
                    decoration: const InputDecoration(labelText: 'Port'),
                    onSaved: (value) {
                      port = int.parse(value!);
                    },
                  ),
                  const SizedBox(height: 16),
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
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _savePrinterConfig,
                    child: const Text('Save Printer Configuration'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Display saved printers in a list
            Expanded(
              child: ListView.builder(
                itemCount: printers.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.print, color: Colors.blue),
                      title: Text(
                          'Printer ${printers[index]['printer_number']} - ${printers[index]['printer_name']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Type: ${printers[index]['printer_type']}'),
                          Text('IP: ${printers[index]['ip_address']}'),
                          Text('Port: ${printers[index]['port']}'),
                          Text('Status: ${printers[index]['status']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _deletePrinter(printers[index]['id'].toString()),
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
