import 'dart:convert';

class Order {
  final String id;
  final String status;
  final String total;
  final String fulljson;

  Order({
    required this.id,
    required this.status,
    required this.total,
    required this.fulljson,
  });

  // Method to create an Order instance from JSON data
  factory Order.fromJson(Map<String, dynamic> orderJson) {
    return Order(
      id: orderJson['id'].toString(),
      status: orderJson['status'] as String,
      total: orderJson['total'] as String,
      fulljson: json.encode(orderJson),
    );
  }
}
