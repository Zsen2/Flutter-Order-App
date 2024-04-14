import 'package:fruit_inv/api/pdf_api.dart';
import 'package:fruit_inv/models/orders_model.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> generateOrdersPdf(
  List<Orders> orders,
  List<List<OrderDetails>> orderDetailsList,
) async {
  final pdf = pw.Document();

  // Define the maximum number of orders per page
  final int maxOrdersPerPage = 14;

  // Loop through each order and its details
  for (int i = 0; i < orders.length; i += maxOrdersPerPage) {
    final int endIndex = (i + maxOrdersPerPage).clamp(0, orders.length);
    final List<Orders> pageOrders = orders.sublist(i, endIndex);
    final List<List<OrderDetails>> pageOrderDetails =
        orderDetailsList.sublist(i, endIndex);

    // Add a new page to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _buildOrderColumn(
                  context,
                  pageOrders.sublist(
                      0, pageOrders.length ~/ 2), // First half of pageOrders
                  pageOrderDetails.sublist(0,
                      pageOrders.length ~/ 2), // First half of pageOrderDetails
                ),
              ),
              pw.SizedBox(width: 5), // Add space between columns
              pw.Expanded(
                child: _buildOrderColumn(
                  context,
                  pageOrders.sublist(
                      pageOrders.length ~/ 2), // Second half of pageOrders
                  pageOrderDetails.sublist(pageOrders.length ~/
                      2), // Second half of pageOrderDetails
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Save the PDF using PdfApi
  final file = await PdfApi.saveDocument(name: 'orders.pdf', pdf: pdf);
  if (file != null) {
    // Open the saved PDF file
    await PdfApi.openFile(file);
  } else {
    // Handle the case where saving the file failed
  }
}

pw.Widget _buildOrderColumn(
  pw.Context context,
  List<Orders> orders,
  List<List<OrderDetails>> orderDetailsList,
) {
  final List<pw.Widget> orderTables = [];

  // Iterate over each order and its details
  for (var i = 0; i < orders.length; i++) {
    final order = orders[i];
    final orderDetails = orderDetailsList[i];
    final table = _buildOrderTable(order, orderDetails);
    orderTables.add(table);
  }

  // Return a column containing the tables for the orders
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: orderTables,
  );
}

pw.Widget _buildOrderTable(
  Orders order,
  List<OrderDetails> orderDetails,
) {
  final Map<String, String> productQuantities = {};

  // Iterate over order details to accumulate quantities for each product
  for (var detail in orderDetails) {
    final existingQuantity = productQuantities[detail.product];
    if (existingQuantity != null) {
      // Concatenate quantities if the product already exists
      productQuantities[detail.product] =
          '$existingQuantity | ${detail.quantity}';
    } else {
      // Set quantity if it's the first occurrence of the product
      productQuantities[detail.product] = '${detail.quantity}';
    }
  }

  // Convert product quantities map to table data
  final List<List<String>> tableData = productQuantities.entries
      .map((entry) => [entry.key, entry.value])
      .toList();

  // Bold style
  final boldStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold);

  // Build the table with bold headers
  return pw.Table.fromTextArray(
    cellStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.normal), // reset to normal for cells
    headerStyle: boldStyle, // bold style for headers
    headers: [
      pw.Text(order.customer, style: boldStyle), // bold customer header
      pw.Text(order.date, style: boldStyle), // bold date header
    ],
    data: tableData,
  );
}
