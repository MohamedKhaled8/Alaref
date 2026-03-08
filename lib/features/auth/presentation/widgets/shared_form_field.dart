import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SharedFormField extends StatelessWidget {
  const SharedFormField({
    super.key,
    this.controller,
    this.validator,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.disabledBorder,
    this.textInputAction,
    this.onEditingComplete,
    this.onChanged,
    this.autofocus = false,
    this.readOnly = false,
    this.initialValue,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  });

  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? disabledBorder;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final bool readOnly;
  final String? initialValue;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Color(0xFFE0E6F3),
        width: 1.2,
      ),
    );

    final defaultFocusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Color(0xFF1363DF),
        width: 1.4,
      ),
    );

    final defaultErrorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: theme.colorScheme.error,
        width: 1.4,
      ),
    );

    return TextFormField(
      controller: controller,
      validator: validator,
      initialValue: controller == null ? initialValue : null,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: obscureText ? 1 : maxLines,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      onChanged: onChanged,
      autofocus: autofocus,
      readOnly: readOnly,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF1A1E2A),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: enabledBorder ?? defaultBorder,
        enabledBorder: enabledBorder ?? defaultBorder,
        focusedBorder: focusedBorder ?? defaultFocusedBorder,
        errorBorder: errorBorder ?? defaultErrorBorder,
        focusedErrorBorder: errorBorder ?? defaultErrorBorder,
        disabledBorder: disabledBorder ?? defaultBorder,
        contentPadding: contentPadding,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF9AA4C1),
        ),
        labelStyle: theme.textTheme.bodySmall?.copyWith(
          color: const Color(0xFF6C7589),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

