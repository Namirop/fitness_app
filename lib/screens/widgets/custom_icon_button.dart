import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final double? size;
  final Color? color;
  final double? radius;
  final IconData icon;
  const CustomIconButton({
    required this.onTap,
    this.size,
    this.color,
    this.radius,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size ?? 45,
        height: size ?? 45,
        decoration: BoxDecoration(
          color: color ?? Colors.white60,
          borderRadius: BorderRadius.circular(radius ?? 15),
        ),
        child: Icon(icon),
      ),
    );
  }
}
