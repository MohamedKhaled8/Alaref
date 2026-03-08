import 'package:flutter/material.dart';

class AuthSocialButtons extends StatelessWidget {
  const AuthSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _SocialButton(
            label: 'Google',
            icon: Icons.g_mobiledata, // Replace with actual Google icon asset if available.
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _SocialButton(
            label: 'Facebook',
            icon: Icons.facebook,
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: () {
        // TODO: Implement social auth.
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFE0E6F3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF1363DF),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF1A1E2A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

