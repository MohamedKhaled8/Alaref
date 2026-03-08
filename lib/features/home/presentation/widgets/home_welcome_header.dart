import 'package:flutter/material.dart';
import 'icon_circle_button.dart';

class HomeWelcomeHeader extends StatelessWidget {
  final String greeting;

  const HomeWelcomeHeader({super.key, required this.greeting});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF335EF7), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF335EF7).withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFFE8EEFF),
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&auto=format&fit=crop',
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'طالبنا البطل 🌟',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1D2E),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconCircleButton(
                icon: Icons.notifications_outlined,
                onTap: () {},
              ),
              const SizedBox(width: 10),
              IconCircleButton(
                icon: Icons.bookmark_outline_rounded,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
