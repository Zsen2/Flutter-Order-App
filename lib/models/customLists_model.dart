class CustomerList {
  final int? id;
  final String customer;

  const CustomerList({
    required this.customer,
    this.id,
  });

  factory CustomerList.fromJson(Map<String, dynamic> json) => CustomerList(
        id: json["id"],
        customer: json["customer"],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer': customer,
      };
}

class ProductList {
  final int? id;
  final String product;

  const ProductList({
    required this.product,
    this.id,
  });

  factory ProductList.fromJson(Map<String, dynamic> json) => ProductList(
        id: json["id"],
        product: json["product"],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product': product,
      };
}

class UnitList {
  final int? id;
  final String unit;

  const UnitList({
    required this.unit,
    this.id,
  });

  factory UnitList.fromJson(Map<String, dynamic> json) => UnitList(
        id: json["id"],
        unit: json["unit"],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'unit': unit,
      };
}
