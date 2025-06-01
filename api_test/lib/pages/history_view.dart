import 'dart:ui'; // Added for BackdropFilter
import 'package:api_test/app_theme.dart';
import 'package:api_test/model/imat/order.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/model/imat/shopping_item.dart'; // Added for ShoppingItem
import 'package:api_test/model/imat/shopping_list.dart'; // Added for ShoppingList
import 'package:api_test/model/imat/product.dart'; // Added import for Product
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:api_test/widgets/app_navigation_bar.dart';
import 'package:api_test/pages/account_view.dart'; // Added for sidebar navigation
import 'package:api_test/pages/favorites_view.dart'; // Added for sidebar navigation
import 'package:api_test/pages/main_view.dart'; // Added for navigation to main view
import 'package:api_test/widgets/product_tile.dart'; // Import ProductTile
import 'package:api_test/main.dart'; // For navigatorKey if sidebar uses global navigation
import 'package:api_test/widgets/cart_overlay_provider.dart'; // ADDED: For global cart access

class HistoryView extends StatefulWidget {
  final bool expandOrders; // Add this parameter
  const HistoryView({super.key, this.expandOrders = false}); // Modify constructor

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> with TickerProviderStateMixin {
  Order? _selectedOrder;
  ShoppingList? _selectedShoppingList; // Added to manage expanded shopping list
  late ScrollController _scrollController;
  bool _showSidebar = false;
  // bool _showCartOverlay = false; // REMOVE: No longer needed
  bool _isInkopslistorExpanded = false; 
  bool _isOrdrarExpanded = false; // Default to false

  // Animation Controllers and Tweens
  late AnimationController _animationController;
  // late Animation<Offset> _cartSlideAnimation; // REMOVE: No longer needed
  late Animation<Offset> _sidebarSlideAnimation;

  // State for product search within an expanded shopping list
  String _shoppingListSearchQuery = '';
  List<Product> _shoppingListSearchResults = [];
  TextEditingController _shoppingListSearchController = TextEditingController();

  final Map<String, bool> _isHovering = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // _cartSlideAnimation = Tween<Offset>( // REMOVE: No longer needed
    //   begin: const Offset(1.0, 0.0),
    //   end: Offset.zero,
    // ).animate(CurvedAnimation(
    //   parent: _animationController,
    //   curve: Curves.easeInOut,
    // ));
    _sidebarSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Set _isOrdrarExpanded based on the widget parameter
    _isOrdrarExpanded = widget.expandOrders;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    final formatter = DateFormat('yyyy-MM-dd, HH:mm');
    return formatter.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final iMat = Provider.of<ImatDataHandler>(context);
    final cartProvider = Provider.of<CartOverlayProvider>(context, listen: false); // ADDED
    final orders = iMat.orders;
    final shoppingLists = iMat.shoppingLists; // Get all shopping lists

    List<Widget> ordrarExpansionTileChildren;
    if (orders.isEmpty) {
      ordrarExpansionTileChildren = [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text('Inga tidigare ordrar.'),
        ),
      ];
    } else {
      ordrarExpansionTileChildren = [_buildOrdersList(context, orders)];
    }

    List<Widget> inkopslistorExpansionTileChildren;
    if (shoppingLists.isEmpty) {
      inkopslistorExpansionTileChildren = [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              const Text('Inga sparade inköpslistor här ännu.'),
              const SizedBox(height: AppTheme.paddingMedium),
              ElevatedButton.icon( // MODIFIED: Changed to ElevatedButton.icon
                icon: const Icon(Icons.add, size: 18), // ADDED: Icon
                label: const Text('Ny inköpslista'), // MODIFIED: Changed child to label
                style: AppTheme.primaryButtonStyle,
                onPressed: () {
                  _showCreateShoppingListDialog(context, iMat);
                },
              ),
            ],
          ),
        ),
      ];
    } else {
      // Display all shopping lists directly
      inkopslistorExpansionTileChildren = [_buildShoppingListsList(context, shoppingLists, iMat)];
      
      // Add the "Ny inköpslista" button at the bottom-left of the dropdown
      inkopslistorExpansionTileChildren.add(
        Padding(
          padding: const EdgeInsets.only(top: AppTheme.paddingMedium, left: AppTheme.paddingSmall, bottom: AppTheme.paddingSmall),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ny inköpslista'),
              style: AppTheme.primaryButtonStyle.copyWith(
                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium, vertical: AppTheme.paddingSmall)),
                textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              onPressed: () {
                _showCreateShoppingListDialog(context, iMat);
              },
            ),
          ),
        ),
      );
    }


    return Scaffold(
      backgroundColor: const Color(0xFFFDF0F5), // Match FavoritesView background
      body: Stack(
        children: [
          Column(
            children: [
              AppNavigationBar(
                showSearchBar: false,
                pageTitle: "Mina inköp", // Updated title
                onCartPressed: () {
                  // setState(() => _showCartOverlay = true); // REMOVE
                  // _animationController.forward(); // REMOVE
                  cartProvider.showCart(); // ADDED: Use global cart provider
                },
              ),
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
                      // MODIFIED: Navigate to MainView using global navigatorKey and clear stack
                      navigatorKey.currentState?.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const MainView()),
                        (Route<dynamic> route) => false,
                      );
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
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildExpansionTile(
                      context: context,
                      title: 'Inköpslistor',
                      isExpanded: _isInkopslistorExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _isInkopslistorExpanded = expanded;
                        });
                      },
                      children: inkopslistorExpansionTileChildren,
                      iMat: iMat,
                    ),
                    const SizedBox(height: 16.0),
                    _buildExpansionTile(
                      context: context,
                      title: 'Ordrar',
                      isExpanded: _isOrdrarExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _isOrdrarExpanded = expanded;
                        });
                      },
                      children: ordrarExpansionTileChildren,
                      iMat: iMat,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Overlay for Sidebar and Cart
          if (_showSidebar) // MODIFIED: Removed _showCartOverlay condition
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showSidebar = false;
                    // _showCartOverlay = false; // REMOVE
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
                child: _sidebar(iMat), 
              ),
            ),
          // if (_showCartOverlay) // REMOVE: Entire block for local cart overlay
          //   Positioned(
          //     top: 0,
          //     right: 0,
          //     bottom: 0,
          //     child: SlideTransition(
          //       position: _cartSlideAnimation,
          //       child: _cartOverlay(),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
    required ImatDataHandler iMat,
    EdgeInsetsGeometry? customChildrenPadding,
  }) {
    final EdgeInsetsGeometry effectiveChildrenPadding = customChildrenPadding ??
        const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 16.0, top: 0);

    _isHovering.putIfAbsent(title, () => false);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD2EBD8), // Match FavoritesView
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3E2A5E),
                    fontSize: 20.0)),
          ],
        ),
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpansionChanged,
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
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        childrenPadding: effectiveChildrenPadding,
        children: children,
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, List<Order> orders) {
    final iMat = Provider.of<ImatDataHandler>(context, listen: false);
    if (orders.isEmpty) {
      return const Center(child: Text('Inga ordrar att visa.'));
    }
    // Sort orders by date in descending order (newest first)
    orders.sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        // Listen to changes for isFavorite state
        final isFavorite = context.watch<ImatDataHandler>().isOrderFavorite(order);

        return ExpansionTile(
          title: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: isFavorite ? AppTheme.primaryPurple : Colors.white,
                  size: 32, // Changed from 24 to 32
                  shadows: isFavorite
                      ? null
                      : [
                          Shadow(color: AppTheme.primaryPurple, blurRadius: 0, offset: const Offset(1.0, 0)), // Adjusted offset for smaller icon
                          Shadow(color: AppTheme.primaryPurple, blurRadius: 0, offset: const Offset(-1.0, 0)),
                          Shadow(color: AppTheme.primaryPurple, blurRadius: 0, offset: const Offset(0, 1.0)),
                          Shadow(color: AppTheme.primaryPurple, blurRadius: 0, offset: const Offset(0, -1.0)),
                        ],
                ),
                tooltip: isFavorite ? 'Ta bort från favoriter' : 'Lägg till som favorit',
                onPressed: () {
                  iMat.toggleOrderFavorite(order);
                  // No need for setState here if context.watch is used for isFavorite
                },
              ),
              const SizedBox(width: 8), // Spacing between heart and order number
              Text(
                '#${order.orderNumber}', // Changed to display #OrderNumber
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _selectedOrder == order ? AppTheme.primaryPurple : AppTheme.textPrimary),
              ),
            ],
          ),
          initiallyExpanded: _selectedOrder == order,
          onExpansionChanged: (bool expanding) {
            setState(() {
              if (expanding) {
                _selectedOrder = order;
              } else {
                if (_selectedOrder == order) {
                  _selectedOrder = null;
                }
              }
            });
          },
          childrenPadding: EdgeInsets.zero, 
          tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: <Widget>[
            _buildOrderDetails(order),
          ],
        );
      },
    );
  }

  Widget _buildShoppingListsList(BuildContext context, List<ShoppingList> shoppingLists, ImatDataHandler iMat) { // Removed isFavoriteList parameter
    if (shoppingLists.isEmpty) {
      return Container(); // Should be handled by the main check in build method
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shoppingLists.length,
      itemBuilder: (context, index) {
        final list = shoppingLists[index];
        final isFavorite = iMat.isShoppingListFavorite(list); // Check if the list is a favorite

        return ExpansionTile(
          leading: IconButton( // Added IconButton for favorite toggle
            icon: Icon(
              Icons.favorite,
              color: isFavorite ? AppTheme.primaryPurple : Colors.white,
              size: 32,
              shadows: isFavorite
                  ? null
                  : [
                      Shadow(color: AppTheme.primaryPurple, blurRadius: 0, offset: const Offset(1.0, 0)),
                      Shadow(color: AppTheme.primaryPurple, blurRadius: 0, offset: const Offset(-1.0, 0)),
                      Shadow(color: AppTheme.primaryPurple, blurRadius: 0, offset: const Offset(0, 1.0)),
                      Shadow(color: AppTheme.primaryPurple, blurRadius: 0, offset: const Offset(0, -1.0)),
                    ],
            ),
            tooltip: isFavorite ? 'Ta bort från favoritlistor' : 'Lägg till som favoritlista',
            onPressed: () {
              iMat.toggleShoppingListFavorite(list);
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                list.title,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _selectedShoppingList == list ? AppTheme.primaryPurple : AppTheme.textPrimary),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit, size: 16, color: AppTheme.buttonText),
                    label: const Text('Byt namn', style: TextStyle(color: AppTheme.buttonText)),
                    style: AppTheme.primaryButtonStyle.copyWith(
                      padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: AppTheme.paddingSmall, vertical: AppTheme.paddingTiny)),
                      textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      backgroundColor: MaterialStateProperty.all(AppTheme.primaryPurple), // Ensure primary purple background
                    ),
                    onPressed: () {
                      _showRenameShoppingListDialog(context, iMat, list);
                    },
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete, size: 16, color: AppTheme.buttonText),
                    label: const Text('Ta bort', style: TextStyle(color: AppTheme.buttonText)),
                    style: AppTheme.primaryButtonStyle.copyWith(
                      backgroundColor: MaterialStateProperty.all(AppTheme.primaryPurple), // Changed from Colors.redAccent
                      padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: AppTheme.paddingSmall, vertical: AppTheme.paddingTiny)),
                      textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                    onPressed: () {
                      _showDeleteShoppingListConfirmationDialog(context, iMat, list);
                    },
                  ),
                ],
              )
            ],
          ),
          initiallyExpanded: _selectedShoppingList == list,
          onExpansionChanged: (bool expanding) {
            setState(() {
              if (expanding) {
                _selectedShoppingList = list;
              } else {
                if (_selectedShoppingList == list) {
                  _selectedShoppingList = null;
                }
              }
            });
          },
          childrenPadding: EdgeInsets.zero,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: <Widget>[
            _buildShoppingListDetails(list, iMat),
          ],
        );
      },
    );
  }

  Widget _buildShoppingListDetails(ShoppingList list, ImatDataHandler iMat) {
    const int crossAxisCount = 6;
    const double childAspectRatio = 0.8;
    const double spacing = 12.0;

    // Filter products for search if this list is selected and query is not empty
    if (_selectedShoppingList == list && _shoppingListSearchQuery.isNotEmpty) {
      // Ensure we are working with a copy of the list to prevent modification issues
      _shoppingListSearchResults = List.from(iMat.findProducts(_shoppingListSearchQuery));
    } else if (_selectedShoppingList != list || _shoppingListSearchQuery.isEmpty) {
      // Clear search results if this list is not selected or query is empty
      _shoppingListSearchResults = [];
    }


    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Search Bar
          if (_selectedShoppingList == list) // Show search only for the currently expanded list
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
              child: TextField(
                controller: _shoppingListSearchController,
                decoration: InputDecoration(
                  hintText: 'Sök produkt att lägga till...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _shoppingListSearchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _shoppingListSearchQuery = '';
                              _shoppingListSearchController.clear();
                              _shoppingListSearchResults = [];
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.paddingMediumSmall), // Used AppTheme.paddingMediumSmall as radius
                    borderSide: BorderSide(color: AppTheme.primaryPurple.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.paddingMediumSmall), // Used AppTheme.paddingMediumSmall as radius
                    borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
                  ),
                ),
                onChanged: (query) {
                  setState(() {
                    _shoppingListSearchQuery = query;
                    if (query.isEmpty) {
                      _shoppingListSearchResults = [];
                    } else {
                      // Perform search (already handled by the logic at the start of the build method)
                      // This ensures search results are updated as user types.
                    }
                  });
                },
              ),
            ),

          // Display Search Results (if any)
          if (_shoppingListSearchResults.isNotEmpty && _selectedShoppingList == list)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Sökresultat:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: AppTheme.paddingSmall),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount, // Changed from crossAxisCount - 1
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    childAspectRatio: childAspectRatio, // Changed from childAspectRatio + 0.2
                  ),
                  itemCount: _shoppingListSearchResults.length,
                  itemBuilder: (context, index) {
                    final product = _shoppingListSearchResults[index];
                    return ProductTile(
                      product,
                      shoppingListContext: true,
                      onAddToShoppingList: (product, quantity) {
                        iMat.addItemToShoppingList(list.id, ShoppingItem(product, amount: quantity.toDouble()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$quantity st ${product.name} lades till i "${list.title}".'),
                            backgroundColor: AppTheme.primaryPurple,
                          ),
                        );
                        // Optionally clear search or give other feedback
                        // setState(() {
                        //   _shoppingListSearchQuery = '';
                        //   _shoppingListSearchController.clear();
                        //   _shoppingListSearchResults = [];
                        // });
                      },
                    );
                  },
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                const Text("Varor i listan:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          
          // Existing items in the list
          if (list.items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppTheme.paddingSmall),
              child: Text('Denna inköpslista innehåller inga varor.'),
            )
          else
            GridView.builder(
              controller: ScrollController(keepScrollOffset: false),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: list.items.length,
              itemBuilder: (context, index) {
                final item = list.items[index];
                // Using ProductTile, assuming it can handle quantity display and removal from list
                return ProductTile(
                  item.product, 
                  historicAmount: item.amount.toInt(),
                  // Optional: Add callbacks for quantity change or removal if ProductTile supports it
                  // onQuantityChanged: (newQuantity) {
                  //   iMat.updateItemQuantityInShoppingList(list.id, item.product.productId, newQuantity.toDouble());
                  // },
                  // onRemove: () {
                  //   iMat.removeItemFromShoppingList(list.id, item.product.productId);
                  // },
                );
              },
            ),
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'Totalt: ${list.getTotal().toStringAsFixed(2)} kr',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: list.items.isNotEmpty ? () {
                  iMat.addShoppingListToCart(list.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Alla varor från "${list.title}" har lagts till i kundvagnen.',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppTheme.primaryPurple,
                    ),
                  );
                } : null, // Disable button if list is empty
                style: AppTheme.primaryButtonStyle.copyWith(
                  textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                child: const Text('Köp nu'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateShoppingListDialog(BuildContext context, ImatDataHandler iMat) {
    final TextEditingController titleController = TextEditingController();
    // Clear search when dialogs are shown, or when list selection changes
    _shoppingListSearchController.clear();
    _shoppingListSearchQuery = '';
    _shoppingListSearchResults = [];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.headerGreen, // Added background color
          title: const Text('Skapa ny inköpslista'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: "Namn på inköpslista"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Avbryt'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: AppTheme.primaryButtonStyle,
              child: const Text('Skapa'),
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  iMat.addShoppingList(ShoppingList(title: titleController.text));
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showRenameShoppingListDialog(BuildContext context, ImatDataHandler iMat, ShoppingList list) {
    final TextEditingController titleController = TextEditingController(text: list.title);
    // Clear search when dialogs are shown
    _shoppingListSearchController.clear();
    _shoppingListSearchQuery = '';
    _shoppingListSearchResults = [];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.headerGreen, // Added background color
          title: Text('Byt namn på "${list.title}"'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: "Nytt namn"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Avbryt'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: AppTheme.primaryButtonStyle,
              child: const Text('Spara'),
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  iMat.updateShoppingListTitle(list.id, titleController.text);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteShoppingListConfirmationDialog(BuildContext context, ImatDataHandler iMat, ShoppingList list) {
    // Clear search when dialogs are shown
    _shoppingListSearchController.clear();
    _shoppingListSearchQuery = '';
    _shoppingListSearchResults = [];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.headerGreen, // Set background to primary green
          title: Text('Ta bort "${list.title}"?'),
          content: const Text('Är du säker på att du vill ta bort denna inköpslista? Detta kan inte ångras.'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple, // Set button background to primary purple
                foregroundColor: Colors.white, // Assuming white text is desired for contrast
              ),
              child: const Text('Avbryt'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple, // Set button background to primary purple
                foregroundColor: Colors.white, // Assuming white text is desired for contrast
              ),
              child: const Text('Ta bort'),
              onPressed: () {
                // First, check if the list is a favorite
                final bool wasFavorite = iMat.isShoppingListFavorite(list);

                // Remove the shopping list
                iMat.removeShoppingList(list.id);

                // If it was a favorite, remove it from favorites as well
                if (wasFavorite) {
                  iMat.toggleShoppingListFavorite(list); // Toggling will remove it
                }

                // Check if the deleted list was the selected one and clear selection
                if (_selectedShoppingList?.id == list.id) {
                  setState(() {
                    _selectedShoppingList = null;
                  });
                }
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Inköpslistan "${list.title}" har tagits bort.'),
                    backgroundColor: AppTheme.primaryPurple,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }


  Widget _buildOrderDetails(Order order) {
    const int crossAxisCount = 6;
    const double childAspectRatio = 0.8;
    const double spacing = 12.0;
    final iMat = Provider.of<ImatDataHandler>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Datum: ${_formatDateTime(order.date)}', style: AppTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          if (order.items.isEmpty)
            const Text('Denna order innehåller inga varor.')
          else
            GridView.builder(
              controller: ScrollController(keepScrollOffset: false),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];
                return ProductTile(item.product, historicAmount: item.amount.toInt());
              },
            ),
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'Totalt: ${order.getTotal().toStringAsFixed(2)} kr',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: () {
                  for (final item in order.items) {
                    iMat.shoppingCartAdd(ShoppingItem(item.product, amount: item.amount));
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${order.items.length} ${order.items.length == 1 ? "vara" : "varor"} från order ${order.orderNumber} har lagts till i kundvagnen.',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppTheme.primaryPurple,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                child: const Text('Köp igen'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sidebar(ImatDataHandler iMat) {
    return Container(
      width: 280.0,
      color: const Color(0xffd2ebd8),
      padding: const EdgeInsets.only(top: 40.0, left:16.0, right: 16.0, bottom: 16.0),
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
          const Text("Mina sidor", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20.0),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text("Favoriter"),
            onTap: () {
              setState(() => _showSidebar = false);
              _animationController.reverse().then((_) {
                if (navigatorKey.currentState?.canPop() ?? false) {
                }
                navigatorKey.currentState?.pushReplacement(MaterialPageRoute(builder: (_) => const FavoritesView()));
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Tidigare inköp"),
            onTap: () {
              setState(() => _showSidebar = false);
              _animationController.reverse();
            },
            selected: true,
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
                navigatorKey.currentState?.pushReplacement(MaterialPageRoute(builder: (_) => const AccountView()));
              });
            },
            child: const Text('Logga in', style: TextStyle(color: Color(0xFFFCEEF4))),
          ),
        ],
      ),
    );
  }
}
