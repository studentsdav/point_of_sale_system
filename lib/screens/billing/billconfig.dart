import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../backend/api_config.dart';
import '../../backend/settings/bill_api_service.dart';

class BillConfigurationForm extends StatefulWidget {
  const BillConfigurationForm({super.key});

  @override
  _BillConfigurationFormState createState() => _BillConfigurationFormState();
}

class _BillConfigurationFormState extends State<BillConfigurationForm> {
  final _formKey = GlobalKey<FormState>();
  final BillApiService apiService =
      BillApiService(baseUrl: '$apiBaseUrl/bill-config');
  String? selectedOutlet;
  String billPrefix = '';
  String? billSuffix;
  int startingBillNumber = 1;
  DateTime? seriesStartDate;
  String currencySymbol = '₹';
  String dateFormat = 'dd-MM-yyyy';
  final List<Map<String, dynamic>> _configurations = [];
  List<String> outlets = [];
  List<dynamic> properties = [];
  List<dynamic> outletConfigurations = [];

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
  }

  List<Map<String, dynamic>> _parseJson(String jsonString) {
    // You can use a JSON decoder if you save the data in a valid JSON format
    return jsonString.isNotEmpty ? List<Map<String, dynamic>>.from([]) : [];
  }

  @override
  void initState() {
    super.initState();
    _loadDataFromHive();
    _loadConfigurations();
  }

  void _loadConfigurations() async {
    try {
      final configurations = await apiService.fetchConfigurations();

      setState(() {
        _configurations.clear();
        _configurations.addAll(
          configurations
              .cast<Map<String, dynamic>>(), // Explicitly cast the list
        );
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load configurations')),
      );
    }
  }

  void _saveConfiguration() async {
    if (_formKey.currentState!.validate() &&
        seriesStartDate != null &&
        selectedOutlet != null) {
      _formKey.currentState!.save();

      final newConfig = {
        'property_id': properties[0]['property_id'], // Example property ID
        'selected_outlet': selectedOutlet,
        'bill_prefix': billPrefix,
        'bill_suffix': billSuffix,
        'starting_bill_number': startingBillNumber,
        'series_start_date': seriesStartDate!.toIso8601String(),
        'currency_symbol': currencySymbol,
        'date_format': dateFormat,
      };

      try {
        await apiService.createConfiguration(newConfig);
        _loadConfigurations();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save configuration')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
    }
  }

  Future<void> _deleteConfiguration(id) async {
    // Add the delete logic here, e.g., making an API call
    // For example:
    await apiService.deleteConfiguration(id);
    setState(() {
      _configurations.removeWhere((config) => config['config_id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bill Configuration')),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(30),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Outlet',
                      icon: Icon(Icons.store),
                    ),
                    items: outlets.map((outlet) {
                      return DropdownMenuItem(
                          value: outlet, child: Text(outlet));
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedOutlet = value),
                    validator: (value) =>
                        value == null ? 'Please select an outlet' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Bill Prefix',
                      icon: Icon(Icons.label),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a bill prefix' : null,
                    onSaved: (value) => billPrefix = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Bill Suffix',
                      icon: Icon(Icons.label_important),
                    ),
                    onSaved: (value) => billSuffix = value,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Starting Bill Number',
                      icon: Icon(Icons.format_list_numbered),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        (value == null || int.tryParse(value) == null)
                            ? 'Please enter a valid number'
                            : null,
                    onSaved: (value) => startingBillNumber = int.parse(value!),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Series Start Date',
                      icon: Icon(Icons.date_range),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null)
                        setState(() => seriesStartDate = pickedDate);
                    },
                    validator: (_) =>
                        seriesStartDate == null ? 'Please select a date' : null,
                    controller: TextEditingController(
                      text: seriesStartDate == null
                          ? ''
                          : "${seriesStartDate!.day}-${seriesStartDate!.month}-${seriesStartDate!.year}",
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Currency Symbol',
                      icon: Icon(Icons.attach_money),
                    ),
                    items: ['₹', '\$', '€'].map((symbol) {
                      return DropdownMenuItem(
                          value: symbol, child: Text(symbol));
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => currencySymbol = value!),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Date Format',
                      icon: Icon(Icons.date_range),
                    ),
                    items: ['dd-MM-yyyy', 'MM-dd-yyyy', 'yyyy-MM-dd']
                        .map((format) {
                      return DropdownMenuItem(
                          value: format, child: Text(format));
                    }).toList(),
                    onChanged: (value) => setState(() => dateFormat = value!),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveConfiguration,
                    child: const Text('Save Configuration'),
                  ),
                  const SizedBox(height: 20),
                  const Text('Saved Configurations:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _configurations.length,
                      itemBuilder: (context, index) {
                        final config = _configurations[index];
                        final billNumberFormat =
                            '${config['bill_prefix']}${config['starting_bill_number']}${config['bill_suffix']}';
                        final seriesStartDate = config['series_start_date'];
                        final savedOn = config['updated_at'];

                        return ListTile(
                          leading: const Icon(Icons.receipt),
                          title: Text(
                            'Your bill no starts from $billNumberFormat from '
                            '${seriesStartDate != null ? _formatDate(seriesStartDate) : "N/A"} '
                            'updated on '
                            '${savedOn != null ? _formatDate(savedOn) : "N/A"} '
                            'for ${config['selected_outlet'] ?? "Unknown Outlet"}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              // Trigger the delete functionality here
                              _deleteConfiguration(config[
                                  'config_id']); // Assuming there's an ID in the configuration
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
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

void main() {
  runApp(const MaterialApp(home: BillConfigurationForm()));
}
