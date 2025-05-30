import 'package:api_test/app_theme.dart';
import 'package:api_test/model/imat/product.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/pages/subcategory_view.dart';
import 'package:api_test/widgets/hover_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeftPanel extends StatelessWidget {
  const LeftPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();

    final Map<String, List<String>> categories = {
      'Erbjudanden': ['Visa alla', 'Rabattvaror', 'Veckans kampanj'],
      'Kött, fågel': ['Visa alla', 'Nötkött', 'Kyckling', 'Fläskkött', 'Pålägg', 'Korv', 'Chark'],
      'Frukt och grönt': ['Visa alla', 'Frukt', 'Bär', 'Grönsaker', 'Rotfrukter', 'Ekologiskt'],
      'Mejeri': ['Visa alla', 'Mjölk & grädde', 'Yoghurt', 'Ost', 'Smör & margarin', 'Ägg'],
      'Bröd och kakor': ['Visa alla', 'Matbröd', 'Frallor', 'Kakor', 'Fikabröd'],
      'Skafferi': ['Visa alla', 'Pasta & ris', 'Konserver', 'Kryddor', 'Bakprodukter'],
      'Fryst': ['Visa alla', 'Frysta grönsaker', 'Glass', 'Pizza', 'Bär', 'Färdigmat fryst'],
      'Fisk och skaldjur': ['Visa alla', 'Färsk fisk', 'Fryst fisk', 'Skaldjur', 'Inlagd fisk'],
      'Färdigmat': ['Visa alla', 'Sallader', 'Färdiga rätter', 'Soppor', 'Smörgåsar'],
      'Vegetarisk': ['Visa alla', 'Vegokött', 'Veganska produkter', 'Vegetariska rätter'],
      'Godis, snacks': ['Visa alla', 'Godis', 'Chips', 'Choklad', 'Nötter'],
      'Dryck': ['Visa alla', 'Läsk', 'Juice', 'Kaffe & te', 'Energidryck', 'Vatten'],
      'Blommor': ['Visa alla', 'Snittblommor', 'Krukväxter', 'Buketter'],
    };

    final Map<String, ProductCategory> subcategoryMap = {
      'Rabattvaror': ProductCategory.UNDEFINED,
      'Veckans kampanj': ProductCategory.UNDEFINED,
      'Nötkött': ProductCategory.MEAT,
      'Kyckling': ProductCategory.MEAT,
      'Fläskkött': ProductCategory.MEAT,
      'Pålägg': ProductCategory.MEAT,
      'Korv': ProductCategory.MEAT,
      'Chark': ProductCategory.MEAT,
      'Frukt': ProductCategory.FRUIT,
      'Bär': ProductCategory.BERRY,
      'Grönsaker': ProductCategory.VEGETABLE_FRUIT,
      'Rotfrukter': ProductCategory.ROOT_VEGETABLE,
      'Ekologiskt': ProductCategory.UNDEFINED,
      'Mjölk & grädde': ProductCategory.DAIRIES,
      'Yoghurt': ProductCategory.DAIRIES,
      'Ost': ProductCategory.DAIRIES,
      'Smör & margarin': ProductCategory.DAIRIES,
      'Ägg': ProductCategory.DAIRIES,
      'Matbröd': ProductCategory.BREAD,
      'Frallor': ProductCategory.BREAD,
      'Kakor': ProductCategory.SWEET,
      'Fikabröd': ProductCategory.SWEET,
      'Pasta & ris': ProductCategory.PASTA,
      'Konserver': ProductCategory.UNDEFINED,
      'Kryddor': ProductCategory.HERB,
      'Bakprodukter': ProductCategory.FLOUR_SUGAR_SALT,
      'Frysta grönsaker': ProductCategory.VEGETABLE_FRUIT,
      'Glass': ProductCategory.SWEET,
      'Pizza': ProductCategory.UNDEFINED,
      'Färdigmat fryst': ProductCategory.UNDEFINED,
      'Färsk fisk': ProductCategory.FISH,
      'Fryst fisk': ProductCategory.FISH,
      'Skaldjur': ProductCategory.FISH,
      'Inlagd fisk': ProductCategory.FISH,
      'Sallader': ProductCategory.UNDEFINED,
      'Färdiga rätter': ProductCategory.UNDEFINED,
      'Soppor': ProductCategory.UNDEFINED,
      'Smörgåsar': ProductCategory.UNDEFINED,
      'Vegokött': ProductCategory.UNDEFINED,
      'Veganska produkter': ProductCategory.UNDEFINED,
      'Vegetariska rätter': ProductCategory.UNDEFINED,
      'Godis': ProductCategory.SWEET,
      'Chips': ProductCategory.SWEET,
      'Choklad': ProductCategory.SWEET,
      'Nötter': ProductCategory.NUTS_AND_SEEDS,
      'Läsk': ProductCategory.COLD_DRINKS,
      'Juice': ProductCategory.COLD_DRINKS,
      'Kaffe & te': ProductCategory.HOT_DRINKS,
      'Energidryck': ProductCategory.COLD_DRINKS,
      'Vatten': ProductCategory.COLD_DRINKS,
      'Snittblommor': ProductCategory.UNDEFINED,
      'Krukväxter': ProductCategory.UNDEFINED,
      'Buketter': ProductCategory.UNDEFINED,
      'Visa alla': ProductCategory.UNDEFINED,
    };

    return Container(
      width: 220,
      color: const Color(0xfffae8ed),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kategorier', style: AppTheme.headingMedium),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: categories.entries.map((entry) {
                final categoryName = entry.key;
                final subcategories = entry.value;

                return ExpansionTile(
                  title: Text(categoryName),
                  children: subcategories.map((subcategory) {
                    return HoverListTile(
                      title: subcategory,
                      onTap: () {
                        final selectedCategory = subcategoryMap[subcategory];
                        if (selectedCategory != null) {
                          final products = iMat.findProductsByCategory(selectedCategory);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubcategoryView(
                                category: selectedCategory,
                                headcategory: categoryName,
                                subcategoryName: subcategory,
                                products: products,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}