import 'package:api_test/app_theme.dart';
import 'package:api_test/model/imat/credit_card.dart';
import 'package:api_test/model/imat/customer.dart';
import 'package:api_test/model/imat/util/functions.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/model/internet_handler.dart';
import 'package:api_test/pages/main_view.dart';
import 'package:api_test/widgets/cart_overlay_provider.dart';
import 'package:api_test/widgets/account_overlay_provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ImatDataHandler()),
        ChangeNotifierProvider(create: (context) => CartOverlayProvider()),
        ChangeNotifierProvider(create: (context) => AccountOverlayProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iMat Demo',      theme: ThemeData(
        colorScheme: AppTheme.colorScheme,
        // Add text theme to prevent yellow underlines
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          displayMedium: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          displaySmall: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          headlineLarge: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          headlineMedium: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          headlineSmall: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          titleLarge: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          titleMedium: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          titleSmall: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          bodyLarge: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          bodyMedium: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          bodySmall: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          labelLarge: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          labelMedium: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          labelSmall: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
        ),
        // Ensure no underlines on buttons and other elements
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(decoration: TextDecoration.none),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: const TextStyle(decoration: TextDecoration.none),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            textStyle: const TextStyle(decoration: TextDecoration.none),
          ),
        ),
      ),      debugShowCheckedModeBanner: false,      builder: (context, child) {
        return Material(
          child: AccountOverlayWrapper(
            child: CartOverlayWrapper(
              child: child ?? const MainView(),
            ),
          ),
        );
      },
      home: const MainView(),
    );
  }
}

// This code is not used.
// Included for testing purposes only
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Image? image;

  @override
  void initState() {
    super.initState();
    //loadImage();
  }

  void loadImage() async {
    final img = await InternetHandler.fetchAndCacheImage(114);
    setState(() {
      image = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _runTests();
            },
            child: const Center(child: Text('Testa')),
          ),
          //image ?? CircularProgressIndicator(),
        ],
      ),
    );
  }

  void _runTests() async {
    //_fetchDetails();
    //var products = await InternetHandler.getProducts();

    //print(products);
    /*
    //var favorites = await InternetHandler.getFavorites();
    //print(favorites);

    var response = await InternetHandler.getProduct(14);
    print(response);

    var json = jsonDecode(response);
    Product product = Product.fromJson(json);
    print('Product ${product.name}');
*/
    var response = await InternetHandler.getCreditCard();
    dbugPrint(response);

    var json = jsonDecode(response);
    CreditCard creditCard = CreditCard.fromJson(json);
    dbugPrint('CreditCard ${creditCard.holdersName}');

    response = await InternetHandler.getCustomer();
    json = jsonDecode(response);
    Customer customer = Customer.fromJson(json);
    dbugPrint('Customer ${customer.firstName} ${customer.lastName}');

    /*
    response = await InternetHandler.getUser();
    print('User ${response}');

    response = await InternetHandler.getOrders();
    //print('Orders ${response}');

    response = await InternetHandler.getShoppingCart();
    print('Orders ${response}');

    var image = await InternetHandler.fetchAndCacheImage(25);
    */
  }
}
