import 'package:flutter/material.dart';
import 'package:fruit_inv/models/customLists_model.dart';
import 'package:fruit_inv/models/orders_model.dart';
import 'package:fruit_inv/models/order_table.dart';
import 'package:fruit_inv/services/database_helper.dart';
import 'package:fruit_inv/utils/utils.dart';
import 'package:fruit_inv/widgets/table_widget.dart';

class OrderPage extends StatefulWidget {
  final Orders? order;

  const OrderPage({super.key, this.order});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<String> customers = [];
  List<String> products = [];
  List<String> units = [];

  final List<OrderTable> orderDetailsList = [];
  bool isEditMode = false;
  OrderTable? currentlyEditingRow;

  String _dropdownValue1 = '';
  String _dropdownValue2 = '';
  String _dropdownValue3 = '';

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCustomersAndProducts();
  }

  void refreshPage() {
    fetchCustomersAndProducts();
  }

  void fetchCustomersAndProducts() async {
    List<CustomerList> fetchedCustomers = await DatabaseHelper.getCustomers();
    List<ProductList> fetchedProducts = await DatabaseHelper.getProducts();
    List<UnitList> fetchedUnits = await DatabaseHelper.getUnits();

    List<String> unitNames = fetchedUnits.map((unit) => unit.unit).toList();

    List<String> customerNames =
        fetchedCustomers.map((customer) => customer.customer).toList();

    List<String> productNames =
        fetchedProducts.map((product) => product.product).toList();

    setState(() {
      customers =
          customerNames.isNotEmpty ? customerNames : ['No Customers Available'];
      products =
          productNames.isNotEmpty ? productNames : ['No Products Available'];
      units = unitNames.isNotEmpty ? unitNames : ['No Units Available'];

      _dropdownValue2 = units.first;
      _dropdownValue3 = customers.first;
      _dropdownValue1 = products.first;
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: buildDropdown('Select customer', _dropdownValue3,
                      _updateDropdownValue3, customers),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(8)),
                    child: addButton(context, 'Customer'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child:
                        buildTextFormField('Quantity per', _quantityController),
                  ),
                ),
                Expanded(
                  child: buildDropdown('Select unit', _dropdownValue2,
                      _updateDropdownValue2, units),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(8)),
                    child: addButton(context, 'Unit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: buildDropdown('Select a product', _dropdownValue1,
                      _updateDropdownValue1, products),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(8)),
                    child: addButton(context, 'Product'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addOrder,
              child: const Text('Add Order'),
            ),
            const SizedBox(height: 40),
            DataTableWidget(
              orderDetailsList: orderDetailsList,
              currentlyEditingRow: currentlyEditingRow,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveOrder,
              child: const Text('Save Order'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDropdown(String hintText, String value,
      Function(String?) onChanged, List<String> items) {
    items.sort();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        hint: Text(hintText),
        value: value,
        isExpanded: true,
        onChanged: onChanged,
        items: items
            .map((item) =>
                DropdownMenuItem<String>(value: item, child: Text(item)))
            .toList(),
        underline: Container(),
      ),
    );
  }

  Widget addButton(BuildContext context, String type) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () {
        Navigator.pushNamed(context, '/addcustomerproduct', arguments: type)
            .then((_) => fetchCustomersAndProducts());
      },
    );
  }

  Widget buildTextFormField(String hintText, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(13),
        labelText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $hintText';
        }
        return null;
      },
    );
  }

  void _updateDropdownValue1(String? newValue) {
    setState(() {
      _dropdownValue1 = newValue!;
    });
  }

  void _updateDropdownValue2(String? newValue) {
    setState(() {
      _dropdownValue2 = newValue!;
    });
  }

  void _updateDropdownValue3(String? newValue) {
    setState(() {
      _dropdownValue3 = newValue!;
    });
  }

  void toggleEditMode() {
    setState(() {
      isEditMode = !isEditMode;
    });
  }

  void _addOrder() {
    setState(() {
      String product = _dropdownValue1;
      String unit = _dropdownValue2;
      String customer = _dropdownValue3;

      if (customer == "No Customers Available") {
        _showSnackBar('No customers available. Please add customers first.');
        return;
      }
      if (product == "No Products Available") {
        _showSnackBar('No products available. Please add products first.');
        return;
      }
      if (unit == "No Units Available") {
        _showSnackBar('No units available. Please add units first.');
        return;
      }

      int quantity;
      try {
        quantity = int.parse(_quantityController.text);
        if (quantity <= 0) {
          throw const FormatException('Quantity must be a positive integer.');
        }
      } catch (e) {
        _showSnackBar('Please enter a valid positive integer for quantity.');
        return;
      }

      orderDetailsList.add(OrderTable(
        product: product,
        quantity: quantity,
        unit: unit,
        customer: customer,
        date: Utils.formatDate(DateTime.now()),
      ));

      _quantityController.clear();
    });
  }

  void _saveOrder() async {
    if (orderDetailsList.isEmpty) {
      _showSnackBar('No orders to save.');
      return;
    }

    try {
      for (var orderTable in orderDetailsList) {
        final existingOrders = await DatabaseHelper.getAllOrders();
        const defaultOrder = Orders(customer: '', date: '');
        final existingOrder = existingOrders.firstWhere(
          (order) =>
              order.customer == orderTable.customer &&
              order.date == orderTable.date,
          orElse: () => defaultOrder,
        );

        int orderId;
        if (existingOrder != defaultOrder) {
          orderId = existingOrder.id!;
        } else {
          final order = Orders(
            customer: orderTable.customer,
            date: orderTable.date,
          );
          orderId = await DatabaseHelper.addOrder(order);
        }

        final orderDetail = OrderDetails(
          orderId: orderId,
          product: orderTable.product,
          quantity: orderTable.quantity,
          unit: orderTable.unit,
        );

        await DatabaseHelper.addOrderDetail(orderDetail);
      }

      Navigator.pop(context, true);
      _showSnackBar('Orders added successfully');
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
