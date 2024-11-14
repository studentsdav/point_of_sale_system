import 'package:flutter/material.dart';

class BillingFormScreen extends StatefulWidget {
  @override
  _BillingFormScreenState createState() => _BillingFormScreenState();
}

class _BillingFormScreenState extends State<BillingFormScreen> {
  final TextEditingController _billNoController = TextEditingController(text: 'BILL12345');
  final TextEditingController _orderNoController = TextEditingController(text: 'ORD67890');
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _tableNoController = TextEditingController(text: '5');
  final TextEditingController _guestIdController = TextEditingController();
  final TextEditingController _guestSearchController = TextEditingController();
  final TextEditingController _paxController = TextEditingController(text: '1');
  final TextEditingController _flatDiscountController = TextEditingController();
  final TextEditingController _percentDiscountController = TextEditingController();

  bool _isInitialized = false;
  String _discountType = 'Percentage'; // Default to Percentage Discount

  // Mock data for items
  final List<Map<String, dynamic>> _items = List.generate(10, (index) {
    return {
      'sno': index + 1,
      'name': 'Item ${index + 1}',
      'qty': 1,
      'rate': 100.0,
      'amount': 100.0,
      'tax': 5.0,
      'discount_amount': 10.0,
      'happy_hour_discount': 5.0,
      'scheme': 'None',
      'category': 'Category ${index % 3}',
    };
  });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _dateController.text = DateTime.now().toString().split(' ')[0];
      _timeController.text = TimeOfDay.now().format(context);
      _isInitialized = true;
    }
  }

  void _searchGuest() {
    setState(() {
      _guestIdController.text = 'GUEST001';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Billing Form'),
      ),
      body: Center(
        child: Container(
          width: 600,  // Adjust as needed for the form width
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 4,
                blurRadius: 10,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bill No:', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextField(controller: _billNoController, enabled: false, style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order No:', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextField(controller: _orderNoController, enabled: false, style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextField(controller: _dateController, enabled: false, style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Time:', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextField(controller: _timeController, enabled: false, style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Table No:', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextField(controller: _tableNoController, enabled: false, style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Guest ID:', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextField(controller: _guestIdController, enabled: false, style: TextStyle(fontWeight: FontWeight.bold)),
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
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: _searchGuest,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Pax Field
                TextFormField(
                  controller: _paxController,
                  decoration: InputDecoration(
                    labelText: 'Pax (Number of People)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),

                // Discount Field with Radio Buttons for Discount Type
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Discount Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Radio<String>(
                      value: 'Percentage',
                      groupValue: _discountType,
                      onChanged: (value) {
                        setState(() {
                          _discountType = value!;
                        });
                      },
                    ),
                    Text('Percentage'),
                    Radio<String>(
                      value: 'Flat',
                      groupValue: _discountType,
                      onChanged: (value) {
                        setState(() {
                          _discountType = value!;
                        });
                      },
                    ),
                    Text('Flat Amount'),
                  ],
                ),
                if (_discountType == 'Percentage')
                  TextFormField(
                    controller: _percentDiscountController,
                    decoration: InputDecoration(labelText: 'Discount Percentage'),
                    keyboardType: TextInputType.number,
                  ),
                if (_discountType == 'Flat')
                  TextFormField(
                    controller: _flatDiscountController,
                    decoration: InputDecoration(labelText: 'Discount Amount'),
                    keyboardType: TextInputType.number,
                  ),
                const SizedBox(height: 10),

                // Scrollable Items List
            Container(
  height: 250, // Increased height to allow vertical scroll as well
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(8),
  ),
  child: SingleChildScrollView(
    scrollDirection: Axis.vertical, // Allow vertical scrolling
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Allow horizontal scrolling
      child: DataTable(
        columns: [
          DataColumn(label: Text('S.No')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Qty')),
          DataColumn(label: Text('Rate')),
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('Tax')),
          DataColumn(label: Text('Discount Amount')),
          DataColumn(label: Text('Happy Hour Discount')),
          DataColumn(label: Text('Scheme')),
          DataColumn(label: Text('Category')),
        ],
        rows: _items.map((item) {
          return DataRow(cells: [
            DataCell(Text(item['sno'].toString())),
            DataCell(Text(item['name'])),
            DataCell(Text(item['qty'].toString())),
            DataCell(Text('₹${item['rate']}')),
            DataCell(Text('₹${item['amount']}')),
            DataCell(Text('${item['tax']}%')),
            DataCell(Text('₹${item['discount_amount']}')),
            DataCell(Text('₹${item['happy_hour_discount']}')),
            DataCell(Text(item['scheme'])),
            DataCell(Text(item['category'])),
          ]);
        }).toList(),
      ),
    ),
  ),
),

                // Summary Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount:'),
                        Text('₹1000.00'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Discount:'),
                        Text('₹50.00'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal:'),
                        Text('₹950.00'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('CGST (2.5%):'),
                        Text('₹23.75'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('SGST (2.5%):'),
                        Text('₹23.75'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Service Charge:'),
                        Text('₹10.00'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Net Receivable Amount:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹1007.50',
                          style: TextStyle(fontWeight: FontWeight.bold),
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
                      onPressed: () {},
                      child: Text('Save'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    ),
                    const SizedBox(width: 10),
                  
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Print Bill'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
