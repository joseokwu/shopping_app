import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/auth.dart';
import 'package:flutter_complete_guide/providers/cart.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  const ProductItem(
      {@required this.id, @required this.imageUrl, @required this.title});

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
    final scaffold = ScaffoldMessenger.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
            onTap: () => Navigator.of(context)
                .pushNamed(ProductDetailScreen.routeName, arguments: id),
            child: Hero(
              tag: product.id,
              child: FadeInImage(
                placeholder:
                    AssetImage('assets/images/product-placeholder.png'),
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            )),
        footer: GridTileBar(
          backgroundColor: Colors.black45,
          title: Text(title, textAlign: TextAlign.center),
          leading: Consumer<Product>(
            builder: (context, value, child) => IconButton(
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              // color: Theme.of(context).accentColor,
              onPressed: () async {
                try {
                  await product.toggleFavorite(auth.getToken, auth.getUserId);
                } catch (e) {
                  scaffold.showSnackBar(SnackBar(
                    content: Text(
                      'Unable to add to favorites',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).errorColor),
                    ),
                    duration: Duration(seconds: 2),
                  ));
                }
              },
            ),
          ),
          trailing: IconButton(
              icon: Icon(Icons.shopping_cart),
              // color: Theme.of(context).accentColor,
              onPressed: () {
                cart.addItem(
                    productId: product.id,
                    price: product.price,
                    title: product.title);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added item to cart'),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          cart.removeSingleItem(product.id);
                        }),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
