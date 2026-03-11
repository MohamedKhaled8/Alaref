import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                  Row(
                    children: [
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            return const Text(
                              'طالبنا البطل',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1D2E),
                                letterSpacing: -0.3,
                              ),
                            );
                          }

                          String name = user.displayName ?? 'طالبنا';
                          if (snapshot.hasData && snapshot.data!.exists) {
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>?;
                            if (data != null &&
                                data['name'] != null &&
                                data['name'].toString().trim().isNotEmpty) {
                              name = data['name'];
                            }
                          }
                          // Get first name for display, avoiding empty strings
                          final trimmedName = name.trim();
                          final firstName = trimmedName.isNotEmpty
                              ? trimmedName.split(' ').first
                              : 'طالبنا';

                          return Text(
                            firstName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1D2E),
                              letterSpacing: -0.3,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      const _AnimatedHand(),
                    ],
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

class _AnimatedHand extends StatefulWidget {
  const _AnimatedHand();

  @override
  State<_AnimatedHand> createState() => _AnimatedHandState();
}

class _AnimatedHandState extends State<_AnimatedHand>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(
        begin: -0.05,
        end: 0.1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: const Text('👋', style: TextStyle(fontSize: 18)),
    );
  }
}
