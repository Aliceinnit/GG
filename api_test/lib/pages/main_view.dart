import 'dart:ui';
import 'package:api_test/widgets/left_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_test/app_theme.dart';
import 'package:api_test/model/imat/product.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/pages/account_view.dart';
import 'package:api_test/pages/history_view.dart';
import 'package:api_test/pages/favorites_view.dart';
import 'package:api_test/widgets/product_tile.dart';
import 'package:api_test/widgets/app_navigation_bar.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> with TickerProviderStateMixin {
  bool _showSidebar = false;
  late AnimationController _animationController;
  late Animation<Offset> _sidebarSlideAnimation;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
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
            children: [              AppNavigationBar(
                onSearch: (query) {
                  if (query.isNotEmpty) {
                    final searchResults = iMat.findProducts(query);
                    iMat.selectSelection(searchResults);
                  } else {
                    iMat.selectAllProducts();
                  }
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
          ),          if (_showSidebar)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showSidebar = false;
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
            ),if (_showSidebar)
            Positioned(
              top: 64,
              right: 0,
              child: SlideTransition(
                position: _sidebarSlideAnimation,
                child: Container(
                  width: 280,
                  height: MediaQuery.of(context).size.height - 64,
                  color: AppTheme.headerGreen,
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.close, color: AppTheme.primaryPurple),
                          onPressed: () => setState(() => _showSidebar = false),
                        ),
                      ),
                      Text("Mina sidor", style: AppTheme.headingMedium),
                      const SizedBox(height: AppTheme.paddingLarge),
                      ListTile(
                        leading: Icon(Icons.favorite, color: AppTheme.primaryPurple),
                        title: Text("Favoriter", style: AppTheme.bodyLarge),
                        onTap: () {
                          setState(() => _showSidebar = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FavoritesView()),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.history, color: AppTheme.primaryPurple),
                        title: Text("Tidigare inköp", style: AppTheme.bodyLarge),
                        onTap: () {
                          setState(() => _showSidebar = false);
                          _showHistory(context);
                        },
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: AppTheme.primaryButtonStyle,
                          onPressed: () => _showAccount(context),
                          child: Text('Logga in', style: AppTheme.buttonTextStyle),
                        ),
                      ),
                    ],
                  ),                ),
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
  }

  Widget _centerStage(BuildContext context, List<Product> products) {
    // Calculate responsive grid columns based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;

    if (screenWidth > 1400) {
      crossAxisCount = 6; // Keep 6 for very wide screens (your preference)
    } else if (screenWidth > 1200) {
      crossAxisCount = 5;
    } else if (screenWidth > 1000) {
      crossAxisCount = 4;
    } else if (screenWidth > 800) {
      crossAxisCount = 3;
    } else if (screenWidth > 600) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2; // Adjusted for very small screens
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _weeklyOfferBanner(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 24),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductTile(products[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _weeklyOfferBanner() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppTheme.headerGreen,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Veckans erbjudanden!',
              style: AppTheme.headingLarge,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                // Lägg till valfri navigation eller funktion
              },
              child: Text('Börja handla', style: AppTheme.buttonTextStyle),
            ),
          ],
        ),
        Image.asset(
          'assets/images/feature.png', // Se till att du har en bild i din assets-mapp
          width: 250,
          fit: BoxFit.contain,
        ),
      ],
    ),
  );
}
}
