import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/edit_product_screen.dart';
import 'package:flutter_complete_guide/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/user_products_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _setProductsData(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<Products>(context);

    return Scaffold(
      appBar: AppBar(title: Text('User Products'), actions: [
        IconButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(EditProductScreen.routeName),
          icon: Icon(Icons.add),
        ),
      ]),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _setProductsData(context),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: products.items.length,
              itemBuilder: (context, i) => Column(
                children: [
                  UserProductsItem(
                      id: products.items[i].id,
                      title: products.items[i].title,
                      imageUrl: products.items[i].imageUrl),
                  Divider()
                ],
              ),
            )),
      ),
    );
  }
}
