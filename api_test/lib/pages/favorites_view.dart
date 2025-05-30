import 'dart:ui'; // Added for BackdropFilter
import 'package:api_test/widgets/app_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/widgets/product_tile.dart';
import 'package:api_test/pages/account_view.dart'; // Added for sidebar navigation
import 'package:api_test/pages/history_view.dart'; // Added for sidebar navigation
import 'package:api_test/widgets/cart_view.dart'; // Added for cart overlay

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> with TickerProviderStateMixin { // Added TickerProviderStateMixin
  late ScrollController _scrollController;
  bool _showSidebar = false; // Added
  bool _showCartOverlay = false; // Added
  late AnimationController _animationController; // Added
  late Animation<Offset> _cartSlideAnimation; // Added
  late Animation<Offset> _sidebarSlideAnimation; // Added

  // State for expansion tiles
  bool _isVarorExpanded = true; // Varor open by default
  bool _isInkopslistorExpanded = false; // Inköpslistor closed by default
  bool _isOrdrarExpanded = false; // Ordrar closed by default

  // State for hover effects on "Visa/Stäng"
  Map<String, bool> _isHovering = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController( // Added initialization
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cartSlideAnimation = Tween<Offset>( // Added initialization
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _sidebarSlideAnimation = Tween<Offset>( // Added initialization
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose(); // Added dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iMat = Provider.of<ImatDataHandler>(context);
    final favoriteProducts = iMat.favorites; // Use live favorites list


    const int varorGridCrossAxisCount = 6;
    const double varorGridCrossAxisSpacing = 12.0;
    const double varorGridMainAxisSpacing = 12.0;
    const double varorGridChildAspectRatio = 0.8;
    // const int maxItemsInTwoRows = 2 * varorGridCrossAxisCount; // Replaced

    // New: Define how many rows to show when scrolling is active
    const double visibleRows = 1.5;
    // Calculate the threshold of items beyond which scrolling is enabled
    final int maxItemsToDisplayWithoutScroll = (visibleRows * varorGridCrossAxisCount).ceil();

    // New constants for Varor section layout
    const double varorPageHorizontalPadding = 16.0; // Existing page padding
    const double varorExpansionTileHorizontalChildPadding = 24.0; // Padding for Varor dropdown edge
    const double scrollbarThickness = 24.0; // Larger scrollbar
    const double scrollbarGap = 24.0; // Padding between tiles and scrollbar
    const double gridViewInternalPaddingRightForScrollbar = scrollbarThickness + scrollbarGap;

    List<Widget> varorExpansionTileChildren;

    if (favoriteProducts.isEmpty) {
      varorExpansionTileChildren = [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text('Inga favoritvaror här ännu.'),
        ),
      ];
    } else {
      if (favoriteProducts.length > maxItemsToDisplayWithoutScroll) { // Updated condition
        final screenWidth = MediaQuery.of(context).size.width;
        
        // Updated calculation for available width for Varor content
        final totalHorizontalPaddingForVarorContent = (varorPageHorizontalPadding * 2) + (varorExpansionTileHorizontalChildPadding * 2);
        final availableWidthForVarorContent = screenWidth - totalHorizontalPaddingForVarorContent;
        
        // Calculate item width based on available width and cross axis count
        final itemWidth = (availableWidthForVarorContent - (varorGridCrossAxisSpacing * (varorGridCrossAxisCount - 1)) - gridViewInternalPaddingRightForScrollbar) / varorGridCrossAxisCount;
        final itemHeight = itemWidth / varorGridChildAspectRatio;

        // Calculate the height for the configured number of visibleRows
        // final heightForTwoRows = (itemHeight * 2) + varorGridMainAxisSpacing; // Replaced
        final double numFullSpacings = (visibleRows.ceil() - 1).toDouble(); // Number of full mainAxisSpacings visible
        final calculatedHeightForVisibleRows = (itemHeight * visibleRows) + (varorGridMainAxisSpacing * numFullSpacings);


        varorExpansionTileChildren = [
          Padding(
            padding: const EdgeInsets.only(right: gridViewInternalPaddingRightForScrollbar), // Add padding for the scrollbar gap
            child: SizedBox(
              height: calculatedHeightForVisibleRows, // Use the new calculated height for 1.5 rows
              child: Scrollbar(
                thumbVisibility: true, 
                thickness: scrollbarThickness, // Use new thickness
                radius: const Radius.circular(10.0), // Keeping radius, or adjust if needed e.g. Radius.circular(12)
                child: ScrollConfiguration( 
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: GridView.builder(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: gridViewInternalPaddingRightForScrollbar), // Use new padding for scrollbar space
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
      backgroundColor: const Color(0xFFFDF0F5),
      body: Stack( // Changed Column to Stack to allow overlays
        children: [
          Column(
            children: [              AppNavigationBar( // Added AppNavigationBar back
                showSearchBar: false,
                pageTitle: "Favoriter",
                onCartPressed: () { // Added
                  setState(() => _showCartOverlay = true);
                  _animationController.forward();
                },
              ),
              // Back Button
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 4.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF3E2A5E)),
                    label: const Text(
                      'Tillbaka',
                      style: TextStyle(
                        color: Color(0xFF3E2A5E),
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
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
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(varorPageHorizontalPadding), // Use defined page padding
                  children: [
                    _buildExpansionTile(
                      context: context,
                      title: 'Varor',
                      isExpanded: _isVarorExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _isVarorExpanded = expanded;
                        });
                      },
                      customChildrenPadding: EdgeInsets.symmetric(horizontal: varorExpansionTileHorizontalChildPadding)
                          .copyWith(bottom: 16.0, top: 0.0), // Pass custom padding for Varor tile
                      children: varorExpansionTileChildren,
                    ),
                    const SizedBox(height: 16),
                    _buildExpansionTile(
                      context: context,
                      title: 'Inköpslistor',
                      isExpanded: _isInkopslistorExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _isInkopslistorExpanded = expanded;
                        });
                      },
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
                      isExpanded: _isOrdrarExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _isOrdrarExpanded = expanded;
                        });
                      },
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
          // Overlay for Sidebar and Cart (Added)
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
              top: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _sidebarSlideAnimation,
                child: _sidebar(iMat), // Pass iMat
              ),
            ),

          if (_showCartOverlay)
            Positioned(
              top: 0,
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
    required bool isExpanded, // Changed from isInitiallyExpanded
    required ValueChanged<bool> onExpansionChanged, // Added callback
    EdgeInsetsGeometry? customChildrenPadding, // New optional parameter
  }) {
    final EdgeInsetsGeometry effectiveChildrenPadding = customChildrenPadding ??
        const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 16.0, top: 0); // Default padding

    // Initialize hover state for the tile if not already present
    _isHovering.putIfAbsent(title, () => false);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD2EBD8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        shape: const Border(), // Added to remove border when expanded
        collapsedShape: const Border(), // Added to remove border when collapsed
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3E2A5E),
                fontSize: 20.0)),
        initiallyExpanded: isExpanded, // Use the passed state
        onExpansionChanged: onExpansionChanged, // Use the passed callback
        trailing: MouseRegion(
          onEnter: (_) => setState(() => _isHovering[title] = true),
          onExit: (_) => setState(() => _isHovering[title] = false),
          child: Text(
            isExpanded ? 'Stäng' : 'Visa',
            style: TextStyle(
              color: const Color(0xFF3E2A5E),
              fontWeight: FontWeight.w600,
              fontSize: 16.0,
              decoration: _isHovering[title]!
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          ),
        ),
        // iconColor and collapsedIconColor are overridden by trailing
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        childrenPadding: effectiveChildrenPadding, // Use effective children padding
        children: children,
      ),
    );
  }

  // Added _sidebar method (adapted from previous versions)
  Widget _sidebar(ImatDataHandler iMat) {
    return Container(
      width: 280,
      color: const Color(0xffd2ebd8),
      padding: const EdgeInsets.only(top: 40, left:16, right: 16, bottom: 16),
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
              // Already on favorites page
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
              backgroundColor: const Color(0xFF3A2C4B), // AppTheme.primaryPurple
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
               setState(() => _showSidebar = false);
              _animationController.reverse().then((_) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountView()));
              });
            },
            child: const Text('Logga in', style: TextStyle(color: Color(0xFFFCEEF4))), // AppTheme.buttonText
          ),
        ],
      ),
    );
  }

  // Added _cartOverlay method (adapted from previous versions)
  Widget _cartOverlay() {
    return Container(
      width: 320,
      color: const Color(0xffd2ebd8),
      padding: const EdgeInsets.only(top: 40, left:16, right: 16, bottom: 16),
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
          const Text('Kundvagn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), // Added fontSize
          const SizedBox(height: 12),
          const Expanded(child: CartView()),
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
              backgroundColor: const Color(0xFF3E2A5E), // AppTheme.primaryPurple
              foregroundColor: Colors.white, // AppTheme.buttonText
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Till kassan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
