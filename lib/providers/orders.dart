import 'package:flutter/cupertino.dart';
import 'package:flutter_complete_guide/models/http_exceptions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({this.dateTime, this.id, this.products, this.amount});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    final url = Uri.parse(
        'https://my-shop-app-2f67e-default-rtdb.firebaseio.com/$userId/orders.json?auth=$authToken');
    try {
      final res = await http.get(url);
      final decodedRes = json.decode(res.body) as Map<String, dynamic>;
      List<OrderItem> loadedOrders = [];
      if (decodedRes == null) {
        _orders = [];
        notifyListeners();
        return;
      }
      print(decodedRes);
      decodedRes.forEach((key, value) {
        loadedOrders.add(
          OrderItem(
              amount: value['amount'],
              id: key,
              dateTime: DateTime.parse(value['dateTime']),
              products: (value['products'] as List<dynamic>)
                  .map((e) => CartItem(
                      id: e['id'],
                      title: e['title'],
                      quantity: e['quantity'],
                      price: e['price']))
                  .toList()),
        );
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://my-shop-app-2f67e-default-rtdb.firebaseio.com/$userId/orders.json?auth=$authToken');
    final time = DateTime.now();
    final res = await http.post(url,
        body: json.encode({
          'amount': total,
          'products': cartProducts
              .map((e) => {
                    'id': e.id,
                    'price': e.price,
                    'quantity': e.quantity,
                    'title': e.title
                  })
              .toList(),
          'dateTime': time.toIso8601String(),
        }));
    if (res.statusCode >= 400) {
      throw HttpExceptions('Could not add order');
    }
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(res.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
