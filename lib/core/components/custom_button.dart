import 'package:flutter/material.dart';
import 'package:loop/core/const/palette.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final Color color;
  final double borderRadius;
  final double elevation;
  final double padding;
  final double? height;
  final double? width;
  final Icon? icon;

  const CustomButton({
    super.key,
    required this.onTap,
    required this.child,
    this.color = Palette.themeColor,
    this.borderRadius = 8.0,
    this.elevation = 4.0,
    this.padding = 6.0,
    this.height,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Material(
        elevation: elevation,
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 8),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
