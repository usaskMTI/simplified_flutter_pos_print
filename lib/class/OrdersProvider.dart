import 'package:flutter/material.dart';
import 'package:esc_printer_test/class/Order.dart';

class OrdersProvider with ChangeNotifier {
  List<Order> _currentOrders = [];
  List<Order> _printedOrders = [];

  List<Order> get currentOrders => _currentOrders;
  List<Order> get printedOrders => _printedOrders;

  void addOrder(Order order) {
    _currentOrders.add(order);
    notifyListeners();
  }

  void printOrder(Order order) {
    _currentOrders.remove(order);
    _printedOrders.add(order);
    notifyListeners();
  }
}
