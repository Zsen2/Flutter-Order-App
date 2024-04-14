import 'package:flutter/material.dart';
import 'package:fruit_inv/models/order_table.dart';

class DataTableWidget extends StatefulWidget {
  final List<OrderTable> orderDetailsList;
  OrderTable? currentlyEditingRow;

  DataTableWidget({
    required this.orderDetailsList,
    required this.currentlyEditingRow,
    super.key,
  });

  @override
  _DataTableWidgetState createState() => _DataTableWidgetState();
}

class _DataTableWidgetState extends State<DataTableWidget> {
  @override
  Widget build(BuildContext context) {
    return DataTable(
      horizontalMargin: 0,
      columnSpacing: 13,
      columns: const [
        DataColumn(label: Text('Customer')),
        DataColumn(label: Text('Product')),
        DataColumn(label: Text('Quantity')),
        DataColumn(label: Text('Unit')),
        DataColumn(label: Text('Edit')),
        DataColumn(label: Text('Delete')),
      ],
      rows: widget.orderDetailsList.map((orderTable) {
        final isEditing = orderTable == widget.currentlyEditingRow;

        return DataRow(cells: [
          DataCell(
            isEditing
                ? TextFormField(
                    initialValue: orderTable.customer,
                    onChanged: (newValue) {
                      orderTable.customer = newValue;
                    },
                  )
                : Text(orderTable.customer),
          ),
          DataCell(
            isEditing
                ? TextFormField(
                    initialValue: orderTable.product,
                    onChanged: (newValue) {
                      orderTable.product = newValue;
                    },
                  )
                : Text(orderTable.product),
          ),
          DataCell(
            isEditing
                ? TextFormField(
                    initialValue: orderTable.quantity.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (newValue) {
                      orderTable.quantity = int.parse(newValue);
                    },
                  )
                : Text(orderTable.quantity.toString()),
          ),
          DataCell(
            isEditing
                ? TextFormField(
                    initialValue: orderTable.unit,
                    onChanged: (newValue) {
                      orderTable.unit = newValue;
                    },
                  )
                : Text(orderTable.unit),
          ),
          DataCell(
            InkWell(
              onTap: () {
                setState(() {
                  widget.currentlyEditingRow = isEditing ? null : orderTable;
                });
              },
              child: isEditing
                  ? const Icon(Icons.save, color: Colors.teal)
                  : const Icon(
                      Icons.edit,
                      color: Colors.blue,
                    ),
            ),
          ),
          DataCell(
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  widget.orderDetailsList.remove(orderTable);
                });
              },
            ),
          ),
        ]);
      }).toList(),
    );
  }
}
