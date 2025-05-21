import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/widgets/delete_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    // Använder watch eftersom denna vyn behöver uppdateras
    // om ett item tas bort ur kundvagnen
    var iMat = context.watch<ImatDataHandler>();
    var items = iMat.getShoppingCart().items;

    return ListView(
      children: [
        for (final item in items)
          Card(
            child: ListTile(
              title: Text(item.product.name),
              subtitle: Text('${item.amount}'),
              trailing: DeleteButton(
                onPressed: () {
                  // Remove this item and triggers update of the UI.
                  // Also updates to the server.
                  // Don't remove the item from the list since
                  // That will not trigger rebuild of the UI
                  // and not update the shoppingcart on the server
                  iMat.shoppingCartRemove(item);
                },
              ),
            ),
          ),
      ],
    );
  }
}
