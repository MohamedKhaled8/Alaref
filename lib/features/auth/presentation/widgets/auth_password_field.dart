import 'package:alaref/features/auth/presentation/cubit/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'shared_form_field.dart';

class AuthPasswordField extends StatelessWidget {
  const AuthPasswordField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.fillColor,
    this.enabledBorder,
    this.focusedBorder,
    this.contentPadding,
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final Color? fillColor;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final authCubit = context.read<AuthCubit>();
        return SharedFormField(
          controller: controller,
          labelText: labelText ?? 'Password',
          hintText: hintText ?? 'Password',
          obscureText: authCubit.isPasswordHidden,
          validator: validator,
          fillColor: fillColor,
          enabledBorder: enabledBorder,
          focusedBorder: focusedBorder,
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: IconButton(
            onPressed: () => authCubit.togglePasswordVisibility(),
            icon: Icon(
              authCubit.isPasswordHidden
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF94A3B8),
            ),
          ),
        );
      },
    );
  }
}
