import 'package:api_test/app_theme.dart';
import 'package:api_test/model/imat/product.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/pages/main_view.dart';
import 'package:api_test/pages/subcategory_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Breadcrumbs extends StatefulWidget {
  final ProductCategory selectedCategory;
  final String headcategory;
  final String subcategory;
  
  final Map<String, ProductCategory> headcategoryMap = {
    'Erbjudanden': ProductCategory.UNDEFINED,
    'Kött, fågel': ProductCategory.MEAT,
    'Frukt och grönt': ProductCategory.FRUIT,
    'Mejeri': ProductCategory.DAIRIES,
    'Bröd och kakor': ProductCategory.UNDEFINED,
    'Skafferi': ProductCategory.UNDEFINED,
    'Fryst': ProductCategory.UNDEFINED,
    'Fisk och skaldjur': ProductCategory.FISH,
    'Färdigmat': ProductCategory.UNDEFINED,
    'Vegetarisk': ProductCategory.UNDEFINED,
    'Godis, snacks': ProductCategory.SWEET,
    'Dryck': ProductCategory.UNDEFINED,
    'Blommor': ProductCategory.UNDEFINED,
    };

  Breadcrumbs({
    super.key,
    required this.selectedCategory,
    required this.headcategory,
    required this.subcategory,
  });

  @override
  State<Breadcrumbs> createState() => _BreadcrumbsState();
}

class _BreadcrumbsState extends State<Breadcrumbs> {
  bool _isHoveringStart = false;
  bool _isHoveringHead = false;

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          MouseRegion(
            onEnter: (_) => setState(() => _isHoveringStart = true),
            onExit: (_) => setState(() => _isHoveringStart = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainView()),
                  (route) => false,
                );
              },
              child: Text(
                "Start",
                style: AppTheme.headingMedium.copyWith(
                  color: _isHoveringStart ? const Color(0xFF3E2A5E) : const Color(0xFF3E2A5E),
                  decoration: _isHoveringStart ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ),
          ),
          const Icon(Icons.chevron_right, size: 24),
          MouseRegion(
            onEnter: (_) => setState(() => _isHoveringHead = true),
            onExit: (_) => setState(() => _isHoveringHead = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                final selectedCategory = widget.headcategoryMap[widget.headcategory];
                final products = iMat.findProductsByCategory(selectedCategory!);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubcategoryView(
                      category: widget.selectedCategory,
                      headcategory: widget.headcategory,
                      subcategoryName: 'Visa alla',
                      products: products,
                    ),
                  ),
                );
              },
              child: Text(
                widget.headcategory,
                style: AppTheme.headingMedium.copyWith(
                  color: _isHoveringHead ? const Color(0xFF3E2A5E) : const Color(0xFF3E2A5E),
                  decoration: _isHoveringHead ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ),
          ),
          if (widget.subcategory != 'Visa alla')
            const Icon(Icons.chevron_right, size: 24),
          if (widget.subcategory != 'Visa alla')
            Text(
              widget.subcategory,
              style: AppTheme.headingMedium,
            ),
        ],
      ),
    );
  }
}