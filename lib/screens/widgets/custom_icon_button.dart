import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double? size;
  final Color? color;
  final double? radius;
  final Widget icon;
  const CustomIconButton({
    this.onTap,
    this.size,
    this.color,
    this.radius,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        width: size ?? 50,
        height: size ?? 50,
        decoration: BoxDecoration(
          color: color ?? const Color.fromARGB(117, 255, 255, 255),
          borderRadius: BorderRadius.circular(radius ?? 18),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius ?? 18),
          splashColor: Colors.black.withOpacity(0.2),
          highlightColor: Colors.black.withOpacity(0.1),
          child: Center(child: icon),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       width: size ?? 50,
  //       height: size ?? 50,
  //       decoration: BoxDecoration(
  //         color: color ?? const Color.fromARGB(117, 255, 255, 255),
  //         borderRadius: BorderRadius.circular(radius ?? 18),
  //       ),
  //       child: Center(child: icon),
  //     ),
  //   );
  // }
}
