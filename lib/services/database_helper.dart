import 'package:fruit_inv/models/customLists_model.dart';
import 'package:fruit_inv/models/orders_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static StreamController<List<CustomerList>>? _customerStreamController;
  static StreamController<List<ProductList>>? _productStreamController;

  static const int _version = 1;
  static const String _dbname = 'database2.db';

  static Future<Database> _getDB() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbname),
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE IF NOT EXISTS Orders(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          customer TEXT, 
          date TEXT
        )
      ''');
        await db.execute('''
        CREATE TABLE IF NOT EXISTS OrderDetails(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          orderId INTEGER,
          product TEXT, 
          quantity INTEGER, 
          unit TEXT, 
          FOREIGN KEY (orderId) REFERENCES Orders(id)
        )
      ''');
        await db.execute('''
        CREATE TABLE IF NOT EXISTS CustomerList(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          customer TEXT
        )
      ''');
        await db.execute('''
        CREATE TABLE IF NOT EXISTS ProductList(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          product TEXT
        )
      ''');
      },
      version: _version,
    );
  }

  // Add method for adding orders
  static Future<int> addOrder(Orders order) async {
    final db = await _getDB();
    return await db.insert('Orders', order.toJson());
  }

  // Add method for adding order details
  static Future<int> addOrderDetail(OrderDetails orderDetail) async {
    final db = await _getDB();
    return await db.insert('OrderDetails', orderDetail.toJson());
  }

  // Add method for updating orders
  static Future<int> updateOrder(Orders order) async {
    final db = await _getDB();
    return await db.update(
      'Orders',
      order.toJson(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  // Add method for updating order details
  static Future<int> updateOrderDetail(OrderDetails orderDetail) async {
    final db = await _getDB();
    return await db.update(
      'OrderDetails',
      orderDetail.toJson(),
      where: 'id = ?',
      whereArgs: [orderDetail.id],
    );
  }

  // Add method for deleting orders
  static Future<int> deleteOrder(int id) async {
    deleteOrderDetail(id);

    final db = await _getDB();
    return await db.delete(
      'Orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Add method for deleting order details
  static Future<int> deleteOrderDetail(int id) async {
    final db = await _getDB();
    return await db.delete(
      'OrderDetails',
      where: 'orderId = ?',
      whereArgs: [id],
    );
  }

  // Add method for clearing all orders
  static Future<void> clearAllOrders() async {
    final Database db = await _getDB();
    await db.delete('Orders');
    await db.delete('OrderDetails');
  }

  // Add method for getting all orders
  static Future<List<Orders>> getAllOrders() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("Orders");
    return List.generate(maps.length, (index) => Orders.fromJson(maps[index]));
  }

  // Add method for getting all order details for a specific order
  static Future<List<OrderDetails>> getOrderDetails(int orderId) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query(
      'OrderDetails',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
    return List.generate(
        maps.length, (index) => OrderDetails.fromJson(maps[index]));
  }

  static Future<int> addCustomer(CustomerList customerList) async {
    final db = await _getDB();
    return await db.insert('CustomerList', customerList.toJson());
  }

  static Future<int> addProduct(ProductList productList) async {
    final db = await _getDB();
    return await db.insert('ProductList', productList.toJson());
  }

  static Future<List<CustomerList>> getCustomers() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("CustomerList");
    return List.generate(
        maps.length, (index) => CustomerList.fromJson(maps[index]));
  }

  static Future<List<ProductList>> getProducts() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("ProductList");
    return List.generate(
        maps.length, (index) => ProductList.fromJson(maps[index]));
  }

  // Method for deleting a customer by ID
  static Future<int> deleteCustomer(int customerId) async {
    final db = await _getDB();
    return await db.delete(
      'CustomerList',
      where: 'id = ?',
      whereArgs: [customerId],
    );
  }

  // Method for deleting a product by ID
  static Future<int> deleteProduct(int productId) async {
    final db = await _getDB();
    return await db.delete(
      'ProductList',
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  static Stream<List<CustomerList>> customerStream() {
    _customerStreamController
        ?.close(); // Close existing stream controller if any to avoid multiple subscriptions
    _customerStreamController = StreamController<List<CustomerList>>.broadcast(
      onListen: () async {
        while (_customerStreamController!.hasListener) {
          final customers = await getCustomers();
          _customerStreamController!.add(customers);
          await Future.delayed(const Duration(
              milliseconds: 500)); // Adjust the frequency as needed
        }
      },
    );
    return _customerStreamController!.stream;
  }

  static Stream<List<ProductList>> productStream() {
    _productStreamController
        ?.close(); // Close existing stream controller if any to avoid multiple subscriptions
    _productStreamController = StreamController<List<ProductList>>.broadcast(
      onListen: () async {
        while (_productStreamController!.hasListener) {
          final products = await getProducts();
          _productStreamController!.add(products);
          await Future.delayed(const Duration(
              milliseconds: 500)); // Adjust the frequency as needed
        }
      },
    );
    return _productStreamController!.stream;
  }

  // Method for updating a customer
  static Future<int> updateCustomer(CustomerList customer) async {
    final db = await _getDB();
    return await db.update(
      'CustomerList',
      customer.toJson(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  // Method for updating a product
  static Future<int> updateProduct(ProductList product) async {
    final db = await _getDB();
    return await db.update(
      'ProductList',
      product.toJson(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }
}
