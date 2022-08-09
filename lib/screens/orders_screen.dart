import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future _ordersFuture;
  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchOrders();
  }

  // var isLoading = false;
  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final orders = Provider.of<Orders>(context).orders;
    return Scaffold(
        appBar: AppBar(title: Text('Your Orders')),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.error != null) {
              print(snapshot.error);
              return Center(
                child: Text('Encountered a problem'),
              );
            } else {
              return Consumer<Orders>(
                builder: (context, value, child) {
                  return ListView.builder(
                    itemBuilder: (context, i) => OrderItem(value.orders[i]),
                    itemCount: value.orders.length,
                  );
                },
              );
            }
          },
        ));
  }
}
