import 'dart:ui'; // Added for BackdropFilter
import 'package:api_test/app_theme.dart';
import 'package:api_test/model/imat/order.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/model/imat/shopping_item.dart'; // Added for ShoppingItem
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:api_test/widgets/app_navigation_bar.dart';
import 'package:api_test/pages/account_view.dart'; // Added for sidebar navigation
import 'package:api_test/pages/favorites_view.dart'; // Added for sidebar navigation
import 'package:api_test/widgets/cart_view.dart'; // Added for cart overlay
import 'package:api_test/widgets/product_tile.dart'; // Import ProductTile
import 'package:api_test/main.dart'; // For navigatorKey if sidebar uses global navigation

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> with TickerProviderStateMixin {
  Order? _selectedOrder;
  late ScrollController _scrollController;
  bool _showSidebar = false;
  bool _showCartOverlay = false;
  late AnimationController _animationController;
  late Animation<Offset> _cartSlideAnimation;
  late Animation<Offset> _sidebarSlideAnimation;

  bool _isInkopslistorExpanded = false;
  bool _isOrdrarExpanded = true; // Ordrar open by default

  final Map<String, bool> _isHovering = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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
    final orders = iMat.orders;

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

    return Scaffold(
      backgroundColor: const Color(0xFFFDF0F5), // Match FavoritesView background
      body: Stack(
        children: [
          Column(
            children: [
              AppNavigationBar(
                showSearchBar: false,
                pageTitle: "Mina sidor", // Updated title
                onCartPressed: () {
                  setState(() => _showCartOverlay = true);
                  _animationController.forward();
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
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: const Text('Inga sparade inköpslistor här ännu.'), // Placeholder
                        ),
                      ],
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
              top: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _sidebarSlideAnimation,
                child: _sidebar(iMat), 
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
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
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
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3E2A5E),
                fontSize: 20.0)),
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
                'Order ${order.orderNumber}',
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

  Widget _cartOverlay() {
    return Container(
      width: 320.0,
      color: const Color(0xffd2ebd8),
      padding: const EdgeInsets.only(top: 40.0, left:16.0, right: 16.0, bottom: 16.0),
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
          const Text('Kundvagn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          const SizedBox(height: 12.0),
          const Expanded(child: CartView()),
          const SizedBox(height: 12.0),
          ElevatedButton(
            onPressed: () {
              setState(() => _showCartOverlay = false);
              _animationController.reverse().then((_) {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Till kassan (ej implementerat härifrån än)')),
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3E2A5E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Till kassan', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
