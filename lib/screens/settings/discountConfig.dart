import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../backend/settings/discountApiService.dart';

class DiscountConfigForm extends StatefulWidget {
  const DiscountConfigForm({super.key});

  @override
  _DiscountConfigFormState createState() => _DiscountConfigFormState();
}

class _DiscountConfigFormState extends State<DiscountConfigForm> {
  DiscountApiService discountApiService =
      DiscountApiService(baseUrl: 'http://localhost:3000/api');
  final _formKey = GlobalKey<FormState>();
  final _feePercentageController = TextEditingController();
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();
  final _typetController = TextEditingController();
  String _applyOn = 'all bills';
  String _status = 'active';
  String? _selectedOutlet; // Default selected outlet

  // List of available outlets (for example purposes, replace with actual data)
  List<String> outlets = [];

  // Map to store Discount Fee by outlet
  Map<String, List<Map<String, dynamic>>> outletDiscount = {};

  List<dynamic> properties = [];
  List<dynamic> outletConfigurations = [];
  DateTime? startDate;

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
    _fetchDiscount();
  }

  Future<void> _fetchDiscount() async {
    try {
      List<Map<String, dynamic>> discount =
          await discountApiService.getDiscountConfigurations();

      // Organize Discount Fee by outlet
      Map<String, List<Map<String, dynamic>>> organizedfees = {};
      for (var fee in discount) {
        String outletName = fee['outlet_name'] ?? 'Unknown Outlet';
        if (!organizedfees.containsKey(outletName)) {
          organizedfees[outletName] = [];
        }
        organizedfees[outletName]!.add(fee);
      }
      setState(() {
        outletDiscount = organizedfees;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetchingDiscount Fee: $e')));
    }
  }

  // Save  Discount Fee configuration
  void _saveDiscountConfig() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Map<String, dynamic> newDiscount = {
        'property_id': properties.first['property_id'],
        'discount_value': double.parse(_feePercentageController.text),
        'min_amount': double.parse(_minAmountController.text),
        'max_amount': double.parse(_maxAmountController.text),
        'apply_on': _applyOn,
        'status': _status,
        'start_date': startDate?.toIso8601String(),
        'outlet_name': _selectedOutlet.toString(),
        'discount_type': _typetController.text
      };

      // Check if the combination of property_id and outlet_name already exists
      String propertyId = newDiscount['property_id'].toString();
      String outletName = newDiscount['outlet_name'];

      bool exists = outletDiscount.containsKey(outletName) &&
          outletDiscount[outletName]!.any(
            (fee) => fee['property_id'].toString() == propertyId.toString(),
          );

      try {
        if (exists) {
          // Update the existing Discount Fee configuration
          String configId = outletDiscount[outletName]!
              .firstWhere((fee) =>
                  fee['property_id'].toString() == propertyId.toString())['id']
              .toString();

          await discountApiService.updateDiscountConfiguration(
            configId,
            newDiscount,
          );

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Service fee updated successfully')));
        } else {
          // Create a new Discount Fee configuration
          await discountApiService.createDiscountConfiguration(newDiscount);

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Service fee created successfully')));
        }

        _fetchDiscount(); // Refresh the UI
        _clearFormFields();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving Discount Fee: $e')));
      }
    }
  }

  void _editDiscount(String configId, Map<String, dynamic> updatedData) async {
    try {
      await discountApiService.updateDiscountConfiguration(
          configId, updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service fee updated successfully')));
      _fetchDiscount(); // Refresh the UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating Discount Fee: $e')));
    }
  }

  void _deleteDiscount(String configId, String outlet, int index) async {
    try {
      await discountApiService.deleteDiscountConfiguration(configId);

      setState(() {
        outletDiscount[outlet]!
            .removeWhere((fee) => fee['id'].toString() == configId.toString());
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service fee deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting Discount Fee: $e')));
    }
  }

  void _clearFormFields() {
    setState(() {
      _feePercentageController.clear();
      _minAmountController.clear();
      _maxAmountController.clear();
      _typetController.clear();
      _applyOn = 'all bills';
      _status = 'active';
      _selectedOutlet = null;
      startDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discount Configuration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form to input Discount Fee details
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
                  // Max Amount Input
                  TextFormField(
                    maxLength: 50,
                    controller: _typetController,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      prefixText: '',
                    ),
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a maximum amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // fee Percentage Input
                  TextFormField(
                    maxLength: 3,
                    controller: _feePercentageController,
                    decoration: const InputDecoration(
                      labelText: 'MAX Percentage',
                      prefixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // Restricts input to digits only
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a fee percentage';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Min Amount Input
                  TextFormField(
                    maxLength: 8,
                    controller: _minAmountController,
                    decoration: const InputDecoration(
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
                  const SizedBox(height: 16),
                  // Max Amount Input
                  TextFormField(
                    maxLength: 8,
                    controller: _maxAmountController,
                    decoration: const InputDecoration(
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
                  const SizedBox(height: 16),
                  // Start Date
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Start Date (yyyy-MM-dd)'),
                    keyboardType: TextInputType.datetime,
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (selectedDate != null && selectedDate != startDate) {
                        setState(() {
                          startDate = selectedDate;
                        });
                      }
                    },
                    controller: TextEditingController(
                        text: startDate != null
                            ? "${startDate!.toLocal()}".split(' ')[0]
                            : ''),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a start date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
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
                    decoration: const InputDecoration(labelText: 'Apply On'),
                  ),
                  const SizedBox(height: 16),
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
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveDiscountConfig,
                    child: const Text('Save  Discount Fee Configuration'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Display saved Discount Fee configurations outlet-wise
            Expanded(
              child: ListView.builder(
                itemCount: outletDiscount.keys.length,
                itemBuilder: (context, index) {
                  String outlet = outletDiscount.keys.elementAt(index);
                  List<Map<String, dynamic>> discount = outletDiscount[outlet]!;

                  return ExpansionTile(
                    title: Text(outlet),
                    leading: const Icon(Icons.store),
                    children: discount.map((discount) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.attach_money,
                              color: Colors.green),
                          title: Text(
                              'Discount %: ${discount['discount_value']}%'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Min: ₹${discount['min_amount']}'),
                              Text('Max: ₹${discount['max_amount']}'),
                              Text('Apply On: ${discount['apply_on']}'),
                              Text('Status: ${discount['status']}'),
                              Text(
                                  'Start Date: ${Getdateormat.formatDate(discount['start_date'])}'),
                              Text('Outlet Name: ${discount['outlet_name']}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteDiscount(
                                discount['id'].toString(),
                                discount['outlet_name'],
                                index),
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

class Getdateormat {
  static String formatDate(dynamic date) {
    try {
      if (date is String) {
        final parsedDate =
            DateTime.parse(date).toLocal(); // Convert to local timezone
        return "${parsedDate.day}-${parsedDate.month}-${parsedDate.year}";
      } else if (date is DateTime) {
        return "${date.toLocal().day}-${date.toLocal().month}-${date.toLocal().year}";
      }
    } catch (e) {
      print("Error formatting date: $e");
    }
    return "Invalid Date";
  }
}
