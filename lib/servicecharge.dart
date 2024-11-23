import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ServiceChargeConfigForm extends StatefulWidget {
  @override
  _ServiceChargeConfigFormState createState() =>
      _ServiceChargeConfigFormState();
}

class _ServiceChargeConfigFormState extends State<ServiceChargeConfigForm> {
  final _formKey = GlobalKey<FormState>();
  final _chargePercentageController = TextEditingController();
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();
  String _applyOn = 'all bills';
  String _status = 'active';
  String? _selectedOutlet; // Default selected outlet

  // List of available outlets (for example purposes, replace with actual data)
  List<String> outlets = [];

  // Map to store service charges by outlet
  Map<String, List<Map<String, dynamic>>> outletServiceCharges = {};

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
        this.outlets = outletslist; // Set the outlets list
      });
    }
  }

  // Save service charge configuration
  void _saveServiceChargeConfig() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create a new service charge config
      Map<String, dynamic> newServiceCharge = {
        'chargePercentage': _chargePercentageController.text,
        'minAmount': _minAmountController.text,
        'maxAmount': _maxAmountController.text,
        'applyOn': _applyOn,
        'status': _status,
      };

      // Add service charge to the selected outlet's list
      if (outletServiceCharges.containsKey(_selectedOutlet)) {
        outletServiceCharges[_selectedOutlet]!.add(newServiceCharge);
      } else {}

      setState(() {
        // Clear the form fields after saving
        _chargePercentageController.clear();
        _minAmountController.clear();
        _maxAmountController.clear();
        _applyOn = 'all bills';
        _status = 'active';
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Service charge configuration saved')));
    }
  }

  // Delete a service charge configuration
  void _deleteServiceCharge(String outlet, int index) {
    setState(() {
      outletServiceCharges[outlet]!.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service charge configuration deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Service Charge Configuration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form to input Service Charge details
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
                    decoration: InputDecoration(labelText: 'Select Outlet'),
                  ),

                  SizedBox(height: 16),
                  // Charge Percentage Input
                  TextFormField(
                    controller: _chargePercentageController,
                    decoration: InputDecoration(
                      labelText: 'Charge Percentage',
                      prefixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // Restricts input to digits only
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a charge percentage';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Min Amount Input
                  TextFormField(
                    controller: _minAmountController,
                    decoration: InputDecoration(
                      labelText: 'Min Amount',
                      prefixText: '₹',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // Restricts input to digits only
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a minimum amount';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Max Amount Input
                  TextFormField(
                    controller: _maxAmountController,
                    decoration: InputDecoration(
                      labelText: 'Max Amount',
                      prefixText: '₹',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // Restricts input to digits only
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a maximum amount';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Apply On Dropdown
                  DropdownButtonFormField<String>(
                    value: _applyOn,
                    onChanged: (value) {
                      setState(() {
                        _applyOn = value!;
                      });
                    },
                    items: ['all bills', 'specific outlets'].map((applyOn) {
                      return DropdownMenuItem<String>(
                        value: applyOn,
                        child: Text(applyOn),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Apply On'),
                  ),
                  SizedBox(height: 16),
                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: _status,
                    onChanged: (value) {
                      setState(() {
                        _status = value!;
                      });
                    },
                    items: ['active', 'inactive'].map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Status'),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveServiceChargeConfig,
                    child: Text('Save Service Charge Configuration'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Display saved service charge configurations outlet-wise
            Expanded(
              child: ListView.builder(
                itemCount: outletServiceCharges.keys.length,
                itemBuilder: (context, index) {
                  String outlet = outletServiceCharges.keys.elementAt(index);
                  List<Map<String, dynamic>> serviceCharges =
                      outletServiceCharges[outlet]!;

                  return ExpansionTile(
                    title: Text(outlet),
                    leading: Icon(Icons.store),
                    children: serviceCharges.map((serviceCharge) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          leading:
                              Icon(Icons.attach_money, color: Colors.green),
                          title: Text(
                              'Charge: ${serviceCharge['chargePercentage']}%'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Min: ₹${serviceCharge['minAmount']}'),
                              Text('Max: ₹${serviceCharge['maxAmount']}'),
                              Text('Apply On: ${serviceCharge['applyOn']}'),
                              Text('Status: ${serviceCharge['status']}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteServiceCharge(
                                outlet, serviceCharges.indexOf(serviceCharge)),
                          ),
                        ),
                      );
                    }).toList(),
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
