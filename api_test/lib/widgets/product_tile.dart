import 'package:api_test/model/imat/product.dart';
import 'package:api_test/model/imat/product_detail.dart';
import 'package:api_test/model/imat/shopping_item.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/widgets/buy_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductTile extends StatelessWidget {
  const ProductTile(this.product, {super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    var iMat = Provider.of<ImatDataHandler>(context, listen: false);

    return Card(
      child: ListTile(
        leading: iMat.getImage(product),
        title: Text(product.name),
        subtitle: Text(
          '${product.price} ${product.unit} ${_brand(product, context)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _favoriteButton(product, context),
            SizedBox(width: 8),
            BuyButton(
              onPressed: () {
                iMat.shoppingCartAdd(ShoppingItem(product));
              },
            ),
          ],
        ),
      ),
    );
  }

  String _brand(Product product, context) {
    var iMat = Provider.of<ImatDataHandler>(context, listen: false);

    ProductDetail? detail = iMat.getDetail(product);

    if (detail != null) {
      return detail.brand;
    }
    return '';
  }

  Widget _favoriteButton(Product p, context) {
    var iMat = Provider.of<ImatDataHandler>(context, listen: false);
    var isFavorite = iMat.isFavorite(product);

    var icon =
        isFavorite
            ? Icon(Icons.star, color: Colors.orange)
            : Icon(Icons.star_border, color: Colors.orange);

    return IconButton(
      onPressed: () {
        iMat.toggleFavorite(product);
      },
      icon: icon,
    );
  }
}
