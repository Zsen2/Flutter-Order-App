import 'package:flutter/material.dart';
import 'package:fruit_inv/models/orders_model.dart';
import 'package:fruit_inv/services/database_helper.dart';
import 'package:fruit_inv/widgets/PDF_widget.dart';
import 'package:fruit_inv/widgets/orders_widget.dart';

class OrdersPage extends StatefulWidget {
  final Orders? orders;

  const OrdersPage({super.key, this.orders});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  void refreshPage() {
    setState(() {});
  }

  void _generatePdfOrders() async {
    try {
      // Fetch all orders and their details
      final List<Orders> allOrders = await DatabaseHelper.getAllOrders();
      final List<List<OrderDetails>> allOrderDetails = await Future.wait(
          allOrders.map((order) => DatabaseHelper.getOrderDetails(order.id!)));

      // Generate the PDF for all orders
      await generateOrdersPdf(allOrders, allOrderDetails);
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }

  void _showClearOrdersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Are you sure you want to clear all orders?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss the dialog
                await DatabaseHelper.clearAllOrders();
                refreshPage();
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25, top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: FutureBuilder<List<Orders>>(
                future: DatabaseHelper.getAllOrders()
                  ..then((value) =>
                      value.sort((a, b) => a.date.compareTo(b.date))),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    if (snapshot.hasError || snapshot.data == null) {
                      return const Center(child: Text('Error fetching orders'));
                    } else {
                      List<Orders> orders = snapshot.data!;
                      return ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          Orders order = orders[index];
                          return OrdersWidget(
                              order: order, key: Key(order.id.toString()));
                        },
                      );
                    }
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: _generatePdfOrders,
                    child: const Text('PDF Orders'),
                  ),
                  TextButton(
                    onPressed: _showClearOrdersDialog,
                    child: const Text('Clear All Orders'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          Navigator.pushNamed(context, '/orderpage')
              .then((val) => val != null ? refreshPage() : null);
        },
      ),
    );
  }
}
