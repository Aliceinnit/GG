import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_test/widgets/account_sidebar.dart';
import 'dart:ui';

class AccountOverlayProvider extends ChangeNotifier {
  bool _isAccountVisible = false;
  
  bool get isAccountVisible => _isAccountVisible;
  
  void showAccount() {
    _isAccountVisible = true;
    notifyListeners();
  }
  
  void hideAccount() {
    _isAccountVisible = false;
    notifyListeners();
  }
  
  void toggleAccount() {
    _isAccountVisible = !_isAccountVisible;
    notifyListeners();
  }
}

class AccountOverlayWrapper extends StatefulWidget {
  final Widget child;
  
  const AccountOverlayWrapper({
    super.key,
    required this.child,
  });
  
  @override
  State<AccountOverlayWrapper> createState() => _AccountOverlayWrapperState();
}

class _AccountOverlayWrapperState extends State<AccountOverlayWrapper>
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
    return Consumer<AccountOverlayProvider>(
      builder: (context, accountProvider, child) {
        // Animate based on account visibility
        if (accountProvider.isAccountVisible) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
        
        return Stack(
          children: [
            widget.child,
            
            // Backdrop blur and overlay
            if (accountProvider.isAccountVisible)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => accountProvider.hideAccount(),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            
            // Account sidebar
            if (accountProvider.isAccountVisible)
              AccountSidebar(
                onClose: () => accountProvider.hideAccount(),
                slideAnimation: _slideAnimation,
              ),
          ],
        );
      },
    );
  }
}
