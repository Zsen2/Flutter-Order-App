import 'package:fruit_inv/models/invoice_customer.dart';
import 'package:fruit_inv/models/invoice_supplier.dart';

class Invoice {
  final InvoiceInfo info;
  final Supplier supplier;
  final Customer customer;
  final List<InvoiceItem> items;

  const Invoice({
    required this.info,
    required this.supplier,
    required this.customer,
    required this.items,
  });
}

class InvoiceInfo {
  final DateTime date;

  const InvoiceInfo({
    required this.date,
  });
}

class InvoiceItem {
  final String description;
  final DateTime date;
  final int quantity;
  final String unit;

  const InvoiceItem({
    required this.description,
    required this.date,
    required this.quantity,
    required this.unit,
  });
}
