import 'package:flutter/material.dart';

class BillConfigurationForm extends StatefulWidget {
  @override
  _BillConfigurationFormState createState() => _BillConfigurationFormState();
}

class _BillConfigurationFormState extends State<BillConfigurationForm> {
  final _formKey = GlobalKey<FormState>();
  String? selectedOutlet;
  String billPrefix = '';
  String? billSuffix;
  int startingBillNumber = 1;
  DateTime? seriesStartDate;
  String currencySymbol = '₹';
  String dateFormat = 'dd-MM-yyyy';
  final List<Map<String, dynamic>> _configurations = [];

  void _saveConfiguration() {
    if (_formKey.currentState!.validate() && seriesStartDate != null && selectedOutlet != null) {
      _formKey.currentState!.save();
      
      setState(() {
        _configurations.add({
          'outlet': selectedOutlet,
          'billPrefix': billPrefix,
          'billSuffix': billSuffix,
          'startingBillNumber': startingBillNumber,
          'seriesStartDate': seriesStartDate,
          'currencySymbol': currencySymbol,
          'dateFormat': dateFormat,
          'savedOn': DateTime.now(),
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bill Configuration')),
      body: Container(
              color: Colors.white,
              padding: EdgeInsets.all(30),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Outlet',
                      icon: Icon(Icons.store),
                    ),
                    items: ['Outlet 1', 'Outlet 2', 'Outlet 3'].map((outlet) {
                      return DropdownMenuItem(value: outlet, child: Text(outlet));
                    }).toList(),
                    onChanged: (value) => setState(() => selectedOutlet = value),
                    validator: (value) => value == null ? 'Please select an outlet' : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Bill Prefix',
                      icon: Icon(Icons.label),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter a bill prefix' : null,
                    onSaved: (value) => billPrefix = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Bill Suffix',
                      icon: Icon(Icons.label_important),
                    ),
                    onSaved: (value) => billSuffix = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Starting Bill Number',
                      icon: Icon(Icons.format_list_numbered),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => (value == null || int.tryParse(value) == null)
                        ? 'Please enter a valid number'
                        : null,
                    onSaved: (value) => startingBillNumber = int.parse(value!),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
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
                      if (pickedDate != null) setState(() => seriesStartDate = pickedDate);
                    },
                    validator: (_) => seriesStartDate == null ? 'Please select a date' : null,
                    controller: TextEditingController(
                      text: seriesStartDate == null
                          ? ''
                          : "${seriesStartDate!.day}-${seriesStartDate!.month}-${seriesStartDate!.year}",
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Currency Symbol',
                      icon: Icon(Icons.attach_money),
                    ),
                    items: ['₹', '\$', '€'].map((symbol) {
                      return DropdownMenuItem(value: symbol, child: Text(symbol));
                    }).toList(),
                    onChanged: (value) => setState(() => currencySymbol = value!),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Date Format',
                      icon: Icon(Icons.date_range),
                    ),
                    items: ['dd-MM-yyyy', 'MM-dd-yyyy', 'yyyy-MM-dd'].map((format) {
                      return DropdownMenuItem(value: format, child: Text(format));
                    }).toList(),
                    onChanged: (value) => setState(() => dateFormat = value!),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveConfiguration,
                    child: Text('Save Configuration'),
                  ),
                  const SizedBox(height: 20),
                  Text('Saved Configurations:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  
                  // Container to wrap the ListView.builder
                  Expanded(
                    child: ListView.builder(
                      itemCount: _configurations.length,
                      itemBuilder: (context, index) {
                        final config = _configurations[index];
                        final billNumberFormat = '${config['billPrefix']}${config['startingBillNumber']}${config['billSuffix']}';
                        final seriesStartDate = config['seriesStartDate'];
                        final savedOn = config['savedOn'];
                    
                        return ListTile(
                          leading: Icon(Icons.receipt),
                          title: Text(
                            'Your bill no starts from $billNumberFormat from ${seriesStartDate?.day}-${seriesStartDate?.month}-${seriesStartDate?.year} updated on ${savedOn.day}-${savedOn.month}-${savedOn.year} for ${config['outlet']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
}

void main() {
  runApp(MaterialApp(home: BillConfigurationForm()));
}
