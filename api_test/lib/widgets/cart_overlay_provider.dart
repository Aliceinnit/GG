import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_test/widgets/cart_sidebar.dart';
import 'dart:ui';

class CartOverlayProvider extends ChangeNotifier {
  bool _isCartVisible = false;
  
  bool get isCartVisible => _isCartVisible;
  
  void showCart() {
    _isCartVisible = true;
    notifyListeners();
  }
  
  void hideCart() {
    _isCartVisible = false;
    notifyListeners();
  }
  
  void toggleCart() {
    _isCartVisible = !_isCartVisible;
    notifyListeners();
  }
}

class CartOverlayWrapper extends StatefulWidget {
  final Widget child;
  
  const CartOverlayWrapper({
    super.key,
    required this.child,
  });
  
  @override
  State<CartOverlayWrapper> createState() => _CartOverlayWrapperState();
}

class _CartOverlayWrapperState extends State<CartOverlayWrapper>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<CartOverlayProvider>(
      builder: (context, cartProvider, child) {
        // Animate based on cart visibility
        if (cartProvider.isCartVisible) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
        
        return Stack(
          children: [
            widget.child,
            
            // Backdrop blur and overlay
            if (cartProvider.isCartVisible)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => cartProvider.hideCart(),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            
            // Cart sidebar
            if (cartProvider.isCartVisible)
              CartSidebar(
                onClose: () => cartProvider.hideCart(),
                slideAnimation: _slideAnimation,
              ),
          ],
        );
      },
    );
  }
}
