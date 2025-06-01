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
      'Ekologiskt': ProductCategory.UNDEFINED, // Assuming 'Ekologiskt' products are marked as UNDEFINED or handled by specific logic if it's a filter
      'Mjölk & grädde': ProductCategory.DAIRIES,
      'Yoghurt': ProductCategory.DAIRIES,
      'Ost': ProductCategory.DAIRIES,
      'Smör & margarin': ProductCategory.DAIRIES,
      'Ägg': ProductCategory.DAIRIES,
      'Matbröd': ProductCategory.BREAD,
      'Frallor': ProductCategory.BREAD,
      'Kakor': ProductCategory.SWEET,
      'Fikabröd': ProductCategory.SWEET,
      'Pasta & ris': ProductCategory.PASTA, // Corrected from PASTA_RICE if PASTA is the enum
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
      'Visa alla': ProductCategory.UNDEFINED, // This mapping is used if not 'Visa alla' case
    };

    // This map helps determine the 'category' for SubcategoryView when "Visa alla" is clicked.
    // It should align with how Breadcrumbs determine the ProductCategory for a head category.
    final Map<String, ProductCategory> headCategoryEnumMapForView = {
      'Erbjudanden': ProductCategory.UNDEFINED,
      'Kött, fågel': ProductCategory.MEAT,
      'Frukt och grönt': ProductCategory.FRUIT, // Representative enum
      'Mejeri': ProductCategory.DAIRIES,
      'Bröd och kakor': ProductCategory.BREAD, // Representative enum (e.g. BREAD or UNDEFINED as in breadcrumbs)
      'Skafferi': ProductCategory.FLOUR_SUGAR_SALT, // Representative enum
      'Fryst': ProductCategory.UNDEFINED, // Representative enum
      'Fisk och skaldjur': ProductCategory.FISH,
      'Färdigmat': ProductCategory.UNDEFINED, // Representative enum
      'Vegetarisk': ProductCategory.UNDEFINED, // Representative enum
      'Godis, snacks': ProductCategory.SWEET,
      'Dryck': ProductCategory.COLD_DRINKS, // Representative enum
      'Blommor': ProductCategory.UNDEFINED, // Representative enum
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
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories.entries.elementAt(index);
                return ExpansionTile(
                  shape: const Border(), // Added to remove border when expanded
                  collapsedShape: const Border(), // Added to remove border when collapsed
                  title: Text(category.key),
                  children: category.value.map((subcategoryNameString) {
                    return HoverListTile(
                      title: subcategoryNameString,
                      onTap: () {
                        final String headCategoryName = category.key;
                        List<Product> productsToView;
                        ProductCategory categoryForView;

                        if (subcategoryNameString == 'Visa alla') {
                          Set<Product> allProductsInHeadCategory = {};
                          List<String>? subcategoriesOfHead = categories[headCategoryName];
                          if (subcategoriesOfHead != null) {
                            for (String subNameInLoop in subcategoriesOfHead) {
                              if (subNameInLoop == 'Visa alla') continue;
                              ProductCategory? subEnum = subcategoryMap[subNameInLoop];
                              if (subEnum != null && subEnum != ProductCategory.UNDEFINED) {
                                allProductsInHeadCategory.addAll(iMat.findProductsByCategory(subEnum));
                              } else if (subEnum == ProductCategory.UNDEFINED) {
                                // If a specific subcategory is UNDEFINED (e.g. "Ekologiskt"),
                                // you might want to fetch all products and then filter them,
                                // or have a specific method in ImatDataHandler for these.
                                // For now, let's assume findProductsByCategory handles UNDEFINED by returning relevant items or empty.
                                // Or, if "Visa alla" for a head category that contains an "Ekologiskt" (UNDEFINED) subcategory
                                // should include *all* products of that headcategory regardless of their specific subcategory,
                                // then the logic needs to be more broad.
                                // The current approach: only adds products from *defined* subcategories.
                                // If 'Ekologiskt' should show all 'Frukt och grönt' that are organic, that's a more complex filter.
                                // For "Visa alla" at headcategory level, we are collecting from its children.
                              }
                            }
                          }
                          // If the head category itself is something like "Erbjudanden" (offers)
                          // which is mapped to UNDEFINED, and "Visa alla" is clicked,
                          // we might want to fetch all products that are on offer.
                          // This requires a different method in ImatDataHandler, e.g., iMat.getOfferProducts().
                          // The current logic for "Visa alla" aggregates products from its listed subcategories.
                          if (headCategoryEnumMapForView[headCategoryName] == ProductCategory.UNDEFINED && allProductsInHeadCategory.isEmpty) {
                            // Potentially fetch all products if it's a generic "Visa alla" for an undefined head category
                            // This is a placeholder for more specific logic if needed.
                            // For example, for "Erbjudanden" -> "Visa alla", you might want all products with a discount.
                            // productsToView = iMat.getAllProducts(); // Example, might not be what's desired.
                          }


                          productsToView = allProductsInHeadCategory.toList();
                          // For "Visa alla", the categoryForView should represent the head category
                          categoryForView = headCategoryEnumMapForView[headCategoryName] ?? ProductCategory.UNDEFINED;
                        } else {
                          ProductCategory? selectedSubEnum = subcategoryMap[subcategoryNameString];
                          if (selectedSubEnum != null) {
                            productsToView = iMat.findProductsByCategory(selectedSubEnum);
                            categoryForView = selectedSubEnum;
                          } else {
                            productsToView = []; // Fallback for safety
                            categoryForView = ProductCategory.UNDEFINED;
                          }
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubcategoryView(
                              category: categoryForView, // This is the ProductCategory enum
                              headcategory: headCategoryName, // This is the String name of the head category
                              subcategoryName: subcategoryNameString, // This is the String name of the subcategory (or "Visa alla")
                              products: productsToView,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(), // Added .toList() here
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}