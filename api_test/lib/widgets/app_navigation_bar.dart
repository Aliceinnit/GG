import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/pages/main_view.dart';
import 'package:api_test/app_theme.dart';
import 'package:api_test/widgets/cart_overlay_provider.dart';
import 'package:api_test/widgets/account_overlay_provider.dart';
import 'package:api_test/widgets/account_icon_widget.dart';

// Global state for logo hover to persist across navigation
class LogoHoverState extends ChangeNotifier {
  bool _isHovered = false;
  
  bool get isHovered => _isHovered;
  
  void setHovered(bool hovered) {
    _isHovered = hovered;
    notifyListeners();
  }
}

class AppNavigationBar extends StatefulWidget {
  final Function(String)? onSearch;
  final VoidCallback? onCartPressed;
  final bool showSearchBar;
  final String? pageTitle; // Added pageTitle parameter
  
  const AppNavigationBar({
    super.key,
    this.onSearch,
    this.onCartPressed,
    this.showSearchBar = true,
    this.pageTitle, // Added to constructor
  });

  @override
  State<AppNavigationBar> createState() => _AppNavigationBarState();
}

class _AppNavigationBarState extends State<AppNavigationBar> {
  final TextEditingController _searchController = TextEditingController();
  static final LogoHoverState _logoHoverState = LogoHoverState();
  bool _isAccountHovered = false;
  bool _isCartHovered = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {    return Container(
      height: 100,
      color: AppTheme.headerGreen,
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium, 
        vertical: AppTheme.paddingMedium,
      ),      child: Row(
      children: [
        // Logo on the left
        _buildLogo(context),
        
        // Conditionally show search bar or spacer
        Expanded(
        child: widget.showSearchBar 
          ? Center(
              child: SizedBox(
                width: 800,
                child: _buildSearchBar(),
              ),
            )
          : widget.pageTitle != null // Check if pageTitle is provided
            ? Center(
                child: Text( // Display the pageTitle
                  widget.pageTitle!,
                  style: TextStyle(
                    fontSize: 24, // Adjust size as needed
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPurple,
                  ),
                ),
              )
            : const SizedBox(), // Empty spacer if no search bar and no title
        ),
        
        // Icons on the right
        _buildRightIcons(context),
      ],
      ),
    );
  }  Widget _buildLogo(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        _logoHoverState.setHovered(true);
      },
      onExit: (_) {
        _logoHoverState.setHovered(false);
      },
      child: GestureDetector(        onTap: () {
          // Reset to show all products
          final iMat = Provider.of<ImatDataHandler>(context, listen: false);
          iMat.selectAllProducts();
          
          // Check if we're already on MainView by checking the widget tree
          bool isOnMainView = false;
          context.visitAncestorElements((element) {
            if (element.widget.runtimeType.toString().contains('MainView')) {
              isOnMainView = true;
              return false; // Stop searching
            }
            return true; // Continue searching
          });
          
          // Only navigate if we're not already on MainView
          if (!isOnMainView) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainView()),
              (route) => false,
            );
          }
        },
        child: AnimatedBuilder(
          animation: _logoHoverState,
          builder: (context, child) {
            return AnimatedScale(
              scale: _logoHoverState.isHovered ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Container(
                width: 100,
                height: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Transform.translate(
                    offset: const Offset(20, 30), // Move left and down
                    child: Transform.scale(
                      scale: 2.0, // Increased from 1.8
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.local_grocery_store,
                            color: AppTheme.primaryPurple,
                            size: 40,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }  Widget _buildSearchBar() {
    return Container(
      height: 48,
      child: TextField(
        controller: _searchController,
        onSubmitted: (value) {
          if (widget.onSearch != null) {
            widget.onSearch!(value);
          }
        },
        decoration: InputDecoration(          hintText: 'Sök varor',
          hintStyle: TextStyle(
            color: AppTheme.primaryPurple,
            fontSize: 18,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.primaryPurple,
            size: 24,
          ),          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppTheme.primaryPurple,
                    size: 24,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    if (widget.onSearch != null) {
                      widget.onSearch!('');
                    }
                  },
                )
              : null,          filled: true,
          fillColor: AppTheme.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(
              color: AppTheme.border,
              width: 1,
            ),
          ),          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(
              color: AppTheme.primaryPurple,
              width: 2,
            ),
          ),          contentPadding: EdgeInsets.symmetric(
            horizontal: AppTheme.paddingLarge,
            vertical: AppTheme.paddingMediumSmall,
          ),
        ),
      ),
    );
  }  Widget _buildRightIcons(BuildContext context) {
    return Row(
      children: [        // Account icon
        MouseRegion(
          onEnter: (_) => setState(() => _isAccountHovered = true),
          onExit: (_) => setState(() => _isAccountHovered = false),
          cursor: SystemMouseCursors.click,
          child: AccountIconWidget(
            isHovered: _isAccountHovered, // Pass hover state
            onPressed: () {
              final accountProvider = Provider.of<AccountOverlayProvider>(context, listen: false);
              accountProvider.showAccount();
            },
          ),
        ),
        
        const SizedBox(width: AppTheme.paddingSmall), // Reduced from AppTheme.paddingMedium
        
        // Shopping cart icon with badge
        MouseRegion(
          onEnter: (_) => setState(() => _isCartHovered = true),
          onExit: (_) => setState(() => _isCartHovered = false),
          cursor: SystemMouseCursors.click,
          child: _buildCartIcon(context, _isCartHovered), // Pass hover state
        ),
      ],
    );
  }

  Widget _buildCartIcon(BuildContext context, bool isHovered) {
    return Consumer<ImatDataHandler>(
      builder: (context, iMat, child) {
        final cartItemCount = iMat.getShoppingCart().items.length;
        
        return GestureDetector(
          onTap: () {
            // Use widget.onCartPressed if available, otherwise default behavior
            if (widget.onCartPressed != null) {
              widget.onCartPressed!();
            } else {
              final cartProvider = Provider.of<CartOverlayProvider>(context, listen: false);
              cartProvider.showCart();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingSmall, vertical: 1), // Reduced horizontal padding
            decoration: isHovered
                ? BoxDecoration(
                    color: Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30.0),
                  )
                : null,
            child: Column( // Changed from Stack to Column for simpler layout
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center, // Center items vertically
              children: [
                Stack( // Stack for icon and badge
                  alignment: Alignment.topRight,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4), // Add some padding to push icon down for badge
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: AppTheme.primaryPurple,
                        size: 36, // Reduced from 38
                      ),
                    ),
                    if (cartItemCount > 0)
                      Container(
                        padding: const EdgeInsets.all(3), 
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple,
                          shape: BoxShape.circle, 
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18, // Reduced from 19
                          minHeight: 18, // Reduced from 19
                        ),
                        child: Text(
                          cartItemCount.toString(),
                          style: TextStyle(
                            color: AppTheme.buttonText,
                            fontSize: 11, // Reduced from 12
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
                // const SizedBox(height: 1), 
                Text(
                  'Varukorg',
                  style: TextStyle(
                    color: AppTheme.primaryPurple,
                    fontSize: 14, // Reduced from 16
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis, 
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
