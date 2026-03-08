import 'package:flutter/material.dart';

class SharedButton extends StatelessWidget {
  const SharedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.borderRadius = 16,
    this.width,
    this.height = 56,
    this.isLoading = false,
    this.icon,
    this.gradient,
    this.textStyle,
    this.borderSide,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final double borderRadius;
  final double? width;
  final double? height;
  final bool isLoading;
  final Widget? icon;
  final Gradient? gradient;
  final TextStyle? textStyle;
  final BorderSide? borderSide;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveWidth = width ?? double.infinity;
    final effectiveColor = color ?? theme.primaryColor;
    final effectiveTextStyle = textStyle ??
        theme.textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: borderSide ?? BorderSide.none,
    );

    Widget child;
    if (isLoading) {
      child = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            gradient is LinearGradient
                ? (gradient as LinearGradient).colors.last
                : Colors.white,
          ),
        ),
      );
    } else {
      final rowChildren = <Widget>[
        if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: effectiveTextStyle,
          ),
        ),
      ];

      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: rowChildren,
      );
    }

    if (gradient != null) {
      return SizedBox(
        width: effectiveWidth,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ).borderRadius,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(borderRadius),
              onTap: isLoading ? null : onPressed,
              child: Padding(
                padding: padding,
                child: Center(child: child),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: effectiveWidth,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveColor,
          shape: shape,
          padding: padding,
          elevation: 0,
        ),
        child: child,
      ),
    );
  }
}

