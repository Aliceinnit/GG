import 'dart:ui';
import 'package:api_test/app_theme.dart';
import 'package:api_test/model/imat/product.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/pages/account_view.dart';
import 'package:api_test/pages/history_view.dart';
import 'package:api_test/widgets/app_navigation_bar.dart';
import 'package:api_test/widgets/breadcrumbs.dart';
import 'package:api_test/widgets/left_panel.dart';
import 'package:api_test/widgets/product_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubcategoryView extends StatefulWidget {
  final ProductCategory category;
  final String headcategory;
  final String subcategoryName;
  final List<Product> products;

  const SubcategoryView({
    super.key,
    required this.category,
    required this.headcategory,
    required this.subcategoryName,
    required this.products,
  });

  @override
  State<SubcategoryView> createState() => _SubcategoryViewState();
}

class _SubcategoryViewState extends State<SubcategoryView> with TickerProviderStateMixin {
  bool _showSidebar = false;
  late AnimationController _animationController;
  late Animation<Offset> _sidebarSlideAnimation;
  late List<Product> _displayedProducts;
  @override
  void initState() {
    super.initState();
    _displayedProducts = widget.products;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sidebarSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var iMat = context.watch<ImatDataHandler>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Column(
            children: [              AppNavigationBar(
                onSearch: (query) {
                  setState(() {
                    if (query.isNotEmpty) {
                    final results = iMat.findProducts(query);
                    _displayedProducts = results;
                  } else {
                    _displayedProducts = widget.products;
                  }
                  });
                },
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Om du vill återanvända samma vänstermeny
                    LeftPanel(), 
                    Expanded(child: _centerStage(context, _displayedProducts)),
                  ],
                ),
              ),          ],
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
            ),
          if (_showSidebar)
            Positioned(
              top: 64,
              right: 0,
              child: SlideTransition(
                position: _sidebarSlideAnimation,
                child: _sidebar(iMat),
              ),
            ),
        ],
      ),
    );
  }

  Widget _centerStage(BuildContext context, List<Product> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Breadcrumbs(selectedCategory: widget.category, headcategory: widget.headcategory, subcategory: widget.subcategoryName),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6, // Changed from 4 to 6
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
    );
  }

  Widget _sidebar(ImatDataHandler iMat) {
    return Container(
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryView()));
            },
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3A2C4B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountView())),
            child: const Text('Logga in', style: TextStyle(color: Color(0xFFFCEEF4))),
          ),        ],
      ),
    );
  }
}