import 'dart:ui';
import 'package:api_test/widgets/left_panel.dart';
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
  late Animation<Offset> _sidebarSlideAnimation;

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
    _sidebarSlideAnimation = Tween<Offset>(
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
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Column(
            children: [
              AppNavigationBar(
                onSearch: (query) {
                  if (query.isNotEmpty) {
                    final searchResults = iMat.findProducts(query);
                    iMat.selectSelection(searchResults);
                  } else {
                    iMat.selectAllProducts();
                  }
                },
                onCartPressed: () {
                  setState(() => _showCartOverlay = true);
                  _animationController.forward();
                },
                onAccountPressed: () {
                  setState(() => _showSidebar = true);
                  _animationController.forward();
                },
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LeftPanel(),
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
              top: 64,
              right: 0,
              child: SlideTransition(
                position: _sidebarSlideAnimation,
                child: Container(
                  width: 280,
                  height: MediaQuery.of(context).size.height - 64,
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
                          backgroundColor: const Color(0xFF3A2C4B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: () => _showAccount(context),
                        child: const Text(
                          'Logga in',
                          style: TextStyle(color: Color(0xFFFCEEF4)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_showCartOverlay)
            Positioned(
              top: 64,
              right: 0,
              child: SlideTransition(
                position: _cartSlideAnimation,
                child: Container(
                  width: 320,
                  height: MediaQuery.of(context).size.height - 64,
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
                      const Expanded(child: CartView()),
                      const SizedBox(height: 12),
                      ElevatedButton(
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Till kassan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
  }  Widget _centerStage(BuildContext context, List<Product> products) {
    // Calculate responsive grid columns based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    
    if (screenWidth > 1400) {
      crossAxisCount = 6; // Very wide screens
    } else if (screenWidth > 1200) {
      crossAxisCount = 5; // Large screens
    } else if (screenWidth > 1000) {
      crossAxisCount = 4; // Medium-large screens
    } else if (screenWidth > 800) {
      crossAxisCount = 3; // Medium screens
    } else if (screenWidth > 600) {
      crossAxisCount = 3; // Small-medium screens
    } else {
      crossAxisCount = 3; // Small screens
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 0.7, // Optimized for more compact tiles
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductTile(products[index]);
      },
    );
  }

  Widget _shoppingCart(BuildContext context, ImatDataHandler iMat) {
    return const SizedBox.shrink();
  }
}
