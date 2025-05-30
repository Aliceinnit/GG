import 'dart:ui'; // Added for BackdropFilter
import 'package:api_test/widgets/app_navigation_bar.dart'; // Added
import 'package:api_test/widgets/cart_view.dart'; // Added
import 'package:api_test/pages/account_view.dart'; // Added
import 'package:api_test/pages/history_view.dart'; // Added
import 'package:api_test/model/imat/product.dart'; // Added
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/widgets/product_tile.dart';

// Changed to StatefulWidget
class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> with TickerProviderStateMixin { // Added with TickerProviderStateMixin
  bool _showSidebar = false;
  bool _showCartOverlay = false;
  late AnimationController _animationController;
  late Animation<Offset> _cartSlideAnimation;
  late Animation<Offset> _sidebarSlideAnimation;
  late List<Product> _displayedFavoriteProducts; // For search filtering

  @override
  void initState() {
    super.initState();
    final iMat = Provider.of<ImatDataHandler>(context, listen: false);
    _displayedFavoriteProducts = List.from(iMat.favorites); // Initialize with all favorites

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
    final iMat = Provider.of<ImatDataHandler>(context);
    // Use _displayedFavoriteProducts for rendering, which is updated by search
    // final favoriteProducts = iMat.favorites; // Original line
    final favoriteProducts = _displayedFavoriteProducts;


    const int varorGridCrossAxisCount = 6;
    const double varorGridCrossAxisSpacing = 12.0;
    const double varorGridMainAxisSpacing = 12.0;
    const double varorGridChildAspectRatio = 0.8;
    const int maxItemsInTwoRows = 2 * varorGridCrossAxisCount;

    List<Widget> varorExpansionTileChildren;

    if (favoriteProducts.isEmpty) {
      varorExpansionTileChildren = [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text('Inga favoritvaror här ännu.', textAlign: TextAlign.center),
        )
      ];
    } else {
      if (favoriteProducts.length > maxItemsInTwoRows) {
        final screenWidth = MediaQuery.of(context).size.width;
        // Padding for overall ListView (body): 16 left, 16 right
        // Padding for ExpansionTile children: 16 left, 16 right
        final totalHorizontalPaddingOutsideGridArea = (16.0 * 2) + (16.0 * 2);
        final widthAvailableForScrollbarAndGrid = screenWidth - totalHorizontalPaddingOutsideGridArea;

        // Define space for the scrollbar to the right of the grid items
        const double scrollbarThickness = 20.0;
        const double scrollbarGap = 20.0; // Increased gap from 12.0 to 20.0
        const double gridViewInternalPaddingRight = scrollbarThickness + scrollbarGap; // Will now be 40.0

        // Width available for the actual grid cells (tiles)
        final widthForGridCells = widthAvailableForScrollbarAndGrid - gridViewInternalPaddingRight;
        
        final tileWidth = (widthForGridCells - (varorGridCrossAxisCount - 1) * varorGridCrossAxisSpacing) / varorGridCrossAxisCount;
        final tileHeight = tileWidth / varorGridChildAspectRatio;
        final calculatedTwoRowsHeight = (2 * tileHeight) + varorGridMainAxisSpacing;
        
        final constrainedHeight = (calculatedTwoRowsHeight > 50.0 && tileWidth > 0) ? calculatedTwoRowsHeight : 250.0;

        varorExpansionTileChildren = [
          SizedBox(
            height: constrainedHeight,
            child: Scrollbar(
              thumbVisibility: true, // Ensure the custom scrollbar's thumb is always visible
              thickness: scrollbarThickness,
              radius: const Radius.circular(10.0),
              child: ScrollConfiguration( // Added to hide GridView's default scrollbar
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: GridView.builder(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: gridViewInternalPaddingRight),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: varorGridCrossAxisCount,
                    crossAxisSpacing: varorGridCrossAxisSpacing,
                    mainAxisSpacing: varorGridMainAxisSpacing,
                    childAspectRatio: varorGridChildAspectRatio,
                  ),
                  itemCount: favoriteProducts.length,
                  itemBuilder: (context, index) {
                    final product = favoriteProducts[index];
                    return ProductTile(product);
                  },
                ),
              ),
            ),
          ),
        ];
      } else {
        varorExpansionTileChildren = [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: varorGridCrossAxisCount,
              crossAxisSpacing: varorGridCrossAxisSpacing,
              mainAxisSpacing: varorGridMainAxisSpacing,
              childAspectRatio: varorGridChildAspectRatio,
            ),
            itemCount: favoriteProducts.length,
            itemBuilder: (context, index) {
              final product = favoriteProducts[index];
              return ProductTile(product);
            },
          ),
        ];
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF0F5), // Light pink background
      // appBar: AppBar(...), // Removed AppBar
      body: Stack( // Added Stack for overlays
        children: [
          Column( // Main content column
            children: [
              AppNavigationBar(
                // onSearch: _filterFavoriteProducts, // Removed onSearch as search bar is hidden
                showSearchBar: false, 
                pageTitle: "Favoriter", // Add the title
                onCartPressed: () {
                  setState(() => _showCartOverlay = true);
                  _animationController.forward();
                },
                onAccountPressed: () {
                  setState(() => _showSidebar = true);
                  _animationController.forward();
                },
              ),
              // Added Back Button here
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 4.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF3E2A5E) /*AppTheme.primaryPurple*/),
                    label: const Text(
                      'Tillbaka',
                      style: TextStyle(color: Color(0xFF3E2A5E) /*AppTheme.primaryPurple*/, fontSize: 20.0, fontWeight: FontWeight.w600), // Changed fontSize from 16 to 20.0
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded( // Make the ListView scrollable if content overflows
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildExpansionTile(
                      context: context,
                      title: 'Varor',
                      isInitiallyExpanded: true,
                      children: varorExpansionTileChildren,
                    ),
                    const SizedBox(height: 16),
                    _buildExpansionTile(
                      context: context,
                      title: 'Inköpslistor',
                      isInitiallyExpanded: true,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: const Text('Inga favoritinköpslistor här ännu.'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildExpansionTile(
                      context: context,
                      title: 'Ordrar',
                      isInitiallyExpanded: true,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: const Text('Inga favoritordrar här ännu.'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Overlay for Sidebar and Cart
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
              top: 0, // Adjusted to be from top of screen
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _sidebarSlideAnimation,
                child: _sidebar(iMat), // Pass iMat
              ),
            ),

          if (_showCartOverlay)
            Positioned(
              top: 0, // Adjusted to be from top of screen
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _cartSlideAnimation,
                child: _cartOverlay(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    bool isInitiallyExpanded = false,
  }) {
    // Access AppTheme properties through context if needed, or ensure AppTheme is imported and accessible.
    // For this example, assuming AppTheme is directly accessible.
    // final appTheme = Provider.of<AppTheme>(context); // Example if AppTheme was a provider

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD2EBD8), // Light green background
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Text(title,
            style: TextStyle( // Apply styles similar to AppTheme.headingMedium
                fontWeight: FontWeight.w600, // from AppTheme.headingMedium
                color: const Color(0xFF3E2A5E), // AppTheme.primaryPurple
                fontSize: 20.0)), // from AppTheme.headingMedium
        initiallyExpanded: isInitiallyExpanded,
        iconColor: const Color(0xFF3E2A5E), // AppTheme.primaryPurple
        collapsedIconColor: const Color(0xFF3E2A5E), // AppTheme.primaryPurple
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 16.0, top:0),
        children: children,
      ),
    );
  }

  // Added _sidebar method (adapted from main_view.dart or subcategory_view.dart)
  Widget _sidebar(ImatDataHandler iMat) {
    return Container(
      width: 280, // Standard sidebar width
      color: const Color(0xffd2ebd8), // Sidebar background color
      padding: const EdgeInsets.only(top: 40, left:16, right: 16, bottom: 16), // Added top padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() => _showSidebar = false);
                _animationController.reverse();
              }
            ),
          ),
          const Text("Mina sidor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text("Favoriter"),
            onTap: () {
              // Already on favorites page, maybe close sidebar or do nothing
              setState(() => _showSidebar = false);
              _animationController.reverse();
            },
            selected: true, // Indicate current page
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Tidigare inköp"),
            onTap: () {
              setState(() => _showSidebar = false);
              _animationController.reverse().then((_) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryView()));
              });
            },
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3A2C4B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
               setState(() => _showSidebar = false);
              _animationController.reverse().then((_) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountView()));
              });
            },
            child: const Text('Logga in', style: TextStyle(color: Color(0xFFFCEEF4))),
          ),
        ],
      ),
    );
  }

  // Added _cartOverlay method (adapted from main_view.dart or subcategory_view.dart)
  Widget _cartOverlay() {
    return Container(
      width: 320, // Standard cart overlay width
      color: const Color(0xffd2ebd8), // Cart overlay background color
      padding: const EdgeInsets.only(top: 40, left:16, right: 16, bottom: 16), // Added top padding
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
          const Expanded(child: CartView()), // Assuming CartView is self-contained
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // Navigate to checkout
              setState(() => _showCartOverlay = false);
              _animationController.reverse().then((_) {
                // TODO: Implement navigation to CheckoutFlow if needed from here
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutFlow()));
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Till kassan (ej implementerat härifrån än)')),
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 50), // Make button full width
            ),
            child: const Text('Till kassan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
