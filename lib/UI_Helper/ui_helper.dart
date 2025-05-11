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

