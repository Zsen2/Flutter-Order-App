import 'package:flutter/material.dart';
import 'package:fruit_inv/models/customLists_model.dart';
import 'package:fruit_inv/services/database_helper.dart';

class AddCustomerProductPage extends StatefulWidget {
  final String type;

  const AddCustomerProductPage({Key? key, required this.type})
      : super(key: key);

  @override
  _AddCustomerProductPageState createState() => _AddCustomerProductPageState();
}

class _AddCustomerProductPageState extends State<AddCustomerProductPage> {
  Stream<List<dynamic>>? _currentStream;
  final TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateStream();
  }

  void _updateStream() {
    if (widget.type == 'Customer') {
      _currentStream = DatabaseHelper.customerStream();
    } else if (widget.type == 'Product') {
      _currentStream = DatabaseHelper.productStream();
    } else if (widget.type == 'Unit') {
      _currentStream = DatabaseHelper.unitStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage ${widget.type}s'),
        actions: [addButton(context)],
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: _currentStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return ListTile(
                  title: Text(widget.type == 'Customer'
                      ? item.customer
                      : widget.type == 'Product'
                          ? item.product
                          : item.unit),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditDialog(context, item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => widget.type == 'Customer'
                            ? DatabaseHelper.deleteCustomer(item.id)
                            : widget.type == 'Product'
                                ? DatabaseHelper.deleteProduct(item.id)
                                : DatabaseHelper.deleteUnit(item.id),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }

  Widget addButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () => _showAddDialog(context),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    _textFieldController.clear(); // Clear controller for new entries
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Add ${widget.type}'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Enter ${widget.type} name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (widget.type == 'Customer') {
                  CustomerList newCustomer =
                      CustomerList(customer: _textFieldController.text);
                  DatabaseHelper.addCustomer(newCustomer);
                } else if (widget.type == 'Product') {
                  ProductList newProduct =
                      ProductList(product: _textFieldController.text);
                  DatabaseHelper.addProduct(newProduct);
                } else if (widget.type == 'Unit') {
                  UnitList newUnit = UnitList(unit: _textFieldController.text);
                  DatabaseHelper.addUnit(newUnit);
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(BuildContext context, dynamic item) async {
    _textFieldController.text = widget.type == 'Customer'
        ? item.customer
        : widget.type == 'Product'
            ? item.product
            : item.unit; // Pre-populate text field
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Edit ${widget.type}'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Enter ${widget.type} name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                if (widget.type == 'Customer') {
                  CustomerList updatedCustomer = CustomerList(
                      id: item.id, // maintain the ID for updating
                      customer: _textFieldController.text);
                  DatabaseHelper.updateCustomer(updatedCustomer);
                } else if (widget.type == 'Product') {
                  ProductList updatedProduct = ProductList(
                      id: item.id, // maintain the ID for updating
                      product: _textFieldController.text);
                  DatabaseHelper.updateProduct(updatedProduct);
                } else if (widget.type == 'Unit') {
                  UnitList updatedUnit = UnitList(
                      id: item.id, // maintain the ID for updating
                      unit: _textFieldController.text);
                  DatabaseHelper.updateUnit(updatedUnit);
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
