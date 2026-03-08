import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AuthFooter extends StatelessWidget {
  const AuthFooter({
    super.key,
    required this.leadingText,
    required this.actionText,
    this.onActionTap,
  });

  final String leadingText;
  final String actionText;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: RichText(
        text: TextSpan(
          text: leadingText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF6C7589),
          ),
          children: [
            TextSpan(
              text: actionText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF1363DF),
                fontWeight: FontWeight.w700,
              ),
              recognizer: TapGestureRecognizer()..onTap = onActionTap,
            ),
          ],
        ),
      ),
    );
  }
}

