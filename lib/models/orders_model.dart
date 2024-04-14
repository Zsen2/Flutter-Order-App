class Orders {
  final int? id;
  final String customer;
  final String date;

  const Orders({
    required this.customer,
    required this.date,
    this.id,
  });

  factory Orders.fromJson(Map<String, dynamic> json) => Orders(
        id: json["id"],
        customer: json["customer"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer': customer,
        'date': date,
      };
}

class OrderDetails {
  final int? id;
  final int orderId;
  final String product;
  final int quantity;
  final String unit;

  const OrderDetails({
    required this.orderId,
    required this.product,
    required this.quantity,
    required this.unit,
    this.id,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) => OrderDetails(
        id: json["id"],
        orderId: json["orderId"],
        product: json["product"],
        quantity: json["quantity"],
        unit: json["unit"],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'product': product,
        'quantity': quantity,
        'unit': unit,
      };
}
