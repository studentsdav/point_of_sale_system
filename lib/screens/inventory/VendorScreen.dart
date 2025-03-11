import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class VendorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: VendorScreen(),
    );
  }
}

final vendorProvider = StateProvider<List<Map<String, String>>>((ref) => [
      {"id": "1", "name": "Vendor A", "contact": "John Doe"},
      {"id": "2", "name": "Vendor B", "contact": "Alice Smith"},
    ]);

class VendorScreen extends ConsumerWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendors = ref.watch(vendorProvider);
    return Scaffold(
      appBar: AppBar(title: Text("Vendor Management")),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Add Vendor", style: Theme.of(context).textTheme.bodyMedium),
                      SizedBox(height: 10),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: "Vendor Name", border: OutlineInputBorder()),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: contactController,
                        decoration: InputDecoration(labelText: "Contact Person", border: OutlineInputBorder()),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isNotEmpty && contactController.text.isNotEmpty) {
                            ref.read(vendorProvider.notifier).state = [
                              ...vendors,
                              {"id": DateTime.now().millisecondsSinceEpoch.toString(), "name": nameController.text, "contact": contactController.text},
                            ];
                          }
                        },
                        child: Text("Add Vendor"),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Vendor List", style: Theme.of(context).textTheme.bodyLarge),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: vendors.length,
                          itemBuilder: (context, index) {
                            final vendor = vendors[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Text(vendor["name"] ?? ""),
                                subtitle: Text("Contact: ${vendor["contact"]}"),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    ref.read(vendorProvider.notifier).state =
                                        vendors.where((v) => v["id"] != vendor["id"]).toList();
                                  },
                                ),
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
        ],
      ),
    );
  }
}
