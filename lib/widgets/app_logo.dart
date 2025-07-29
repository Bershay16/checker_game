import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.asset(
          'assets/images/logo.jpg',
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: borderRadius,
              ),
              child: const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 40,
              ),
            );
          },
        ),
      ),
    );
  }
}

class AppLogoWithText extends StatelessWidget {
  final double? logoSize;
  final String? title;
  final TextStyle? titleStyle;
  final MainAxisAlignment alignment;
  final double spacing;

  const AppLogoWithText({
    super.key,
    this.logoSize,
    this.title,
    this.titleStyle,
    this.alignment = MainAxisAlignment.center,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        AppLogo(
          width: logoSize,
          height: logoSize,
        ),
        if (title != null) ...[
          SizedBox(width: spacing),
          Text(
            title!,
            style: titleStyle ?? const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ],
    );
  }
} 