import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/models/http_exceptions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  String authToken;
  String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favorites {
    return items.where((element) => element.isFavorite).toList();
  }

  Product getProductById(String id) {
    return items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse(
        'https://my-shop-app-2f67e-default-rtdb.firebaseio.com/$userId/products.json?auth=$authToken');
    try {
      final res = await http.get(url);
      final prods = json.decode(res.body) as Map<String, dynamic>;
      List<Product> loadedProducts = [];
      if (prods == null) return;
      prods.forEach((key, value) {
        loadedProducts.add(
          Product(
              id: key,
              description: value['description'],
              imageUrl: value['imageUrl'],
              isFavorite: value['isFavorite'],
              price: value['price'],
              title: value['title']),
        );
      });
      _items = loadedProducts.reversed.toList();
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://my-shop-app-2f67e-default-rtdb.firebaseio.com/$userId/products.json?auth=$authToken');
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'isFavorite': product.isFavorite,
          }));

      final newProduct = Product(
          id: json.decode(response.body)['name'],
          description: product.description,
          imageUrl: product.imageUrl,
          price: product.price,
          title: product.title);
      _items.add(newProduct);
      // _items.insert(0, newProduct) to insert at the beginning

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> editProduct(String id, Product product) async {
    final foundIndex = _items.indexWhere((element) => element.id == id);
    if (foundIndex >= 0) {
      final url = Uri.parse(
          'https://my-shop-app-2f67e-default-rtdb.firebaseio.com/$userId/products/$id.json?auth=$authToken');
      await http.patch(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
          }));
      _items[foundIndex] = product;
    }
    notifyListeners();
  }

  Future<void> deleteProduct(String productId) async {
    final url = Uri.parse(
        'https://my-shop-app-2f67e-default-rtdb.firebaseio.com/$userId/products/$productId?auth=$authToken');
    final productIndex =
        _items.indexWhere((element) => element.id == productId);
    var existingProduct = _items[productIndex];
    _items.removeAt(productIndex);
    notifyListeners();
    final res = await http.delete(url);
    if (res.statusCode >= 400) {
      _items.insert(productIndex, existingProduct);
      notifyListeners();
      throw HttpExceptions('Failed to delete');
    }
    existingProduct = null;
  }
}
