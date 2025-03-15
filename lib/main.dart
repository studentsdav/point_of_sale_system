import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:point_of_sale_system/model/discount_model.dart';
import 'package:point_of_sale_system/model/packing_charge_model.dart';
import 'package:point_of_sale_system/model/service_charge_model.dart';

import 'backend/settings/outlet_service.dart';
import 'model/delivery_charge_model.dart';
import 'screens/users/poslogin.dart';

final OutletApiService apiService =
    OutletApiService(baseUrl: 'http://localhost:3000/api');
void main() async {
  await _initializeHive();
  Hive.registerAdapter(DiscountModelAdapter()); // Register the adapter
  Hive.registerAdapter(ServiceChargeModelAdapter()); // Register the new model
  Hive.registerAdapter(DeliveryChargeModelAdapter());
  Hive.registerAdapter(PackingChargeModelAdapter());

  await _loadData();
  runApp(const MyApp());
}

// Method to save fetched data into SharedPreferences
Future<void> _initializeHive() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
}

Future<void> _loadData() async {
  try {
    // Fetch properties
    List<Map<String, dynamic>> propertiesList = [];
    try {
      final fetchedProperties = await apiService.getAllProperties();
      if (fetchedProperties.isNotEmpty) {
        propertiesList = List<Map<String, dynamic>>.from(fetchedProperties);
        await _saveDataToHiveproperty(propertiesList);
        print('Properties saved successfully.');
      }
    } catch (error) {
      print('Error fetching properties: $error');
    }

    // Fetch outlet configurations
    List<Map<String, dynamic>> outletConfigurationsList = [];
    try {
      final fetchedOutletConfigurations =
          await apiService.fetchOutletConfigurations();
      if (fetchedOutletConfigurations.isNotEmpty) {
        outletConfigurationsList =
            List<Map<String, dynamic>>.from(fetchedOutletConfigurations);
        await _saveDataToHiveoutlet(outletConfigurationsList);
        print('Outlet configurations saved successfully.');
      }
    } catch (error) {
      print('Error fetching outlet configurations: $error');
    }

    // Log final status
    if (propertiesList.isEmpty && outletConfigurationsList.isEmpty) {
      print('No data fetched for both properties and outlet configurations.');
    }
  } catch (error) {
    print('Unexpected error: $error');
  }
}

Future<void> _saveDataToHiveproperty(
  List<Map<String, dynamic>> properties,
) async {
  var box = await Hive.openBox('appData');
  // Store the data in a Hive box
  await box.put('properties', properties);
}

Future<void> _saveDataToHiveoutlet(
    List<Map<String, dynamic>> outletConfigurations) async {
  var box = await Hive.openBox('appData');

  await box.put('outletConfigurations', outletConfigurations);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State {
  List<String> outlets = []; // List of outlets to select
  List<dynamic> properties = [];
  List<dynamic> outletConfigurations = [];
  @override
  void initState() {
    super.initState();
    _loadDataFromHive();
  }

  // Load data from Hive
  Future<void> _loadDataFromHive() async {
    try {
      var box = await Hive.openBox('appData');

      // Retrieve the data
      var properties = box.get('properties');
      var outletConfigurations = box.get('outletConfigurations');

      // Check for null in both properties and outletConfigurations
      properties ??= [];
      outletConfigurations ??= [];

      // Extract outlet names (with null checks)
      List<String> outletslist = [];
      if (outletConfigurations != null) {
        for (var outlet in outletConfigurations) {
          if (outlet['outlet_name'] != null) {
            outletslist.add(outlet['outlet_name'].toString());
          }
        }
      }

      setState(() {
        this.properties = properties;
        this.outletConfigurations = outletConfigurations;
        outlets = outletslist; // Set the outlets list
      });
    } catch (error) {
      print(error);
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Point Of Sale',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a Colors.teal toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: POSLoginScreen(
          propertyid: properties[0]['property_id'] ?? 0,
          outlet: outlets,
        ));
    //   home: const MyHomePage(
    //     title: "POS",
    //   ),
    // );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
