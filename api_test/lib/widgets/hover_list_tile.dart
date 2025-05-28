import 'package:flutter/material.dart';

class HoverListTile extends StatefulWidget {
  final String title;
  final VoidCallback? onTap;

  const HoverListTile({required this.title, this.onTap, super.key});

  @override
  State<HoverListTile> createState() => _HoverListTileState();
}

class _HoverListTileState extends State<HoverListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        color: _isHovered ? Colors.grey[300] : Colors.transparent,
        child: ListTile(
          title: Text(widget.title),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
