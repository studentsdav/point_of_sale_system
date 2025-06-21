import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../backend/api_config.dart';
import '../../backend/inventory/vendor_service.dart';

final vendorProvider = StateProvider<List<Map<String, String>>>((ref) => [
      {"id": "1", "name": "Vendor A", "contact": "John Doe"},
      {"id": "2", "name": "Vendor B", "contact": "Alice Smith"},
    ]);

class VendorScreen extends ConsumerStatefulWidget {
  VendorScreen({super.key});

  @override
  ConsumerState<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends ConsumerState<VendorScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final VendorService vendorService = VendorService(apiBaseUrl);

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    final data = await vendorService.getAllVendors();
    ref.read(vendorProvider.notifier).state =
        List<Map<String, String>>.from(data.map((v) => {
              'id': v['id'].toString(),
              'name': v['name'] ?? '',
              'contact': v['contact'] ?? '',
            }));
  }

  Future<void> _addVendor() async {
    if (nameController.text.isNotEmpty && contactController.text.isNotEmpty) {
      await vendorService.createVendor({
        'name': nameController.text,
        'contact': contactController.text,
      });
      await _loadVendors();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendors = ref.watch(vendorProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Vendor Management")),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Add Vendor",
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 10),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                            labelText: "Vendor Name",
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: contactController,
                        decoration: const InputDecoration(
                            labelText: "Contact Person",
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _addVendor,
                        child: const Text("Add Vendor"),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Vendor List",
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: vendors.length,
                          itemBuilder: (context, index) {
                            final vendor = vendors[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Text(vendor["name"] ?? ""),
                                subtitle: Text("Contact: ${vendor["contact"]}"),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    await vendorService.deleteVendor(
                                        int.parse(vendor["id"] ?? '0'));
                                    await _loadVendors();
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
