import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_test/app_theme.dart';
import 'package:api_test/model/imat/product.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/pages/account_view.dart';
import 'package:api_test/pages/history_view.dart';
import 'package:api_test/widgets/cart_view.dart';
import 'package:api_test/widgets/product_tile.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    var iMat = context.watch<ImatDataHandler>();
    var products = iMat.selectProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFFCEEF4), // Ljus bakgrund
      body: Column(
        children: [
          const SizedBox(height: AppTheme.paddingLarge),
          _header(context, iMat),
          const SizedBox(height: AppTheme.paddingMedium),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _leftPanel(iMat),
                Expanded(child: _centerStage(context, products)),
                _shoppingCart(iMat),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, ImatDataHandler iMat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // iMat-logotyp
          const Text(
            "iMat",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),

          // Sökfält
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Sök varor",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Ikoner till höger
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.list),
                tooltip: 'Mina inköp',
                onPressed: () => _showHistory(context),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border),
                tooltip: 'Favoriter',
                onPressed: () => iMat.selectFavorites(),
              ),
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                tooltip: 'Varukorg',
                onPressed: () {}, // valfri
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                tooltip: 'Logga in',
                onPressed: () => _showAccount(context),
              ),
            ],
          ),
        ],
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
      color: Colors.white,
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
                  onTap: () {
                    // Koppla till din kategori-filter
                    // Ex: iMat.selectSelection(iMat.findProductsByCategory(...));
                  },
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
        crossAxisCount: 4, // 4 kolumner per rad
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

  Widget _shoppingCart(ImatDataHandler iMat) {
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
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              iMat.placeOrder();
            },
            child: const Text('Köp!'),
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
}
