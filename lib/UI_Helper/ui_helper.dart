import 'package:flutter/material.dart';

class UIHelper {
  // Custom Text Field
  static TextField buildThemedTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefixIcon,
    Widget? suffixIcon,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    double borderRadius = 10.0,
    EdgeInsetsGeometry? contentPadding,
    int? maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: theme.colorScheme.primary),
    );

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: border.copyWith(
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
        ),
        labelStyle: TextStyle(color: theme.colorScheme.primary),
        floatingLabelStyle: TextStyle(color: theme.colorScheme.primary),
      ),
      style: theme.textTheme.bodyMedium,
    );
  }

  // Material button (existing)
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

  // Elevated button (existing)
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