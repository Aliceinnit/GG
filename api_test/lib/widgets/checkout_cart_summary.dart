import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/model/imat/shopping_item.dart';
import 'package:api_test/app_theme.dart';

class CheckoutCartSummary extends StatefulWidget {
  final VoidCallback? onNext;
  
  const CheckoutCartSummary({super.key, this.onNext});

  @override
  State<CheckoutCartSummary> createState() => _CheckoutCartSummaryState();
}

class _CheckoutCartSummaryState extends State<CheckoutCartSummary> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImatDataHandler>(
      builder: (context, iMat, child) {
        var items = iMat.getShoppingCart().items;
        
        if (items.isEmpty) {
          return _buildEmptyCart(context);
        }

        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Din kundvagn',
                              style: AppTheme.headingLarge.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '${items.length} ${items.length == 1 ? 'artikel' : 'artiklar'}',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: items.length,
                          separatorBuilder: (context, index) => Divider(
                            color: Colors.grey[100],
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            return _buildCartItem(items[index], iMat);
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: _buildCartTotal(iMat),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildContinueButton(items.isNotEmpty),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Din kundvagn är tom',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lägg till produkter från butiken för att fortsätta',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Tillbaka till butiken'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(ShoppingItem item, ImatDataHandler iMat) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [          // Product image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: iMat.getImageData(item.product) != null
                  ? iMat.getImage(item.product)
                  : Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.grey[400],
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.product.price.toStringAsFixed(2)} kr/${item.product.unit}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Quantity controls
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    if (item.amount > 1) {
                      iMat.shoppingCartUpdate(item, delta: -1);
                    } else {
                      iMat.shoppingCartRemove(item);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.remove,
                      size: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    item.amount.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    iMat.shoppingCartUpdate(item, delta: 1);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.add,
                      size: 18,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Item total
          Text(
            '${(item.product.price * item.amount).toStringAsFixed(2)} kr',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartTotal(ImatDataHandler iMat) {
    final total = iMat.shoppingCartTotal();
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Delsumma',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              '${total.toStringAsFixed(2)} kr',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Leverans',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              'Beräknas i nästa steg',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Totalt',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${total.toStringAsFixed(2)} kr',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContinueButton(bool isEnabled) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? widget.onNext : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryPurple,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[600],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Fortsätt till leverans',
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
