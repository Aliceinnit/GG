import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/model/internet_handler.dart';
import 'package:api_test/widgets/delete_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// New StatefulWidget for animated icon buttons
class _AnimatedCartButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const _AnimatedCartButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  _AnimatedCartButtonState createState() => _AnimatedCartButtonState();
}

class _AnimatedCartButtonState extends State<_AnimatedCartButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _isPressed ? 1.3 : (_isHovered ? 1.1 : 1.0);
    final Color iconColor = _isHovered ? widget.color.withOpacity(0.8) : widget.color;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: Tooltip(
          message: widget.tooltip,
          child: Transform.scale(
            scale: scale,
            child: Icon(
              widget.icon,
              color: iconColor,
              size: 24, // Standard icon size
            ),
          ),
        ),
      ),
    );
  }
}

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    var iMat = context.watch<ImatDataHandler>();
    var items = iMat.getShoppingCart().items;

    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Din kundvagn är tom.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final String imageUrl = InternetHandler.getImageUrl(item.product.productId);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            leading: SizedBox(
              width: 50,
              height: 50,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/images/Image-not-found.png');
                },
              ),
            ),
            title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Pris: ${item.product.price?.toStringAsFixed(2) ?? 'N/A'} kr/st'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _AnimatedCartButton(
                  icon: Icons.remove_circle_outline,
                  color: Colors.redAccent,
                  tooltip: 'Minska antal',
                  onPressed: () {
                    iMat.shoppingCartUpdate(item, delta: -1.0);
                  },
                ),
                Padding( // Added padding for better spacing around the quantity text
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '${item.amount}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                _AnimatedCartButton(
                  icon: Icons.add_circle_outline,
                  color: Colors.green,
                  tooltip: 'Öka antal',
                  onPressed: () {
                    iMat.shoppingCartUpdate(item, delta: 1.0);
                  },
                ),
                const SizedBox(width: 8),
                DeleteButton(
                  onPressed: () {
                    iMat.shoppingCartRemove(item);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
