import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(15),
      child: Column(children: [
        ListTile(
          title: Text('\$${widget.order.amount}'),
          subtitle: Text(
            DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
          ),
          trailing: IconButton(
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              icon: Icon(Icons.expand_more)),
        ),
        // if (_expanded)
        AnimatedContainer(
          // constraints: BoxConstraints(minHeight: ),
          height: _expanded
              ? min(widget.order.products.length * 20.0 + 10, 100)
              : 0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            height: min(widget.order.products.length * 20.0 + 10, 100),
            child: ListView(
                children: widget.order.products
                    .map((prod) => Row(children: [
                          Text(
                            prod.title,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${prod.quantity} x \$${prod.price}',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          )
                        ], mainAxisAlignment: MainAxisAlignment.spaceBetween))
                    .toList()),
          ),
        )
      ]),
    );
  }
}
