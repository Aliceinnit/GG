import 'package:api_test/app_theme.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/pages/checkout_flow.dart';
import 'package:api_test/pages/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_test/main.dart';

class CartSidebar extends StatelessWidget {
  final VoidCallback onClose;
  final Animation<Offset> slideAnimation;

  const CartSidebar({
    super.key,
    required this.onClose,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 64,
      right: 0,
      child: SlideTransition(
        position: slideAnimation,
        child: Container(
          width: 350,
          height: MediaQuery.of(context).size.height - 64,
          decoration: BoxDecoration(
            color: AppTheme.headerGreen,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(-5, 0),
              ),
              BoxShadow(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(-10, 0),
              ),
            ],
            border: Border.all(
              color: AppTheme.primaryPurple.withOpacity(0.1),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kundvagn', style: AppTheme.headingMedium),
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // Cart items
              Expanded(child: _CartItemsList()),

              const SizedBox(height: AppTheme.paddingMedium),

              // Total and checkout
              _CartSummary(),

              const SizedBox(height: 12),

              // Checkout button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (navigatorKey.currentState == null) {
                      print('navigatorKey.currentState is NULL in CartSidebar');
                      return;
                    }

                    navigatorKey.currentState!.push(
                      MaterialPageRoute(builder: (context) => const CheckoutFlow()),
                    );

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      onClose();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Till kassan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItemsList extends StatefulWidget {
  @override
  State<_CartItemsList> createState() => _CartItemsListState();
}

class _CartItemsListState extends State<_CartItemsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var iMat = context.watch<ImatDataHandler>();
    var items = iMat.getShoppingCart().items;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            Text(
              'Din kundvagn är tom',
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _CartItem(item: item);
      },
    );
  }
}

class _CartItem extends StatelessWidget {
  final dynamic item; // ShoppingItem type

  const _CartItem({required this.item});

  @override
  Widget build(BuildContext context) {
    var iMat = context.read<ImatDataHandler>();
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.headerGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                width: 1,
              ),
            ),            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: iMat.getImage(item.product),
            ),
          ),
          
          const SizedBox(width: AppTheme.paddingMedium),
          
          // Product name and price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.product.price.toStringAsFixed(2)} ${item.product.unit}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryPurple,
                  ),
                ),
              ],
            ),
          ),
          
          // Quantity controls
          _buildQuantityControls(iMat, item, item.amount.toInt()),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(ImatDataHandler iMat, dynamic cartItem, int quantity) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (quantity > 1) {
                iMat.shoppingCartUpdate(cartItem, delta: -1);
              } else {
                iMat.shoppingCartRemove(cartItem);
              }
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Icon(
                Icons.remove,
                color: AppTheme.buttonText,
                size: 18,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 32,
            child: Center(
              child: Text(
                quantity.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              iMat.shoppingCartUpdate(cartItem, delta: 1);
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Icon(
                Icons.add,
                color: AppTheme.buttonText,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var iMat = context.watch<ImatDataHandler>();
    var cart = iMat.getShoppingCart();
    var total = iMat.shoppingCartTotal();

    return Column(
      children: [
        // Total - styled like a product tile
        Container(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          decoration: BoxDecoration(
            color: AppTheme.headerGreen,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 0),
              ),
            ],
            border: Border.all(
              color: AppTheme.primaryPurple.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Totalt:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${total.toStringAsFixed(2)} kr',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppTheme.paddingMedium),
      ],
    );
  }
}
