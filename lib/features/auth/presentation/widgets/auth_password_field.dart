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
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;

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
          suffixIcon: IconButton(
            onPressed: () => authCubit.togglePasswordVisibility(),
            icon: Icon(
              authCubit.isPasswordHidden
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF9AA4C1),
            ),
          ),
        );
      },
    );
  }
}
