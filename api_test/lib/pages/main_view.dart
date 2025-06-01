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
import 'package:api_test/pages/subcategory_view.dart';
import 'package:api_test/widgets/product_tile.dart';
import 'package:api_test/widgets/app_navigation_bar.dart';
import 'package:api_test/main.dart'; // Import main.dart to access navigatorKey

class MainView extends StatefulWidget {
  final int? initialTabIndex; // Added
  final bool expandHistoryOrders; // Added

  const MainView({super.key, this.initialTabIndex, this.expandHistoryOrders = false}); // Modified constructor

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialTabIndex == 2 && mounted) { // 2 corresponds to History view
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushReplacement( // Using pushReplacement to avoid MainView stacking if not desired
            MaterialPageRoute(
              builder: (context) => HistoryView(expandOrders: widget.expandHistoryOrders),
            ),
          );
        } else {
          print('navigatorKey.currentState is NULL in MainView initState');
        }
      }
    });
  } // <--- This closing brace was missing

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
          ),
          if (_showSidebar)
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
            ), // End of Positioned.fill
            if (_showSidebar) // Corrected line: separated comma and if
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
                          onPressed: () {
                            if (mounted) {
                              setState(() => _showSidebar = false);
                              _animationController.reverse();
                            }
                          },
                        ),
                      ),
                      Text("Mina sidor", style: AppTheme.headingMedium),
                      const SizedBox(height: AppTheme.paddingLarge),
                      ListTile(
                        leading: Icon(Icons.favorite, color: AppTheme.primaryPurple),
                        title: Text("Favoriter", style: AppTheme.bodyLarge),
                        onTap: () {
                          if (navigatorKey.currentState == null) {
                            print('navigatorKey.currentState is NULL in MainView for Favoriter');
                            return;
                          }
                          navigatorKey.currentState!.push(
                            MaterialPageRoute(builder: (context) => const FavoritesView()),
                          );
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() => _showSidebar = false);
                              _animationController.reverse();
                            }
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.history, color: AppTheme.primaryPurple),
                        title: Text("Mina inköp", style: AppTheme.bodyLarge), // Changed text here
                        onTap: () {
                          // _showHistoryWithKey(); // Use new method with navigatorKey // Original
                          if (navigatorKey.currentState == null) {
                            print('navigatorKey.currentState is NULL in MainView for Mina inköp');
                            return;
                          }
                          navigatorKey.currentState!.push(
                            MaterialPageRoute(builder: (context) => const HistoryView(expandOrders: false)), // Pass default false if opened from sidebar
                          );
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() => _showSidebar = false);
                              _animationController.reverse();
                            }
                          });
                        },
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: AppTheme.primaryButtonStyle,
                          onPressed: () {
                            _showAccountWithKey(); // Use new method with navigatorKey
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() => _showSidebar = false);
                                _animationController.reverse();
                              }
                            });
                          },
                          child: Text('Logga in', style: AppTheme.buttonTextStyle),
                        ),
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

  // New method using GlobalKey
  void _showAccountWithKey() {
    if (navigatorKey.currentState == null) {
      print('navigatorKey.currentState is NULL in MainView _showAccountWithKey');
      return;
    }
    navigatorKey.currentState!.push(
      MaterialPageRoute(builder: (context) => const AccountView()),
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
    var iMat = context.watch<ImatDataHandler>(); // Add this line to access iMat

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _weeklyOfferBanner(iMat), // Pass iMat to the method
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

  Widget _weeklyOfferBanner(ImatDataHandler iMat) { // Add ImatDataHandler parameter
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubcategoryView(
                      category: ProductCategory.UNDEFINED, // As "Erbjudanden" is UNDEFINED
                      headcategory: 'Erbjudanden',
                      subcategoryName: 'Visa alla',
                      products: iMat.products, // Pass all products as placeholder
                    ),
                  ),
                );
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
