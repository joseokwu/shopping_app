import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/orders.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Consumer<Cart>(
                    builder: (context, value, child) => Chip(
                      label: Text(
                        '\$${value.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge
                                .color),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  OrderButton(cart: cart)
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: Consumer<Cart>(
            builder: (context, value, child) => ListView.builder(
              itemCount: value.items.length,
              itemBuilder: (context, i) {
                return CartItem(
                    id: value.items.values.toList()[i].id,
                    productId: value.items.keys.toList()[i],
                    title: value.items.values.toList()[i].title,
                    quantity: value.items.values.toList()[i].quantity,
                    price: value.items.values.toList()[i].price);
              },
            ),
          ))
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  Future<void> _handleOrder(BuildContext context, Cart value) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Orders>(context, listen: false)
          .addOrder(value.items.values.toList(), value.totalAmount);
      value.clearItems();
    } catch (e) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('An error occurred'),
          content: Text('OOPS! We were unable to place this order'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Okay'))
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
        onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
            ? null
            : () => _handleOrder(context, widget.cart));
  }
}
