import 'package:api_test/model/imat/product.dart';
import 'package:api_test/model/imat/shopping_item.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/app_theme.dart';
import 'package:api_test/pages/login_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _AnimatedProductTileButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final BorderRadiusGeometry borderRadius;
  final String? tooltip;

  const _AnimatedProductTileButton({
    required this.icon,
    required this.onPressed,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.tooltip,
  });

  @override
  _AnimatedProductTileButtonState createState() => _AnimatedProductTileButtonState();
}

class _AnimatedProductTileButtonState extends State<_AnimatedProductTileButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _isPressed ? 1.2 : (_isHovered ? 1.05 : 1.0);
    final Color bgColor = _isHovered ? AppTheme.primaryPurple.withOpacity(0.85) : AppTheme.primaryPurple;

    Widget buttonContent = Transform.scale(
      scale: scale,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: widget.borderRadius,
          boxShadow: _isHovered || _isPressed ? [
            BoxShadow(
              color: AppTheme.primaryPurple.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 1,
            )
          ] : [],
        ),
        child: Icon(
          widget.icon,
          color: AppTheme.buttonText,
          size: 22,
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: widget.tooltip != null
            ? Tooltip(message: widget.tooltip!, child: buttonContent)
            : buttonContent,
      ),
    );
  }
}

class ProductTile extends StatefulWidget {
  const ProductTile(
    this.product, {
    super.key,
    this.historicAmount,
    this.shoppingListContext = false,
    this.initialQuantityForShoppingList = 1,
    this.onAddToShoppingList,
  });

  final Product product;
  final int? historicAmount;
  final bool shoppingListContext;
  final int initialQuantityForShoppingList;
  final Function(Product product, int quantity)? onAddToShoppingList;

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _hoverController;
  late AnimationController _borderController;
  late Animation<double> _flipAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _borderColorAnimation;
  bool _isFlipped = false;
  bool _isHovered = false;
  bool _isHeartHovered = false;
  int _shoppingListQuantity = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _borderController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.015,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 8.0,
      end: 20.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _borderColorAnimation = ColorTween(
      begin: AppTheme.primaryPurple.withOpacity(0.1),
      end: AppTheme.primaryPurple.withOpacity(0.4),
    ).animate(CurvedAnimation(
      parent: _borderController,
      curve: Curves.easeInOut,
    ));

    _startBorderAnimation();

    if (widget.shoppingListContext) {
      _shoppingListQuantity = widget.initialQuantityForShoppingList;
    }
  }

  void _startBorderAnimation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isHovered && !_isFlipped) {
        _borderController.forward().then((_) {
          if (mounted) {
            _borderController.reverse().then((_) {
              if (mounted) {
                _startBorderAnimation();
              }
            });
          }
        });
      } else {
        _startBorderAnimation();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _hoverController.dispose();
    _borderController.dispose();
    super.dispose();
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
    if (_isFlipped) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _onHoverEnter() {
    setState(() {
      _isHovered = true;
    });
    _hoverController.forward();
    _borderController.stop();
  }

  void _onHoverExit() {
    setState(() {
      _isHovered = false;
    });
    _hoverController.reverse();
    _startBorderAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImatDataHandler>(
      builder: (context, iMat, child) {
        final cartItems = iMat.getShoppingCart().items;
        final cartItem = cartItems
            .where((item) => item.product.productId == widget.product.productId)
            .firstOrNull;
        final quantity = cartItem?.amount.toInt() ?? 0;
        final isInCart = quantity > 0;

        return MouseRegion(
          onEnter: (_) => _onHoverEnter(),
          onExit: (_) => _onHoverExit(),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _flipCard,
            child: AnimatedBuilder(
              animation: Listenable.merge(
                  [_flipAnimation, _scaleAnimation, _borderColorAnimation]),
              builder: (context, child) {
                final isShowingFront = _flipAnimation.value < 0.5;
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_flipAnimation.value * 3.14159),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.headerGreen,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(_isHovered ? 0.2 : 0.08),
                            blurRadius: _elevationAnimation.value,
                            offset: Offset(0, _isHovered ? 6 : 2),
                          ),
                          if (_isHovered)
                            BoxShadow(
                              color: AppTheme.primaryPurple.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 0),
                            ),
                        ],
                        border: _isHovered
                            ? Border.all(
                                color: AppTheme.primaryPurple.withOpacity(0.5),
                                width: 3,
                              )
                            : Border.all(
                                color: _borderColorAnimation.value ??
                                    AppTheme.primaryPurple.withOpacity(0.1),
                                width: 1,
                              ),
                      ),
                      child: Stack(
                        children: [
                          isShowingFront
                              ? _buildFrontCard(
                                  iMat, isInCart, cartItem, quantity)
                              : Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..rotateY(3.14159),
                                  child: _buildBackCard(iMat),
                                ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFrontCard(
      ImatDataHandler iMat, bool isInCart, ShoppingItem? cartItem, int quantity) {
    final isFavorite = iMat.isFavorite(widget.product);

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: iMat.getImage(widget.product) ??
                            Container(
                              color: Colors.grey[100],
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.paddingMedium,
                  0,
                  AppTheme.paddingMedium,
                  AppTheme.paddingMedium,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column( // Wrap existing Text in a Column
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontSize: 20, // Increased from 16
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4), // Add some space
                          GestureDetector( // Make the new info section tappable
                            onTap: _flipCard,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 18, // Increased from 14
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Tryck för detaljer", // Changed text here
                                  style: TextStyle(
                                    fontSize: 16, // Increased from 12
                                    color: AppTheme.textSecondary,
                                    // decoration: TextDecoration.underline, // Optional: if you want underline
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.product.price.toStringAsFixed(2)} ${widget.product.unit}',
                          style: const TextStyle(
                            fontSize: 20, // Increased from 16
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                        // Conditional display based on context
                        if (widget.shoppingListContext)
                          _buildShoppingListQuantityControls(iMat) // New method for shopping list context
                        else if (widget.historicAmount != null)
                          _buildHistoricAmountDisplay() // Call to helper method
                        else if (!isInCart)
                          _buildAddButton(iMat)
                        else
                          _buildQuantityControls(iMat, cartItem!, quantity),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Favorite Icon with Tooltip and Hover Effect
        Positioned(
          top: 8,
          left: 8,
          child: Tooltip(
            message: isFavorite ? "Ta bort från favoriter" : "Lägg till i favoriter",
            preferBelow: false,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHeartHovered = true),
              onExit: (_) => setState(() => _isHeartHovered = false),
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  // Check if user is logged in before allowing to add to favorites
                  if (!iMat.isLoggedIn) {
                    // Show popup dialog instead of direct redirection
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: const Color(0xFFD2EBD8), // Set dialog background to green
                          title: const Text('Logga in krävs'),
                          content: const Text('Du behöver logga in för att kunna spara favoriter.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                              },
                              child: const Text('Avbryt'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryPurple, // Set button color to primary purple
                                foregroundColor: Colors.white, // Set text color to white
                              ),
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginView(redirectTo: '/favorites'),
                                  ),
                                );
                              },
                              child: const Text('Logga in'),
                            ),
                          ],
                        );
                      },
                    );
                    return;
                  }
                  
                  bool itemWasFavorite = isFavorite;
                  iMat.toggleFavorite(widget.product);
                  if (mounted) {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    if (!itemWasFavorite) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${widget.product.name} har lagts till i favoriter.'),
                          backgroundColor: AppTheme.primaryPurple,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${widget.product.name} har tagits bort från favoriter.'),
                          backgroundColor: AppTheme.error,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: _isHeartHovered // MODIFIED: Apply grey background if hovered, regardless of favorite status
                        ? Colors.grey.withOpacity(0.2)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: isFavorite
                        ? AppTheme.primaryPurple
                        : (_isHeartHovered
                            ? Colors.grey[700]
                            : Colors.white),
                    size: 32,
                    shadows: isFavorite
                        ? [
                            Shadow(color: Colors.black.withOpacity(0.25), blurRadius: 2, offset: Offset(0, 1)),
                          ]
                        : (_isHeartHovered
                            ? [
                                Shadow(color: Colors.black.withOpacity(0.25), blurRadius: 2, offset: Offset(0, 1)),
                              ]
                            : [
                                Shadow(color: AppTheme.primaryPurple, blurRadius: 0, offset: Offset(1, 0)),
                                Shadow(color: AppTheme.primaryPurple, blurRadius: 0, offset: Offset(-1, 0)),
                                Shadow(color: AppTheme.primaryPurple, blurRadius: 0, offset: Offset(0, 1)),
                                Shadow(color: AppTheme.primaryPurple, blurRadius: 0, offset: Offset(0, -1)),
                              ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // New method for quantity controls and add button in shopping list search context
  Widget _buildShoppingListQuantityControls(ImatDataHandler iMat) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end, // Align to the right
      children: [
        Container(
          height: 36, // Increased from 32
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withOpacity(0.1), // Background for the number area
            borderRadius: BorderRadius.circular(8),      // Overall rounding for the -/1/+ group
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AnimatedProductTileButton(
                icon: Icons.remove,
                tooltip: 'Minska antal',
                borderRadius: const BorderRadius.only( // Left side rounded
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                onPressed: () {
                  if (_shoppingListQuantity > 1) {
                    setState(() {
                      _shoppingListQuantity--;
                    });
                  }
                },
              ),
              Container( // Quantity display
                width: 40, // Increased from 36
                height: 36, // Increased from 32
                alignment: Alignment.center,
                // No separate decoration; background comes from the parent Container
                child: Text(
                  _shoppingListQuantity.toString(),
                  style: const TextStyle(
                    fontSize: 18, // Increased from 14
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryPurple,
                  ),
                ),
              ),
              _AnimatedProductTileButton(
                icon: Icons.add,
                tooltip: 'Öka antal',
                borderRadius: const BorderRadius.only( // Right side rounded
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                onPressed: () {
                  setState(() {
                    _shoppingListQuantity++;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: AppTheme.paddingSmall), // Spacer before "Lägg till" button
        // Add to Shopping List Button
        ElevatedButton(
          onPressed: () {
            widget.onAddToShoppingList?.call(widget.product, _shoppingListQuantity);
          },
          style: AppTheme.primaryButtonStyle.copyWith(
            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: AppTheme.paddingSmall, vertical: AppTheme.paddingTiny)),
            textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Increased from 12
          ),
          child: const Text('Lägg till'),
        ),
      ],
    );
  }

  // Helper method to build the historic amount display
  Widget _buildHistoricAmountDisplay() {
    String unitSuffix = 'st'; // Default to 'st'
    if (widget.product.unit.contains('/')) {
      final parts = widget.product.unit.split('/');
      if (parts.length > 1) {
        final lastPart = parts.last.toLowerCase();
        if (lastPart == 'kg') {
          unitSuffix = 'kg';
        } else if (lastPart == 'st') {
          unitSuffix = 'st';
        }
        // Add more conditions if other units like 'g', 'l', 'ml' are possible
      }
    }
    return Text(
      'Antal: ${widget.historicAmount} $unitSuffix',
      style: const TextStyle(
        fontSize: 18, // Increased from 14
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary, // Or AppTheme.primaryPurple
      ),
    );
  }

  Widget _buildBackCard(ImatDataHandler iMat) {
    final productDetail = iMat.getDetail(widget.product);

    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppTheme.primaryPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Produktinformation',
                style: TextStyle(
                  fontSize: 20, // Increased from 16
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 18, // Increased from 14
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (productDetail != null) ...[
                    if (productDetail.brand.isNotEmpty) ...[
                      _buildInfoRow('Märke', productDetail.brand),
                      const SizedBox(height: 8),
                    ],
                    if (productDetail.description.isNotEmpty) ...[
                      _buildInfoRow('Beskrivning', productDetail.description),
                      const SizedBox(height: 8),
                    ],
                    if (productDetail.contents.isNotEmpty) ...[
                      _buildInfoRow('Innehåll', productDetail.contents),
                      const SizedBox(height: 8),
                    ],
                    if (productDetail.origin.isNotEmpty) ...[
                      _buildInfoRow('Ursprung', productDetail.origin),
                      const SizedBox(height: 8),
                    ],
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.grey[400],
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ingen detaljerad information tillgänglig',
                            style: TextStyle(
                              fontSize: 16, // Increased from 12
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pris',
                          style: TextStyle(
                            fontSize: 18, // Increased from 14
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${widget.product.price.toStringAsFixed(2)} ${widget.product.unit}',
                          style: const TextStyle(
                            fontSize: 18, // Increased from 14
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryPurple.withOpacity(0.1),
                  AppTheme.primaryPurple.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryPurple.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedRotation(
                  turns: _isHovered ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.flip_to_front,
                    size: 18,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Tryck för att vända tillbaka',
                  style: TextStyle(
                    fontSize: 16, // Increased from 12
                    color: AppTheme.primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16, // Increased from 12
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryPurple,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16, // Increased from 12
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(ImatDataHandler iMat) {
    return _AnimatedProductTileButton(
      icon: Icons.add,
      tooltip: 'Lägg till i varukorg',
      onPressed: () {
        iMat.shoppingCartAdd(ShoppingItem(widget.product));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.product.name} har lagts till i kundvagnen.',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.primaryPurple,
          ),
        );
      },
    );
  }

  Widget _buildQuantityControls(
      ImatDataHandler iMat, ShoppingItem cartItem, int quantity) {
    return GestureDetector(
      onTap: () {}, // Prevent flip when tapping quantity controls
      child: Container(
        height: 36, // Increased from 32
        decoration: BoxDecoration(
          color: AppTheme.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AnimatedProductTileButton(
              icon: Icons.remove,
              tooltip: 'Minska antal',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              onPressed: () {
                if (quantity > 1) {
                  iMat.shoppingCartUpdate(cartItem, delta: -1);
                } else {
                  iMat.shoppingCartRemove(cartItem);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${widget.product.name} har tagits bort från kundvagnen.',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppTheme.error, // Or another appropriate color
                    ),
                  );
                }
              },
            ),
            Container(
              width: 40, // Increased from 36
              height: 36, // Increased from 32
              alignment: Alignment.center,
              child: Text(
                quantity.toString(),
                style: const TextStyle(
                  fontSize: 18, // Increased from 14
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ),
            _AnimatedProductTileButton(
              icon: Icons.add,
              tooltip: 'Öka antal',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              onPressed: () {
                iMat.shoppingCartUpdate(cartItem, delta: 1);
                // Show SnackBar only when increasing, as initial add is handled by _buildAddButton
                // and removal has its own message.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Antal för ${widget.product.name} har ökats till ${quantity + 1}.',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppTheme.primaryPurple,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
