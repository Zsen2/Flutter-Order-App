import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fruit_inv/models/invoice.dart';
import 'package:fruit_inv/models/invoice_supplier.dart';
import 'package:fruit_inv/models/invoice_customer.dart';
import 'package:fruit_inv/models/orders_model.dart';
import 'package:fruit_inv/services/database_helper.dart';
import 'package:fruit_inv/api/pdf_invoice_api.dart';
import 'package:fruit_inv/api/pdf_api.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class OrdersWidget extends StatefulWidget {
  final Orders order;

  const OrdersWidget({Key? key, required this.order}) : super(key: key);

  @override
  _OrderWidgetState createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrdersWidget> {
  late List<OrderDetails> orderDetailsList;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  void fetchOrderDetails() async {
    final details = await DatabaseHelper.getOrderDetails(widget.order.id!);
    if (mounted) {
      setState(() {
        orderDetailsList = details;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          // SlidableAction for generating PDF
          SlidableAction(
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(10)),
            onPressed: _generatePDF,
            backgroundColor: const Color.fromARGB(255, 28, 14, 230),
            foregroundColor: Colors.white,
            icon: Icons.picture_as_pdf_rounded,
            label: 'PDF',
          ),
        ],
      ),
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        dismissible: DismissiblePane(onDismissed: () async {
          await DatabaseHelper.deleteOrder(widget.order.id!);
        }),
        children: [
          // SlidableAction for deleting
          SlidableAction(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(10)),
            onPressed: ((context) {}),
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      key: Key(widget.order.id.toString()),
      child: _buildOrderDetailsWidget(widget.order),
    );
  }

  void _generatePDF(BuildContext context) async {
    final invoiceItems = orderDetailsList.map((details) {
      return InvoiceItem(
        description: details.product,
        date: DateTime.now(),
        quantity: details.quantity,
        unit: details.unit,
      );
    }).toList();

    final invoice = Invoice(
      supplier: const Supplier(
        name: 'Erl\'s   trading',
        address: 'Marbeach Lapu-Lapu City',
      ),
      customer: Customer(name: widget.order.customer),
      info: InvoiceInfo(
        date: DateTime.now(),
      ),
      items: invoiceItems,
    );

    try {
      if (await requestStoragePermission(Permission.storage) == true) {
        final pdfFile = await PdfInvoiceApi.generate(invoice);
        await PdfApi.openFile(pdfFile);
        print('Storage permission granted');
      } else {
        print('Storage permission denied');
      }
    } catch (e) {
      print('Error generating or opening PDF: $e');
    }
  }

  Future<bool> requestStoragePermission(Permission permission) async {
    AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
    if (build.version.sdkInt >= 30) {
      var re = await Permission.manageExternalStorage.request();
      if (re.isGranted) {
        return true;
      } else {
        return false;
      }
    } else {
      if (await permission.isGranted) {
        return true;
      } else {
        var result = await permission.request();
        if (result.isGranted) {
          return true;
        } else {
          return false;
        }
      }
    }
  }

  Widget _buildOrderDetailsWidget(Orders order) {
    return FutureBuilder<List<OrderDetails>>(
      // Builder of OrderDetails product, quantity, units and price
      future: order.id != null
          ? DatabaseHelper.getOrderDetails(order.id!)
          : Future.value([]),
      builder: (context, detailsSnapshot) {
        if (detailsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (detailsSnapshot.hasError || detailsSnapshot.data == null) {
            return const Center(child: Text('Error fetching order details'));
          } else {
            List<OrderDetails> orderDetails = detailsSnapshot.data!;
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      order.customer,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      order.date,
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: orderDetails.length,
                      itemBuilder: (context, index) {
                        OrderDetails details = orderDetails[index];
                        return ListTile(
                          dense: true,
                          visualDensity: const VisualDensity(vertical: -3),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                details.product,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${details.quantity}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                details.unit,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }
        }
      },
    );
  }
}
