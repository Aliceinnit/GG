import 'package:api_test/model/imat/product.dart';
import 'package:api_test/model/imat/shopping_item.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/app_theme.dart';
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
        width: 32,
        height: 32,
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
          size: 18,
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
  const ProductTile(this.product, {super.key});

  final Product product;

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
                              fontSize: 16,
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
                                  size: 14,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Tryck för detaljer", // Changed text here
                                  style: TextStyle(
                                    fontSize: 12,
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
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                        if (!isInCart)
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
        Positioned(
          top: 8,
          left: 8,
          child: GestureDetector(
            onTap: () {
              iMat.toggleFavorite(widget.product);
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isFavorite
                      ? AppTheme.primaryPurple.withOpacity(0.3)
                      : AppTheme.border,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? AppTheme.primaryPurple : AppTheme.textSecondary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
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
                  fontSize: 16,
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
                      fontSize: 14,
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
                              fontSize: 12,
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
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${widget.product.price.toStringAsFixed(2)} ${widget.product.unit}',
                          style: const TextStyle(
                            fontSize: 14,
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
                    fontSize: 12,
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
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryPurple,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
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
      },
    );
  }

  Widget _buildQuantityControls(
      ImatDataHandler iMat, ShoppingItem cartItem, int quantity) {
    return GestureDetector(
      onTap: () {}, // Prevent flip when tapping quantity controls
      child: Container(
        height: 32,
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
                }
              },
            ),
            Container(
              width: 36,
              height: 32,
              alignment: Alignment.center,
              child: Text(
                quantity.toString(),
                style: const TextStyle(
                  fontSize: 14,
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
              },
            ),
          ],
        ),
      ),
    );
  }
}
