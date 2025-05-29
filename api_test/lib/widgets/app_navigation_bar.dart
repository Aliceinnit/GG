import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/pages/account_view.dart';
import 'package:api_test/pages/main_view.dart';
import 'package:api_test/app_theme.dart';

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
  final VoidCallback? onAccountPressed;
  final bool showSearchBar;
  
  const AppNavigationBar({
    super.key,
    this.onSearch,
    this.onCartPressed,
    this.onAccountPressed,
    this.showSearchBar = true,
  });

  @override
  State<AppNavigationBar> createState() => _AppNavigationBarState();
}

class _AppNavigationBarState extends State<AppNavigationBar> {
  final TextEditingController _searchController = TextEditingController();
  static final LogoHoverState _logoHoverState = LogoHoverState();

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
          : const SizedBox(), // Empty spacer when search bar is hidden
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
                      scale: 1.8, // Make the logo bigger while keeping container size
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
  }
  Widget _buildRightIcons(BuildContext context) {
    return Row(
      children: [
        // Account icon
        _buildAccountIcon(context),
        
        const SizedBox(width: AppTheme.paddingMedium),
        
        // Shopping cart icon with badge
        _buildCartIcon(context),
      ],
    );
  }

  Widget _buildCartIcon(BuildContext context) {
    return Consumer<ImatDataHandler>(
      builder: (context, iMat, child) {
        final cartItemCount = iMat.getShoppingCart().items.length;
        
        return Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [                IconButton(
                  onPressed: widget.onCartPressed ?? () {
                    // Default behavior - could show cart modal or navigate to cart
                  },
                  icon: Icon(
                    Icons.shopping_bag_outlined,
                    color: AppTheme.primaryPurple,
                    size: 32,
                  ),
                  tooltip: 'Varukorg',
                ),
                Text(
                  'Varukorg',
                  style: TextStyle(
                    color: AppTheme.primaryPurple,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (cartItemCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),                  decoration: BoxDecoration(
                    color: AppTheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),                  child: Text(
                    cartItemCount.toString(),
                    style: TextStyle(
                      color: AppTheme.buttonText,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
  Widget _buildAccountIcon(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: widget.onAccountPressed ?? () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AccountView()),
            );
          },
          icon: Icon(
            Icons.person_outline,
            color: AppTheme.primaryPurple,
            size: 32,
          ),
          tooltip: 'Mina sidor',
        ),        Text(
          'Mina sidor',
          style: TextStyle(
            color: AppTheme.primaryPurple,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
