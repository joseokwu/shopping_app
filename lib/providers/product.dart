import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_complete_guide/models/http_exceptions.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {this.description,
      this.id,
      this.imageUrl,
      this.isFavorite = false,
      this.price,
      this.title});

  Future<void> toggleFavorite(String authToken, String userId) async {
    final url = Uri.parse(
        'https://my-shop-app-2f67e-default-rtdb.firebaseio.com/$userId/products/$id.json?auth=$authToken');
    isFavorite = !isFavorite;
    notifyListeners();
    // try {
    final res =
        await http.patch(url, body: json.encode({'isFavorite': isFavorite}));
    print(res.statusCode);
    if (res.statusCode >= 400) {
      isFavorite = !isFavorite;
      notifyListeners();
      throw HttpExceptions('Failed to Favorite');
    }
  }
}
