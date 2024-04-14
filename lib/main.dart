import 'package:flutter/material.dart';
import 'package:fruit_inv/pages/addCusProd_page.dart';
import 'package:fruit_inv/pages/orders.dart';
import 'package:fruit_inv/pages/order_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const OrdersPage(),
      routes: {
        '/orderpage': (context) => const OrderPage(),
        '/addcustomerproduct': (context) => AddCustomerProductPage(
            type: ModalRoute.of(context)!.settings.arguments as String),
      },
    );
  }
}
