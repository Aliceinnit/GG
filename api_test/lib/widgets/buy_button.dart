import 'package:flutter/material.dart';

class BuyButton extends StatelessWidget {
  const BuyButton({required this.onPressed, super.key});

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () {
        onPressed();
      },
    );
  }
}
