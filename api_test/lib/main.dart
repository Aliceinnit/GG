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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
      navigatorKey: navigatorKey,
      title: 'iMat Demo',      theme: ThemeData(
        colorScheme: AppTheme.colorScheme,
        // Apply AppTheme text styles and ensure no underlines
        textTheme: TextTheme(
          displayLarge: AppTheme.headingLarge,
          displayMedium: AppTheme.headingLarge, // You can adjust this if AppTheme.headingLarge is too big for displayMedium
          displaySmall: AppTheme.headingMedium,
          headlineLarge: AppTheme.headingLarge,
          headlineMedium: AppTheme.headingMedium,
          headlineSmall: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600), // Example: using bodyLarge with emphasis
          titleLarge: AppTheme.headingMedium,    // Often used for AppBar titles, dialog titles
          titleMedium: AppTheme.bodyLarge,     // Standard for list item titles
          titleSmall: AppTheme.bodyMedium,    // Smaller titles or captions
          bodyLarge: AppTheme.bodyLarge,
          bodyMedium: AppTheme.bodyMedium,    // Default text style for most content
          bodySmall: AppTheme.bodySmall,
          labelLarge: AppTheme.buttonTextStyle, // Specifically for button text
          labelMedium: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w500), // Example for input labels
          labelSmall: AppTheme.bodySmall,     // For the smallest labels
        ).apply(
          decoration: TextDecoration.none, // Apply no underline globally to all text styles in the theme
          // The colors defined in each AppTheme TextStyle (e.g., AppTheme.textPrimary, AppTheme.textSecondary, AppTheme.buttonText)
          // will be preserved as they are part of the specific TextStyle objects.
        ),
        // Ensure no underlines on buttons and other elements
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            // textStyle will be derived from theme.textTheme.labelLarge by default
            // We only need to ensure decoration is none if not covered by global apply
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
