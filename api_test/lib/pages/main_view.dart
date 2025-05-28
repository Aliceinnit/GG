import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_test/app_theme.dart';
import 'package:api_test/model/imat/product.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/pages/account_view.dart';
import 'package:api_test/pages/checkout_flow.dart';
import 'package:api_test/pages/history_view.dart';
import 'package:api_test/widgets/cart_view.dart';
import 'package:api_test/widgets/product_tile.dart';
import 'package:api_test/widgets/app_navigation_bar.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> with TickerProviderStateMixin {
  bool _showSidebar = false;
  bool _showCartOverlay = false;
  late AnimationController _animationController;
  late Animation<Offset> _cartSlideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
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
    var products = iMat.selectProducts;    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Column(
            children: [
              // Use the new navigation bar
              AppNavigationBar(
                onSearch: (query) {
                  // Implement search functionality using findProducts method
                  if (query.isNotEmpty) {
                    final searchResults = iMat.findProducts(query);
                    iMat.selectSelection(searchResults);
                  } else {
                    iMat.selectAllProducts();
                  }
                },
                onCartPressed: () {
                  // You can implement cart modal or navigation here
                  _showCartModal(context, iMat);
                },
                onAccountPressed: () {
                  _showAccount(context);
                },
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _leftPanel(iMat),
                    Expanded(child: _centerStage(context, products)),
                    _shoppingCart(context, iMat),
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
  void _showCartModal(BuildContext context, ImatDataHandler iMat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD2EBD8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kundvagn',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CartView(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CheckoutFlow()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Till kassan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
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

  Widget _shoppingCart(BuildContext context, ImatDataHandler iMat) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFFAF7F9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kundvagn', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(height: 500, child: CartView()),
          const SizedBox(height: 12),          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckoutFlow()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Till kassan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }  void _showAccount(BuildContext context) {
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
