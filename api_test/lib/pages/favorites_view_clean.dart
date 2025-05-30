import 'package:api_test/widgets/app_navigation_bar.dart';
import 'package:api_test/model/imat/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/widgets/product_tile.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  late List<Product> _displayedFavoriteProducts;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final iMat = Provider.of<ImatDataHandler>(context, listen: false);
    _displayedFavoriteProducts = List.from(iMat.favorites);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iMat = Provider.of<ImatDataHandler>(context);
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
          child: Text('Inga favoritvaror här ännu.'),
        ),
      ];
    } else {
      if (favoriteProducts.length > maxItemsInTwoRows) {
        varorExpansionTileChildren = [
          SizedBox(
            height: 400,
            child: Scrollbar(
              controller: _scrollController,
              child: GridView.builder(
                controller: _scrollController,
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
      body: Column(
        children: [
          const AppNavigationBar(
            showSearchBar: false,
            pageTitle: "Favoriter",
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
    );
  }

  Widget _buildExpansionTile({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    bool isInitiallyExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD2EBD8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF3E2A5E),
            fontSize: 20.0,
          ),
        ),
        initiallyExpanded: isInitiallyExpanded,
        iconColor: const Color(0xFF3E2A5E),
        collapsedIconColor: const Color(0xFF3E2A5E),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 16.0, top: 0),
        children: children,
      ),
    );
  }
}
