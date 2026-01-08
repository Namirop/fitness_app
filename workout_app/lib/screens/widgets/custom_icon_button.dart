import 'package:flutter/material.dart';
import 'package:workout_app/core/constants/app_constants.dart';

class CustomIcon extends StatelessWidget {
  final VoidCallback? onTap;
  final double? size;
  final Color? color;
  final double? radius;
  final Widget icon;
  final double? topPadding;
  const CustomIcon({
    super.key,
    this.onTap,
    this.size,
    this.color,
    this.radius,
    required this.icon,
    this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding ?? 0),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          width: size ?? 50,
          height: size ?? 50,
          decoration: BoxDecoration(
            color: color ?? const Color.fromARGB(117, 255, 255, 255),
            borderRadius: BorderRadius.circular(
              radius ?? AppBorderRadius.medium,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius ?? 18),
            splashColor: Colors.black.withOpacity(0.2),
            highlightColor: Colors.black.withOpacity(0.1),
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}
