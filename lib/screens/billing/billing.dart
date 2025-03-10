import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../backend/billing/bill_service.dart';
import '../../backend/guestmanage/guest_record_api_service.dart';
import '../../backend/order/OrderApiService.dart';
import '../../backend/settings/deliveryApiService.dart';
import '../../backend/settings/discountApiService.dart';
import '../../backend/settings/packingChargeApiService.dart';
import '../../backend/settings/serviceChargeApiService.dart';

class BillingFormScreen extends StatefulWidget {
  final tableno;
  final propertyid;
  final outlet;
  const BillingFormScreen(
      {super.key,
      required this.propertyid,
      required this.outlet,
      required this.tableno});

  @override
  _BillingFormScreenState createState() => _BillingFormScreenState();
}

class _BillingFormScreenState extends State<BillingFormScreen> {
  BillingApiService billingApiService =
      BillingApiService(baseUrl: 'http://localhost:3000/api');
  OrderApiService orderApiService =
      OrderApiService(baseUrl: 'http://localhost:3000/api');
  GuestRecordApiService guestRecordApiService =
      GuestRecordApiService(baseUrl: 'http://localhost:3000/api');
  DiscountApiService discountApiService =
      DiscountApiService(baseUrl: 'http://localhost:3000/api');
  PackingChargeApiService packingApiService =
      PackingChargeApiService(baseUrl: 'http://localhost:3000/api');
  DeliveryApiService deliveryApiService =
      DeliveryApiService(baseUrl: 'http://localhost:3000/api');
  List<Map<dynamic, dynamic>> discountList = [
    {}
  ]; // Variable to store discounts
  List<Map<dynamic, dynamic>> packingList = [{}]; // Variable to store discounts
  List<Map<dynamic, dynamic>> deliveryList = [
    {}
  ]; // Variable to store discounts
  List<Map<dynamic, dynamic>> serviceList = [{}]; // Variable to store discounts

  ServiceChargeApiService serviceChargeApiService =
      ServiceChargeApiService(baseUrl: 'http://localhost:3000/api');

  final TextEditingController _billNoController = TextEditingController();
  final TextEditingController _orderNoController =
      TextEditingController(text: 'ORD67890');
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _tableNoController = TextEditingController();
  final TextEditingController _guestIdController = TextEditingController();
  final TextEditingController _guestSearchController = TextEditingController();
  final TextEditingController _paxController = TextEditingController(text: '1');
  final TextEditingController _flatDiscountController = TextEditingController();
  final TextEditingController _percentDiscountController =
      TextEditingController();
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> orderItems = [];
  String selectedOrderId = "";
  bool isLoadingOrders = true;
  bool isLoadingItems = false;
  bool isFlatDiscount = false;
  bool _isInitialized = false;
  String _discountType = 'Percentage'; // Default to Percentage Discount

  // Mock data for items
  // final List<Map<String, dynamic>> _items = List.generate(10, (index) {
  //   return {
  //     'sno': index + 1,
  //     'name': 'Item ${index + 1}',
  //     'qty': 1,
  //     'rate': 100.0,
  //     'amount': 100.0,
  //     'tax': 5.0,
  //     'discount_amount': 10.0,
  //     'happy_hour_discount': 5.0,
  //     'scheme': 'None',
  //     'category': 'Category ${index % 3}',
  //   };
  // });
  Map<String, Map<String, dynamic>> itemMap = {};
  List<Map<String, dynamic>> _guestRecords = [];

  bool _isloading = false;

  @override
  void initState() {
    _tableNoController.text = widget.tableno;
    _fetchAllData();
    super.initState();
  }

  _fetchAllData() async {
    setState(() {
      _isloading = true;
    });
    await _fetchOrders();

    await fetchDiscounts();

    await fetchpacking();

    await fetchService();

    await fetchDelivery();

    await generateBillId();
    setState(() {
      _isloading = false;
    });
  }

  Future<void> fetchDiscounts() async {
    try {
      List<Map<dynamic, dynamic>> fetchedDiscounts =
          await discountApiService.getDiscountConfigurations();

      setState(() {
        discountList = fetchedDiscounts; // Store fetched values in the variable
      });
    } catch (e) {
      print('Error fetching discounts: $e');
    }
  }

  Future<void> fetchpacking() async {
    try {
      List<Map<dynamic, dynamic>> fetchedPacking =
          await packingApiService.getPackingChargeConfigurations();

      setState(() {
        packingList = fetchedPacking; // Store fetched values in the variable
      });
    } catch (e) {
      print('Error fetching discounts: $e');
    }
  }

  Future<void> fetchService() async {
    try {
      List<Map<dynamic, dynamic>> fetchedService =
          await serviceChargeApiService.getServiceChargeConfigurations();

      setState(() {
        serviceList = fetchedService; // Store fetched values in the variable
      });
    } catch (e) {
      print('Error fetching discounts: $e');
    }
  }

  Future<void> fetchDelivery() async {
    try {
      List<Map<dynamic, dynamic>> fetchedDelivery =
          await deliveryApiService.getDeliveryCharges();

      setState(() {
        deliveryList = fetchedDelivery; // Store fetched values in the variable
      });
    } catch (e) {
      print('Error fetching discounts: $e');
    }
  }

  void _reset() {
    setState(() {
      // Clear selected order and items
      selectedOrderId = ''; // Clear selected order ID
      itemMap.clear(); // Clear the item map (which holds order items)
      orderItems.clear(); // Clear the list of order items
      // Optionally, fetch all orders again if needed
      _fetchOrders(); // This function will reload the orders list from the API or database
    });
  }

  Future<void> _fetchOrders() async {
    setState(() {
      isLoadingOrders = true;
    });

    try {
      // Fetch orders by table and status (assuming this fetches the 10 orders)
      orders = await orderApiService.getOrdersByTableAndStatus(
          widget.tableno, 'Pending');

      // Check if there are orders, then extract their IDs
      if (orders.isNotEmpty) {
        // Extract all order IDs from the fetched orders
        List<String> orderIds =
            orders.map((order) => order['order_id'].toString()).toList();

        // Fetch items for all selected orders
        _fetchOrderItems(orderIds);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching orders: $e')),
      );
    } finally {
      setState(() {
        isLoadingOrders = false;
      });
    }
  }

  Future<void> _fetchOrderItems(List<String> orderIds) async {
    setState(() {
      isLoadingItems = true;
    });

    try {
      // Fetch items for all selected orders
      final fetchedItems = await orderApiService.getOrderItemsByIds(orderIds);

      // Process fetched items
      for (var item in [...orderItems, ...fetchedItems]) {
        final key = item['item_name'];

        // Safely parse item quantity, rate, and tax
        int itemQuantity = 0;
        if (item['item_quantity'] != null) {
          if (item['item_quantity'] is String) {
            itemQuantity = int.tryParse(item['item_quantity']) ?? 0;
          } else if (item['item_quantity'] is int) {
            itemQuantity = item['item_quantity'] as int;
          }
        }

        double itemRate = 0.0;
        if (item['item_rate'] != null) {
          if (item['item_rate'] is String) {
            itemRate = double.tryParse(item['item_rate']) ?? 0.0;
          } else if (item['item_rate'] is double) {
            itemRate = item['item_rate'] as double;
          }
        }

        int taxRate = 0;
        if (item['taxrate'] != null && item['taxrate'] is int) {
          taxRate = item['taxrate'];
        }

        double taxAmount = (itemRate * taxRate) / 100; // Calculate tax amount

        if (itemMap.containsKey(key)) {
          itemMap[key]!['quantity'] += itemQuantity;
          itemMap[key]!['taxval'] +=
              taxAmount * itemQuantity; // Add tax to total tax
          itemMap[key]!['total'] = (itemMap[key]!['quantity'] * itemRate) +
              itemMap[key]!['tax']; // Total = price + tax
        } else {
          itemMap[key] = {
            'sno': itemMap.length + 1,
            'item_name': item['item_name'],
            'quantity': itemQuantity,
            'price': itemRate,
            'taxval': taxAmount * itemQuantity, // Total tax for this item
            'tax': taxRate,
            'discountable': item['discountable'],
            'total': (itemQuantity * itemRate) +
                (taxAmount * itemQuantity), // Total price + tax
            'order_id': item['order_id'],
          };
        }
      }

      setState(() {
        orderItems = itemMap.values.toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching order items: ${e.toString()}')),
      );
      print("Error: $e");
    } finally {
      setState(() {
        isLoadingItems = false;
      });
    }
  }

  Future<void> _fetchOrderItemsnew(List<String> orderIds) async {
    setState(() {
      isLoadingItems = true;
    });

    try {
      // Fetch items for all selected orders
      final fetchedItems = await orderApiService.getOrderItemsByIds(orderIds);

      // Clear previous order items
      itemMap.clear();

      // Process fetched items
      for (var item in fetchedItems) {
        final key = item['item_name'];

        // Safely parse item quantity, rate, and tax
        int itemQuantity = 0;
        if (item['item_quantity'] != null) {
          if (item['item_quantity'] is String) {
            itemQuantity = int.tryParse(item['item_quantity']) ?? 0;
          } else if (item['item_quantity'] is int) {
            itemQuantity = item['item_quantity'] as int;
          }
        }

        double itemRate = 0.0;
        if (item['item_rate'] != null) {
          if (item['item_rate'] is String) {
            itemRate = double.tryParse(item['item_rate']) ?? 0.0;
          } else if (item['item_rate'] is double) {
            itemRate = item['item_rate'] as double;
          }
        }

        int taxRate = 0;
        if (item['taxrate'] != null && item['taxrate'] is int) {
          taxRate = item['taxrate'];
        }

        // Calculate tax amount and total including tax
        double taxAmount = (itemRate * taxRate) / 100; // Tax per unit
        double totalAmount =
            (itemQuantity * itemRate) + (itemQuantity * taxAmount);

        // Add item to the map
        itemMap[key] = {
          'sno': itemMap.length + 1,
          'item_name': item['item_name'],
          'quantity': itemQuantity,
          'price': itemRate,
          'taxval': taxAmount * itemQuantity, // Total tax for this item
          'tax': taxRate,
          'discountable': item['discountable'],
          'total': totalAmount, // Total price including tax
          'order_id': item['order_id'],
        };
      }

      setState(() {
        orderItems = itemMap.values.toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching order items: ${e.toString()}')),
      );
      print("Error: $e");
    } finally {
      setState(() {
        isLoadingItems = false;
      });
    }
  }

  List<Map<String, dynamic>> convertItemMapToList(
      Map<String, dynamic> itemMap) {
    return itemMap.entries.map((entry) {
      final dynamic value = entry.value; // Extract value
      if (value is Map) {
        return {
          "key": entry.key.toString(), // Ensure key is String
          ...value
              .cast<String, dynamic>(), // Cast value to Map<String, dynamic>
        };
      }
      return {"key": entry.key.toString()};
    }).toList();
  }

  Future<void> generateBillId() async {
    final maxBillNo = await billingApiService.getMaxBillNo(widget.outlet);
    _billNoController.text = maxBillNo['nextBillNumber'];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _dateController.text = DateTime.now().toString().split(' ')[0];
      _timeController.text = TimeOfDay.now().format(context);
      _isInitialized = true;
    }
  }

  Future<void> _searchGuest(query) async {
    if (query.isEmpty) {
      setState(() {
        _guestRecords = [];
      });
      return;
    }

    try {
      final result = await guestRecordApiService.searchRecords(query);
      setState(() {
        _guestRecords = result;
      });
    } catch (error) {
      print('Error searching guests: $error');
    }
  }

  Future<void> _saveBill() async {
    try {
      // Assuming itemMap is already populated
      List<Map<String, dynamic>> updatedItems = [];

      double servicechargeValue =
          double.parse(serviceList[0]['service_charge'] ?? "0.0");
      double packingChargeValue =
          double.parse(packingList[0]['packing_charge'] ?? "0.0");
      double deliveryChargeValue =
          double.parse(deliveryList[0]['delivery_charge'] ?? "0.0");

      // Get user input for discount
      double discountPercentageInput =
          double.tryParse(_percentDiscountController.text) ??
              0.0; // Input percentage discount
      double flatDiscountInput =
          double.tryParse(_flatDiscountController.text) ??
              0.0; // Input flat discount

      // Calculate and update tax, total, and discount values for each item in the map
      itemMap.forEach((itemName, itemDetails) {
        int itemQuantity =
            itemDetails['quantity']; // Assuming quantity is available
        double itemRate = itemDetails['price']; // Assuming price is available
        int taxRate = itemDetails['tax']; // Assuming tax rate is available

        // Calculate the tax value (assuming tax is already the percentage)
        double taxValue = (itemQuantity * itemRate * taxRate) / 100;

        // Calculate total amount (itemQuantity * itemRate + taxValue)
        double totalAmount = (itemQuantity * itemRate);

        // Calculate the discount amount (either flat or percentage based on the input)
        double discountAmount = 0.0;
        double discountPercentage = 0.0;

        validateDiscount(totalAmount);

        if (isFlatDiscount) {
          discountAmount = flatDiscountInput; // Flat discount
          discountPercentage =
              (flatDiscountInput / totalAmount) * 100; // Calculate percentage
        } else {
          discountPercentage = discountPercentageInput; // Percentage discount
          discountAmount =
              (totalAmount * discountPercentageInput) / 100; // Calculate amount
        }

        // Prepare updated item with new calculated values
        Map<String, dynamic> updatedItem = {
          'sno': itemMap.length + 1,
          'item_name': itemName, // Get item name from map key
          'quantity': itemQuantity,
          'price': itemRate,
          'tax': taxValue,
          'total': totalAmount +
              taxValue -
              discountAmount, // Subtract discount from total
          'discountable': itemDetails['discountable'],
          'discountPercentage': discountPercentage,
          'dis_amt': discountAmount, // Discount amount
          'order_id': itemDetails['order_id'],
        };
        updatedItems.add(updatedItem);
      });

      // Step 1: Calculate totals for the bill
      Map<String, double> totals = calculateTotalsitems(updatedItems);

      // Step 2: Prepare bill data with updated items and totals
      Map<String, dynamic> billData = {
        "bill_number": _billNoController.text,
        "table_no": widget.tableno,
        "tax_value": totals['cgst']! + totals['sgst']!, // Total tax from totals
        "discount_percentage": totals['discountPercentage'],
        "service_charge_percentage": servicechargeValue,
        "packing_charge_percentage": packingChargeValue,
        "delivery_charge_percentage": deliveryChargeValue,
        "other_charge": 0.00,
        "property_id": widget.propertyid,
        "outletname": widget.outlet,
        "pax": _paxController.text,
        "guestName": _guestSearchController.text,
        "guestId": _guestIdController.text,
        "platform_fees_percentage": 0.00,
        "platform_fees_tax": 0.00,
        "platform_fees_tax_per": 0.00,
        "packing_charge_tax": 0.00,
        "delivery_charge_tax": 0.00,
        "service_charge_tax": 0.00,
        "packing_charge_tax_per": 0.00,
        "delivery_charge_tax_per": 0.00,
        "service_charge_tax_per": 0.00,
        "items":
            updatedItems, // Send updated items with tax, total, and discount
      };

      // Step 3: Send data to API
      var result = await billingApiService.generateBill(billData);
      processResponse(result);
      //_generateAndSaveBill(result.billid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill saved successfully!')),
      );

      _clearControllers();
    } catch (error) {
      // Handle any errors
      processResponserror(error.toString());
      _clearControllers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill saved successfully!')),
      );
      print('Error: $error');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error: $error')),
      // );
    }
  }

  void validateDiscount(double billAmount) {
    if (_percentDiscountController.text.isNotEmpty ||
        _flatDiscountController.text.isNotEmpty) {
      double enteredPercentage =
          double.tryParse(_percentDiscountController.text) ?? 0.0;
      double enteredFlatDiscount =
          double.tryParse(_flatDiscountController.text) ?? 0.0;

      // Assume we get the discount config from discountList
      Map<String, dynamic> discountConfig = discountList.isNotEmpty
          ? Map<String, dynamic>.from(discountList[0])
          : {};

      double minAmount =
          double.parse(discountConfig['min_amount'].toString() ?? "0.0");
      double maxAmount =
          double.parse(discountConfig['max_amount'].toString() ?? "0.0");
      double maxDiscountValue =
          double.parse(discountConfig['discount_value'].toString() ?? "0.0");

      String? errorMessage;

      if (billAmount < minAmount) {
        errorMessage =
            "Bill amount must be at least ₹$minAmount to apply discount.";
      }

      if (_discountType == 'Percentage') {
        double calculatedDiscount = (billAmount * enteredPercentage) / 100;

        if (enteredPercentage > maxDiscountValue) {
          errorMessage =
              "Max allowed discount percentage is $maxDiscountValue%.";
          _percentDiscountController.text = maxDiscountValue.toString();
        }

        if (calculatedDiscount > maxAmount) {
          errorMessage = "Max discount allowed is ₹$maxAmount.";
          _percentDiscountController.text =
              ((maxAmount / billAmount) * 100).toStringAsFixed(2);
        }
      }

      if (_discountType == 'Flat') {
        if (enteredFlatDiscount > maxAmount) {
          errorMessage = "Max flat discount allowed is ₹$maxAmount.";
          _flatDiscountController.text = maxAmount.toString();
        }
      }

      if (errorMessage != null) {
        // SchedulerBinding.instance.addPostFrameCallback((_) {
        //   showError(errorMessage!);
        // });
      }
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {});
    });
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void processResponserror(String response) {
    try {
      // Remove the prefix to extract the JSON part
      final jsonStartIndex = response.indexOf('{');
      if (jsonStartIndex == -1) {
        throw const FormatException('No JSON found in the response.');
      }

      // Extract the JSON substring
      final jsonResponseString = response.substring(jsonStartIndex);

      // Parse the JSON string
      Map<String, dynamic> jsonResponse = json.decode(jsonResponseString);

      // Extract the required fields
      int billId = jsonResponse['billId'];
      double grandTotal = double.parse(jsonResponse['grand_total']);
      _generateAndSaveBill(billId);
      // Process the extracted fields
      print('Bill ID: $billId');
      print('Grand Total: $grandTotal');

      // Further processing if needed
    } catch (e) {
      print('Error processing response: $e');
    }
  }

  void processResponse(response) {
    // Decode the JSON response into a map
    Map<String, dynamic> result = json.decode(response);

    // Extract the billId and grand_total from the result
    int billId = result['billId'];
    double grandTotal =
        double.parse(result['grand_total']); // Convert string to double

    // Print the extracted values
    print("Bill ID: $billId");
    print("Grand Total: ₹$grandTotal");

    // Call _generateAndSaveBill with the billId
    _generateAndSaveBill(billId);
  }

  Future<void> _generateAndSaveBill(billid) async {
    final pdf = pw.Document();

    // Calculate totals
    double subtotal = orderItems.fold(
        0, (sum, item) => sum + (item['quantity'] * item['price']));
    double tax = subtotal * 0.05; // Example 5% tax
    double total = subtotal + tax;

    // Page format for 80mm receipt paper
    const pageWidth = 80.0 * PdfPageFormat.mm;
    const pageFormat = PdfPageFormat(pageWidth, double.infinity);

    pdf.addPage(pw.Page(
      pageFormat: pageFormat,
      margin: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Text('My Business Name',
                textAlign: pw.TextAlign.center,
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text('123 Business Street, City, Country',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
            pw.Text('Phone: +123456789 | Email: contact@business.com',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
            pw.Divider(thickness: 1, color: PdfColors.black),
            pw.SizedBox(height: 5),

            // Bill Info
            pw.Text('Bill To:',
                style:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.Text('Customer Name: John Doe',
                style: const pw.TextStyle(fontSize: 9)),
            pw.Text(
                'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                style: const pw.TextStyle(fontSize: 9)),
            pw.SizedBox(height: 5),

            // Itemized Bill
            pw.Text('Itemized Bill:',
                style:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            pw.TableHelper.fromTextArray(
              cellAlignment: pw.Alignment.centerLeft,
              headers: ['Item', 'Qty', 'Price', 'Total'],
              headerStyle: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black),
              cellStyle: const pw.TextStyle(fontSize: 9),
              data: orderItems.map((item) {
                double total = item['quantity'] * item['price'];
                return [
                  item['item_name'],
                  '${item['quantity']}',
                  '${item['price'].toStringAsFixed(2)}',
                  (total.toStringAsFixed(2)),
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 10),

            // Totals
            pw.Divider(thickness: 1, color: PdfColors.black),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 10)),
                pw.Text(subtotal.toStringAsFixed(2),
                    style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Tax (5%):', style: const pw.TextStyle(fontSize: 10)),
                pw.Text(tax.toStringAsFixed(2),
                    style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total:',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text(total.toStringAsFixed(2),
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 10),

            // Footer
            pw.Text('Thank you for your purchase!',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.green)),
            pw.Text('Visit Again!',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
          ],
        );
      },
    ));

    // Get the directory for saving the PDF
    final directory = Directory(
        'C:\\Users\\Public\\Documents'); // Customize the path if needed
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }

    // Save the file with the Bill ID as the filename
    final file = File('${directory.path}\\$billid.pdf');
    await file.writeAsBytes(await pdf.save());

    print("PDF saved at: ${file.path}");

    // Automatically open the PDF with the default viewer (Windows-specific)
    Process.run('explorer', [file.path]).then((result) {
      print("Opened PDF in default viewer: ${result.stdout}");
    });
  }

  void _clearControllers() {
    Navigator.pop(context);
  }

  Map<String, double> calculateTotalsitems(List<Map<String, dynamic>> items) {
    double totalAmount = 0.0;

    double discountPercentageInput =
        double.tryParse(_percentDiscountController.text) ?? 0.0;
    double flatDiscountInput =
        double.tryParse(_flatDiscountController.text) ?? 0.0;
    double taxRate = 5.0;

    // Sum amounts only for discountable items
    for (var item in items) {
      if (item['discountable'] == true) {
        totalAmount += item['total'];
      }
    }

    double discountAmount = 0.0;
    double discountPercentage = 0.0;
    validateDiscount(totalAmount);
    if (isFlatDiscount) {
      discountAmount = flatDiscountInput;
      discountPercentage = totalAmount > 0
          ? (flatDiscountInput / totalAmount) * 100
          : 0.0; // Avoid division by zero
    } else {
      discountPercentage = discountPercentageInput;
      discountAmount = (totalAmount * discountPercentage) / 100;
    }

    double servicechargeValue =
        double.parse(serviceList[0]['service_charge'] ?? "0.0");
    double packingChargeValue =
        double.parse(packingList[0]['packing_charge'] ?? "0.0");
    double deliveryChargeValue =
        double.parse(deliveryList[0]['delivery_charge'] ?? "0.0");

    return {
      'totalAmount': totalAmount,
      'totalDiscount': discountAmount,
      'discountPercentage': discountPercentage,
      'cgst': (totalAmount - discountAmount) * (taxRate / 2) / 100,
      'sgst': (totalAmount - discountAmount) * (taxRate / 2) / 100,
      'serviceCharge': (totalAmount * servicechargeValue / 100),
      'packingCharge': (totalAmount * packingChargeValue / 100),
      'deliveryCharge': (totalAmount * deliveryChargeValue / 100),
    };
  }

  // Function to calculate totals
  Map<String, double> calculateTotals(Map<String, dynamic> itemMap) {
    double totalAmountnew = 0.0;
    double totalAmount = 0.0;
    // Get user input for discount
    double discountPercentageInput =
        double.tryParse(_percentDiscountController.text) ??
            0.0; // Input percentage discount
    double flatDiscountInput = double.tryParse(_flatDiscountController.text) ??
        0.0; // Input flat discount
    double serviceCharge = 10.0; // Example service charge
    double taxRate = 5.0; // Total GST rate (5%)

    double discountAmount = 0.0;
    double discountPercentage = 0.0;

    // Filter only discountable items and calculate totalAmount for discountable items
    itemMap.forEach((key, item) {
      if (item['discountable'] == true) {
        totalAmountnew +=
            item['total']; // Add only discountable items to the totalAmount
      }
    });

    itemMap.forEach((key, item) {
      totalAmount +=
          item['total']; // Add only discountable items to the totalAmount
    });
    validateDiscount(totalAmount);
    // Apply either flat discount or percentage discount
    if (isFlatDiscount && totalAmountnew > 0) {
      discountAmount = flatDiscountInput;
      discountPercentage = (flatDiscountInput / totalAmountnew) * 100;
    } else if (totalAmountnew > 0) {
      discountPercentage = discountPercentageInput;
      discountAmount = (totalAmountnew * discountPercentageInput) / 100;
    }

    double subtotal = totalAmount - discountAmount; // Subtotal after discount
    double cgst = (subtotal * (taxRate / 2)) / 100; // CGST = 2.5%
    double sgst = (subtotal * (taxRate / 2)) / 100; // SGST = 2.5%
    double netReceivableAmount = subtotal + cgst + sgst;

    double servicechargeValue =
        double.parse(serviceList[0]['service_charge'] ?? "0.0");
    double packingChargeValue =
        double.parse(packingList[0]['packing_charge'] ?? "0.0");
    double deliveryChargeValue =
        double.parse(deliveryList[0]['delivery_charge'] ?? "0.0");

    return {
      'totalAmount': totalAmount,
      'discount': discountAmount,
      'discountPercentage': discountPercentage,
      'subtotal': subtotal,
      'cgst': cgst,
      'sgst': sgst,
      'serviceCharge': (totalAmount * servicechargeValue / 100),
      'packingCharge': (totalAmount * packingChargeValue / 100),
      'deliveryCharge': (totalAmount * deliveryChargeValue / 100),
      'netReceivableAmount': netReceivableAmount +
          (totalAmount * servicechargeValue / 100) +
          (totalAmount * packingChargeValue / 100) +
          (totalAmount * deliveryChargeValue / 100),
    };
  }

  List<Map<String, dynamic>> updateItems(List<Map<String, dynamic>> items,
      double totalAmount, double totalDiscount) {
    double discountPercentage =
        totalAmount > 0 ? (totalDiscount / totalAmount) * 100 : 0.0;

    return items.map((item) {
      if (item['discountable'] == true) {
        double itemDiscountValue =
            (item['item_amount'] * discountPercentage) / 100;
        double updatedItemValue = item['item_amount'] - itemDiscountValue;

        return {
          ...item, // Spread the original item
          "discount_percentage": discountPercentage,
          "total_discount_value": itemDiscountValue,
          "total_item_value": updatedItemValue,
        };
      } else {
        return {
          ...item,
          "discount_percentage": 0.0,
          "total_discount_value": 0.0,
          "total_item_value": item['item_amount'],
        };
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totals = calculateTotals(itemMap);
    double servicechargeValue =
        double.parse(serviceList[0]['service_charge'] ?? "0.0");
    double packingChargeValue =
        double.parse(packingList[0]['packing_charge'] ?? "0.0");
    double deliveryChargeValue =
        double.parse(deliveryList[0]['delivery_charge'] ?? "0.0");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing Form'),
      ),
      body: _isloading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Container(
                width: MediaQuery.of(context)
                    .size
                    .width, // Adjust the width to fit both sides
                padding: const EdgeInsets.all(16.0),

                child: Row(
                  children: [
                    // Left side: Order List

                    // const SizedBox(width: 16), // Space between left and right side
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Orders',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(
                                height: 10), // Space between header and list
                            Expanded(
                              child: ListView.builder(
                                itemCount: orders.length,
                                itemBuilder: (context, index) {
                                  final order = orders[index];
                                  return Card(
                                    child: ListTile(
                                      title: Text(
                                          'Order No: ${order["order_number"]}'),
                                      subtitle: Text(
                                          'Table No: ${order["table_number"]} - ${order["order_type"]}'),
                                      onTap: () {
                                        setState(() {
                                          selectedOrderId =
                                              order['order_id'].toString();
                                          // //   ordernumber = order['order_number'].toString();
                                          _fetchOrderItemsnew(
                                              [selectedOrderId]);
                                        });
                                      },
                                      selected: selectedOrderId ==
                                          order['order_id'].toString(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Order Items',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.blue,
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {
                                      _reset();
                                    },
                                    icon: const Icon(Icons.refresh))
                              ],
                            ),
                            const SizedBox(
                                height: 10), // Space between header and list
                            Expanded(
                              child: ListView(
                                children: selectedOrderId.isEmpty
                                    // If no order is selected, show all items
                                    ? itemMap.entries.map((entry) {
                                        var item = entry.value;
                                        return ListTile(
                                          title: Text(item['item_name']),
                                          subtitle: Text(
                                              'Qty: ${item['quantity']} | ₹${item['total']}'),
                                          trailing: Text('₹${item['price']}'),
                                        );
                                      }).toList()
                                    : itemMap.entries
                                        // Filter items based on selectedOrderId
                                        .where((entry) =>
                                            entry.value['order_id']
                                                .toString() ==
                                            selectedOrderId.toString())
                                        .map((entry) {
                                        var item = entry.value;
                                        return ListTile(
                                          title: Text(item['item_name']),
                                          subtitle: Text(
                                              'Qty: ${item['quantity']} | ₹${item['total']}'),
                                          trailing: Text('₹${item['price']}'),
                                        );
                                      }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Right side: Existing Billing Form
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Bill No:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextField(
                                              controller: _billNoController,
                                              enabled: false,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Order No:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextField(
                                              controller: _orderNoController,
                                              enabled: false,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Date:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextField(
                                              controller: _dateController,
                                              enabled: false,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Time:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextField(
                                              controller: _timeController,
                                              enabled: false,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Table No:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextField(
                                              controller: _tableNoController,
                                              enabled: false,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Guest ID:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextField(
                                              controller: _guestIdController,
                                              enabled: false,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _guestSearchController,
                                  decoration: InputDecoration(
                                    labelText: 'Search Guest',
                                    suffixIcon: _guestSearchController
                                            .text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed: () {
                                              setState(() {
                                                _guestSearchController.clear();
                                                _guestRecords =
                                                    []; // Hide suggestions
                                              });
                                            },
                                          )
                                        : IconButton(
                                            icon: const Icon(Icons.search),
                                            onPressed: () {
                                              if (_guestSearchController
                                                  .text.isNotEmpty) {
                                                _searchGuest(
                                                    _guestSearchController
                                                        .text);
                                              }
                                            },
                                          ),
                                  ),
                                  onChanged:
                                      _searchGuest, // Call search function on text change
                                ),
                                const SizedBox(height: 10),
                                _guestRecords.isNotEmpty
                                    ? Container(
                                        height: 200, // Adjust height as needed
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: ListView.builder(
                                          itemCount: _guestRecords.length,
                                          itemBuilder: (context, index) {
                                            final guest = _guestRecords[index];
                                            return ListTile(
                                              title: Text(guest['guest_name']),
                                              subtitle:
                                                  Text(guest['phone_number']),
                                              onTap: () {
                                                setState(() {
                                                  _guestSearchController.text =
                                                      guest[
                                                          'guest_name']; // Set selected guest
                                                  _guestIdController
                                                      .text = guest[
                                                          'guest_id']
                                                      .toString(); // Store selected guest
                                                  _guestRecords =
                                                      []; // Hide the dropdown
                                                });
                                                print('Selected Guest: $guest');
                                              },
                                            );
                                          },
                                        ),
                                      )
                                    : const SizedBox(), // Hide list when empty

                                // Pax Field
                                TextFormField(
                                  controller: _paxController,
                                  decoration: const InputDecoration(
                                    labelText: 'Pax (Number of People)',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 10),
                                // Discount Field with Radio Buttons for Discount Type
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text('Discount Type:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Radio<String>(
                                      value: 'Percentage',
                                      groupValue: _discountType,
                                      onChanged: (value) {
                                        setState(() {
                                          isFlatDiscount = false;
                                          _discountType = value!;
                                        });
                                      },
                                    ),
                                    const Text('Percentage'),
                                    Radio<String>(
                                      value: 'Flat',
                                      groupValue: _discountType,
                                      onChanged: (value) {
                                        setState(() {
                                          isFlatDiscount = true;
                                          _discountType = value!;
                                        });
                                      },
                                    ),
                                    const Text('Flat Amount'),
                                  ],
                                ),
                                if (_discountType == 'Percentage')
                                  TextFormField(
                                    maxLength: 3,
                                    controller: _percentDiscountController,
                                    decoration: const InputDecoration(
                                        labelText: 'Discount Percentage'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                  ),
                                if (_discountType == 'Flat')
                                  TextFormField(
                                    maxLength: 10,
                                    controller: _flatDiscountController,
                                    decoration: const InputDecoration(
                                        labelText: 'Discount Amount'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                  ),
                                const SizedBox(height: 10),
                                // Scrollable Items List
                                SizedBox(
                                  height:
                                      130, // Keeps height fixed to allow scrolling vertically
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return SingleChildScrollView(
                                        scrollDirection:
                                            Axis.vertical, // Vertical scrolling
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis
                                              .horizontal, // Horizontal scrolling
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              minWidth: constraints
                                                  .maxWidth, // Ensure table fits the container
                                            ),
                                            child: DataTable(
                                              columnSpacing:
                                                  20, // Adjust spacing between columns
                                              columns: const [
                                                DataColumn(label: Text('S.No')),
                                                DataColumn(label: Text('Name')),
                                                DataColumn(label: Text('Qty')),
                                                DataColumn(label: Text('Rate')),
                                                DataColumn(
                                                    label: Text('Amount')),
                                                DataColumn(label: Text('Tax')),
                                                DataColumn(
                                                    label: Text('Discount')),
                                              ],
                                              rows:
                                                  itemMap.entries.map((entry) {
                                                var item = entry.value;
                                                return DataRow(cells: [
                                                  DataCell(Text(
                                                      item['sno'].toString())),
                                                  DataCell(
                                                      Text(item['item_name'])),
                                                  DataCell(Text(item['quantity']
                                                      .toString())),
                                                  DataCell(Text(
                                                      '₹${item['price']}')),
                                                  DataCell(Text(
                                                      '₹${item['total']}')),
                                                  DataCell(
                                                      Text('${item['tax']}%')),
                                                  DataCell(Text(
                                                      '${item['discountable']}')),
                                                ]);
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Summary Section
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Total Amount:'),
                                        Text(
                                            '₹${totals['totalAmount']!.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'Discount: ${totals['discountPercentage']!.toStringAsFixed(2)}%'),
                                        Text(
                                            '₹${totals['discount']!.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Subtotal:'),
                                        Text(
                                            '₹${totals['subtotal']!.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('CGST:'),
                                        Text(
                                            '₹${totals['cgst']!.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('SGST:'),
                                        Text(
                                            '₹${totals['sgst']!.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'Delivery Charge: ${deliveryChargeValue.toStringAsFixed(2)}%'),
                                        Text(
                                            '₹${totals['deliveryCharge']!.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'Packing Charge: ${packingChargeValue.toStringAsFixed(2)}%'),
                                        Text(
                                            '₹${totals['packingCharge']!.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'Service Charge: ${servicechargeValue.toStringAsFixed(2)}%'),
                                        Text(
                                            '₹${totals['serviceCharge']!.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Net Receivable Amount:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '₹${totals['netReceivableAmount']!.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Bottom Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        _saveBill();
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue),
                                      child: const Text('Save'),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        _generateAndSaveBill(1);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange),
                                      child: const Text('Print Bill'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
