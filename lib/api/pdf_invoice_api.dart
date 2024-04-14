import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fruit_inv/api/pdf_api.dart';
import 'package:fruit_inv/models/invoice_customer.dart';
import 'package:fruit_inv/models/invoice.dart';
import 'package:fruit_inv/models/invoice_supplier.dart';
import 'package:fruit_inv/utils/utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfInvoiceApi {
  static pw.Font? regularFont;
  static pw.Font? boldFont;

  static Future<File> generate(Invoice invoice) async {
    final pdf = pw.Document();

    // Load custom fonts
    regularFont = await loadFont('assets/fonts/RobotoMono-Regular.ttf');
    boldFont = await loadFont('assets/fonts/RobotoMono-Bold.ttf');

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          buildHeader(invoice),
          buildTitle(invoice.customer),
          buildInvoice(invoice),
        ],
        footer: (context) => buildFooter(invoice),
      ),
    );

    final file = await PdfApi.saveDocument(name: 'my_invoice.pdf', pdf: pdf);
    return file ?? (throw Exception('Failed to save document'));
  }

  static Future<pw.Font> loadFont(String fontPath) async {
    final ByteData fontData = await rootBundle.load(fontPath);
    final Uint8List fontUint8List = fontData.buffer.asUint8List();
    return pw.Font.ttf(fontUint8List.buffer.asByteData());
  }

  static pw.Widget buildHeader(Invoice invoice) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 1 * PdfPageFormat.cm),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              buildSupplierAddress(invoice.supplier),
              buildInvoiceInfo(invoice.info), // Aligns to the rightmost
            ],
          ),
          pw.SizedBox(height: 1 * PdfPageFormat.cm),
        ],
      );

  static pw.Widget buildInvoiceInfo(InvoiceInfo info) {
    final titles = <String>['Date:'];
    final data = <String>[
      Utils.formatDate(info.date),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: List.generate(titles.length, (index) {
        final title = titles[index];
        final value = data[index];

        return buildText(title: title, value: value, width: 120);
      }),
    );
  }

  static pw.Widget buildSupplierAddress(Supplier supplier) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(supplier.name,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          pw.Text(supplier.address),
        ],
      );

  static pw.Widget buildTitle(Customer customer) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            customer.name,
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );

  static pw.Widget buildInvoice(Invoice invoice) {
    final headers = ['Product', 'Quantity'];

    // Group items by description and concatenate quantities
    final groupedItems = <String, String>{};
    for (var item in invoice.items) {
      final quantity = '${item.quantity}';
      groupedItems.update(
        item.description,
        (existingValue) => '$existingValue | $quantity',
        ifAbsent: () => quantity,
      );
    }

    final data =
        groupedItems.entries.map((entry) => [entry.key, entry.value]).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      cellAlignment: pw.Alignment.centerLeft,
      cellStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
      },
      border: null,
    );
  }

  static pw.Widget buildFooter(Invoice invoice) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Divider(),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          buildSimpleText(title: 'Address', value: invoice.supplier.address),
        ],
      );

  static pw.Widget buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = pw.TextStyle(fontWeight: pw.FontWeight.bold);

    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(title, style: style),
        pw.SizedBox(width: 2 * PdfPageFormat.mm),
        pw.Text(value),
      ],
    );
  }

  static pw.Widget buildText({
    required String title,
    required String value,
    double width = double.infinity,
    pw.TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? pw.TextStyle(fontWeight: pw.FontWeight.bold);

    return pw.Container(
      width: width,
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(title, style: style)),
          pw.Text(value, style: unite ? style : null),
        ],
      ),
    );
  }
}
