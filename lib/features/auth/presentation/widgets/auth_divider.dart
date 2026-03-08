import 'package:flutter/material.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({
    super.key,
    this.text = 'Or continue with',
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: Color(0xFFE0E6F3),
            thickness: 1,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF9AA4C1),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Divider(
            color: Color(0xFFE0E6F3),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

