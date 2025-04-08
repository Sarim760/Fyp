import 'package:flutter/material.dart';

class UIHelper {
  // Material button that follows app theme
  static MaterialButton buildThemedButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    Color? buttonColor,
    double minWidth = 200.0,
    double height = 42.0,
    double elevation = 5.0,
    double borderRadius = 30.0,
  }) {
    final theme = Theme.of(context);
    
    return MaterialButton(
      onPressed: onPressed,
      minWidth: minWidth,
      height: height,
      color: buttonColor ?? theme.colorScheme.primary,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Elevated button that follows app theme
  static ElevatedButton buildThemedElevatedButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    double borderRadius = 30.0,
  }) {
    final theme = Theme.of(context);
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}