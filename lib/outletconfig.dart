import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:point_of_sale_system/backend/outlet_service.dart';

class OutletConfigurationForm extends StatefulWidget {
  @override
  _OutletConfigurationFormState createState() =>
      _OutletConfigurationFormState();
}

class _OutletConfigurationFormState extends State<OutletConfigurationForm> {
    final OutletApiService apiService = OutletApiService(baseUrl: 'http://localhost:3000/api');
  List<dynamic> properties = [];
  List<dynamic> outletConfigurations = [];
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  String? selectedProperty;
  String outletName = '';
  String address = '';
  String contactNumber = '';
  String managerName = '';
  String openingHours = '';
  bool isSaved = false;

@override
void initState(){
  _initializeHive();
  _loadData();
  super.initState();
}



Future<void> _loadDatanew() async {
  try {
    final fetchedProperties = await apiService.getAllProperties();
    final fetchedOutletConfigurations = await apiService.fetchOutletConfigurations();

    // If your data is in JSON format, you should decode it first:
    // List<dynamic> jsonData = json.decode(fetchedProperties);
    List<Map<String, dynamic>> propertiesList = List<Map<String, dynamic>>.from(fetchedProperties);
    List<Map<String, dynamic>> outletConfigurationsList = List<Map<String, dynamic>>.from(fetchedOutletConfigurations);

    // Save data to SharedPreferences
    await _saveDataToHive(propertiesList, outletConfigurationsList);

    setState(() {
      properties = propertiesList;
      outletConfigurations = outletConfigurationsList;
      isLoading = false;
    });
  } catch (error) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load data: $error')),
    );
  }
}

   // Method to save fetched data into SharedPreferences
Future<void> _initializeHive() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
}

Future<void> _saveDataToHive(
    List<Map<String, dynamic>> properties,
    List<Map<String, dynamic>> outletConfigurations) async {
  var box = await Hive.openBox('appData');
  
  // Store the data in a Hive box
  await box.put('properties', properties);
  await box.put('outletConfigurations', outletConfigurations);
}













  Future<void> _loadData() async {
    try {
      final fetchedProperties = await apiService.getAllProperties();
      final fetchedOutletConfigurations = await apiService.fetchOutletConfigurations();
      setState(() {
        properties = fetchedProperties;
        outletConfigurations = fetchedOutletConfigurations;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $error')),
      );
    }
  }


void _saveOutletConfiguration() async {
  if (_formKey.currentState!.validate() && selectedProperty != null) {
    _formKey.currentState!.save();
    final outletData = {
      'property_id': int.parse(selectedProperty!),
      'outlet_name': outletName,
      'address': address,
      'contact_number': contactNumber,
      'manager_name': managerName,
      'opening_hours': openingHours,
      'currency':"\$",
      'city':"Dehradun",
      'country':"India",
      'state':"Uttarakhand"
    };

    try {
      await apiService.createOutletConfiguration(outletData);
      setState(() {
        isSaved = true;
        _loadDatanew() ;
        _loadData();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Outlet configuration saved successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save outlet configuration: $error')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill all required fields.')),
    );
  }
}

  void _editOutletConfiguration() {

    setState(() {
      isSaved = false;
    });
  }

    Future<void> deleteOutletConfiguration(id) async {
       try {
   await apiService.deleteOutletConfiguration(id);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Outlet deleted successfully!')),
      );
  _loadData();
       }catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete outlet: $e')),
      );
       }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Outlet Configuration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Selection (Mandatory First)
            Text('Select Property', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Property',
                icon: Icon(Icons.home),
              ),
      items: properties.map<DropdownMenuItem<String>>((property) {
                    return DropdownMenuItem<String>(
                      value: property['property_id'].toString(),
                      child: Text(property['property_name']),
                    );
                  }).toList(),
              onChanged: (value) => setState(() => selectedProperty = value),
              validator: (value) => value == null ? 'Please select a property' : null,
            ),
            const SizedBox(height: 20),

            // Outlet Configuration Form
            Text('Enter Outlet Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Outlet Name',
                      icon: Icon(Icons.store),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter outlet name' : null,
                    onSaved: (value) => outletName = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Address',
                      icon: Icon(Icons.location_on),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter address' : null,
                    onSaved: (value) => address = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Contact Number',
                      icon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? 'Please enter contact number' : null,
                    onSaved: (value) => contactNumber = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Manager Name',
                      icon: Icon(Icons.person),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter manager name' : null,
                    onSaved: (value) => managerName = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Opening Hours',
                      icon: Icon(Icons.access_time),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter opening hours' : null,
                    onSaved: (value) => openingHours = value!,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveOutletConfiguration,
                    child: Text('Save Outlet Configuration'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Show Outlet Profile (if saved)
       isLoading
    ? Center(child: CircularProgressIndicator())
    : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Outlet Profiles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...outletConfigurations.map((config) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue.shade50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Outlet Profile: ${config['property_id']}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.green),
                          onPressed: () {
                            // Implement edit functionality here
                            _editOutletConfiguration();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Implement delete functionality here
                            deleteOutletConfiguration(config['id'].toString());
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.store, size: 30, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(config['outlet_name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 30, color: Colors.blue),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(config['address'], style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 30, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(config['contact_number'], style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.person, size: 30, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(config['manager_name'], style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 30, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(config['opening_hours'], style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),

          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: OutletConfigurationForm()));
}
