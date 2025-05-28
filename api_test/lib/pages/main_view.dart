import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_test/app_theme.dart';
import 'package:api_test/model/imat/product.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/pages/account_view.dart';
import 'package:api_test/pages/history_view.dart';
import 'package:api_test/widgets/cart_view.dart';
import 'package:api_test/widgets/product_tile.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> with SingleTickerProviderStateMixin {
  bool _showSidebar = false;
  bool _showCartOverlay = false;
  late AnimationController _animationController;
  late Animation<Offset> _cartSlideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _cartSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var iMat = context.watch<ImatDataHandler>();
    var products = iMat.selectProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFFCEEF4),
      body: Stack(
        children: [
          Column(
            children: [
              _header(context, iMat),
              const SizedBox(height: AppTheme.paddingMedium),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _leftPanel(iMat),
                    Expanded(child: _centerStage(context, products)),
                  ],
                ),
              ),
            ],
          ),

          if (_showSidebar || _showCartOverlay)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showSidebar = false;
                    _showCartOverlay = false;
                  });
                  _animationController.reverse();
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),
            ),

          if (_showSidebar)
            Positioned(
              top: 120,
              right: 0,
              child: Container(
                width: 250,
                height: MediaQuery.of(context).size.height - 120,
                color: const Color(0xffd2ebd8),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _showSidebar = false),
                      ),
                    ),
                    const Text("Mina sidor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.favorite),
                      title: const Text("Favoriter"),
                      onTap: () {
                        setState(() => _showSidebar = false);
                        iMat.selectFavorites();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text("Tidigare inköp"),
                      onTap: () {
                        setState(() => _showSidebar = false);
                        _showHistory(context);
                      },
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A2C4B), // Mörklila
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () => _showAccount(context),
                      child: const Text(
                        'Logga in',
                        style: TextStyle(color: Color(0xFFFCEEF4)), // Ljusrosa
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_showCartOverlay)
            Positioned(
              top: 120,
              right: 0,
              child: SlideTransition(
                position: _cartSlideAnimation,
                child: Container(
                  width: 320,
                  height: MediaQuery.of(context).size.height - 120,
                  color: const Color(0xffd2ebd8),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Stäng',
                          onPressed: () {
                            setState(() => _showCartOverlay = false);
                            _animationController.reverse();
                          },
                        ),
                      ),
                      const Text('Kundvagn', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Expanded(child: CartView()),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          iMat.placeOrder();
                        },
                        child: const Text('Köp!'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, ImatDataHandler iMat) {
    return Container(
      color: const Color.fromARGB(255, 210, 235, 216),
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
            child: const Text(
              'iMat',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3A2C4B),
              ),
            ),
          ),
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Sök varor",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                tooltip: 'Varukorg',
                onPressed: () {
                  setState(() => _showCartOverlay = true);
                  _animationController.forward();
                },
                iconSize: 70,
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                tooltip: 'Mina sidor',
                onPressed: () => setState(() => _showSidebar = true),
                iconSize: 70,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _leftPanel(ImatDataHandler iMat) {
    final categories = [
      'Erbjudanden',
      'Kött, fågel',
      'Frukt och grönt',
      'Mejeri',
      'Bröd och kaffebröd',
      'Fryst',
      'Fisk och skaldjur',
      'Färdigmat',
      'Vegetarisk',
      'Godis, snacks',
      'Dryck',
      'Blommor',
    ];

    return Container(
      width: 220,
      color: const Color(0xfffae8ed),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kategorier', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  dense: true,
                  title: Text(categories[index]),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _centerStage(BuildContext context, List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductTile(products[index]);
      },
    );
  }

  void _showAccount(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountView()),
    );
  }

  void _showHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryView()),
    );
  }
}
