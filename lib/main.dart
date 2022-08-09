import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/custom_route.dart';
import '../screens/auth_screen.dart';
import '../screens/splash_screen.dart';
import '../providers/auth.dart';
import '../providers/cart.dart';
import '../screens/product_detail_screen.dart';
import '../screens/product_overview_screen.dart';
import '../providers/orders.dart';
import '../screens/cart_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';
import '../providers/products.dart';
import '../screens/edit_product_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            update: (context, value, previous) => Products(value.getToken,
                value.getUserId, previous == null ? [] : previous.items),
          ),
          ChangeNotifierProvider(
            create: (context) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            update: (context, value, previous) => Orders(value.getToken,
                value.getUserId, previous == null ? [] : previous.orders),
          ),
        ],
        child: Consumer<Auth>(
          builder: (context, value, child) {
            return MaterialApp(
              title: 'MyShop',
              theme: ThemeData(
                  pageTransitionsTheme: PageTransitionsTheme(builders: {
                    TargetPlatform.android: CustomPageTransitionBuilder(),
                    TargetPlatform.iOS: CustomPageTransitionBuilder()
                  }),
                  primarySwatch: Colors.purple,
                  accentColor: Colors.deepOrange,
                  fontFamily: 'Lato'),
              home: value.auth
                  ? ProductOverviewScreen()
                  : FutureBuilder(
                      future: value.tryAutoLogin(),
                      builder: (context, snapshot) =>
                          snapshot.connectionState == ConnectionState.waiting
                              ? SplashScreen()
                              : AuthScreen(),
                    ),
              routes: {
                ProductOverviewScreen.routeName: (context) =>
                    ProductOverviewScreen(),
                ProductDetailScreen.routeName: (context) =>
                    ProductDetailScreen(),
                CartScreen.routeName: (context) => CartScreen(),
                OrdersScreen.routeName: (context) => OrdersScreen(),
                UserProductsScreen.routeName: (context) => UserProductsScreen(),
                EditProductScreen.routeName: (context) => EditProductScreen()
              },
            );
          },
        ));
  }
}
