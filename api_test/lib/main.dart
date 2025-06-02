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
import 'dart:io' show Platform;
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main(List<String> arguments) {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ImatDataHandler()),
        ChangeNotifierProvider(create: (context) => CartOverlayProvider()),
        ChangeNotifierProvider(create: (context) => AccountOverlayProvider()),
      ],
      child: MyApp(resetUserData: arguments.contains('--reset-user-data')),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool resetUserData;
  
  const MyApp({super.key, this.resetUserData = false});
  
  @override
  Widget build(BuildContext context) {
    if (resetUserData) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final dataHandler = Provider.of<ImatDataHandler>(context, listen: false);
        await dataHandler.reset();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All user data has been reset'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
        print('User data reset completed');
      });
    }
    
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'iMat Demo',      
      theme: ThemeData(
        colorScheme: AppTheme.colorScheme,
        textTheme: TextTheme(
          displayLarge: AppTheme.headingLarge,
          displayMedium: AppTheme.headingLarge,
          displaySmall: AppTheme.headingMedium,
          headlineLarge: AppTheme.headingLarge,
          headlineMedium: AppTheme.headingMedium,
          headlineSmall: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          titleLarge: AppTheme.headingMedium,
          titleMedium: AppTheme.bodyLarge,
          titleSmall: AppTheme.bodyMedium,
          bodyLarge: AppTheme.bodyLarge,
          bodyMedium: AppTheme.bodyMedium,
          bodySmall: AppTheme.bodySmall,
          labelLarge: AppTheme.buttonTextStyle,
          labelMedium: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w500),
          labelSmall: AppTheme.bodySmall,
        ).apply(
          decoration: TextDecoration.none,
        ),
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
      ),      
      debugShowCheckedModeBanner: false,      
      builder: (context, child) {
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
        ],
      ),
    );
  }

  void _runTests() async {
    var response = await InternetHandler.getCreditCard();
    dbugPrint(response);

    var json = jsonDecode(response);
    CreditCard creditCard = CreditCard.fromJson(json);
    dbugPrint('CreditCard ${creditCard.holdersName}');

    response = await InternetHandler.getCustomer();
    json = jsonDecode(response);
    Customer customer = Customer.fromJson(json);
    dbugPrint('Customer ${customer.firstName} ${customer.lastName}');
  }
}
