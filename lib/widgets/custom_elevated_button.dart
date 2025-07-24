import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Widget? icon;
  final ButtonStyle? style;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final Size? minimumSize;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? height;
  final double? width;

  const CustomElevatedButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.style,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.minimumSize,
    this.padding,
    this.borderRadius,
    this.isLoading = false,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style ?? ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        foregroundColor: foregroundColor ?? Colors.white,
        elevation: elevation ?? 2,
        minimumSize: minimumSize ?? const Size(0, 48),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon!,
                    const SizedBox(width: 8),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: fontSize ?? 16,
                        fontWeight: fontWeight ?? FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize ?? 16,
                    fontWeight: fontWeight ?? FontWeight.w600,
                  ),
                ),
    );

    return SizedBox(
      height: height ?? 48,
      width: width,
      child: button,
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Widget? icon;
  final ButtonStyle? style;
  final Color? borderColor;
  final Color? textColor;
  final double? elevation;
  final Size? minimumSize;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? height;
  final double? width;

  const CustomOutlinedButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.style,
    this.borderColor,
    this.textColor,
    this.elevation,
    this.minimumSize,
    this.padding,
    this.borderRadius,
    this.isLoading = false,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 48,
      width: width,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: style ?? OutlinedButton.styleFrom(
          foregroundColor: textColor ?? Theme.of(context).primaryColor,
          elevation: elevation ?? 0,
          minimumSize: minimumSize ?? const Size(double.infinity, 48),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: BorderSide(
            color: borderColor ?? Theme.of(context).primaryColor,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? Theme.of(context).primaryColor,
                  ),
                ),
              )
            : icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icon!,
                      const SizedBox(width: 8),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: fontSize ?? 16,
                          fontWeight: fontWeight ?? FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize ?? 16,
                      fontWeight: fontWeight ?? FontWeight.w600,
                    ),
                  ),
      ),
    );
  }
}
