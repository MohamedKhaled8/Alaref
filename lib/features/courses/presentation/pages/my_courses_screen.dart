import 'package:alaref/features/home/presentation/pages/home_screen.dart';
import 'package:alaref/features/home/presentation/widgets/home_course_horizontal_card.dart';
import 'package:alaref/features/home/presentation/widgets/home_package_card.dart';
import 'package:flutter/material.dart';


// ============================================
// MY COURSES SCREEN - مراحل دراسية + أنيميشن
// ============================================
class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'عرض خاص لفترة محدودة',
                        style: TextStyle(
                          color: Color(0xFFFF9800),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'باقاتنا المتكاملة',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1D2E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'كل ما تحتاجه للنجاح في مكان واحد وبسعر أقل',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const HomePackageCard(
                    title: 'باقة الفصل الأول كاملة',
                    subtitle: 'جميع محاضرات الفصل الأول + المذكرات',
                    price: '٤٥٠ ج.م',
                    oldPrice: '٦٠٠ ج.م',
                    gradient: [Color(0xFF335EF7), Color(0xFF5B7AFF)],
                    imageUrl:
                        'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?q=80&w=400&auto=format&fit=crop',
                  ),
                  const SizedBox(height: 16),
                  const HomePackageCard(
                    title: 'باقة المراجعة النهائية',
                    subtitle: '١٠ محاضرات مكثفة + بنك الأسئلة',
                    price: '٣٠٠ ج.م',
                    oldPrice: '٤٥٠ ج.م',
                    gradient: [Color(0xFFE91E63), Color(0xFFFF4081)],
                    imageUrl:
                        'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?q=80&w=400&auto=format&fit=crop',
                  ),
                  const SizedBox(height: 16),
                  const HomePackageCard(
                    title: 'باقة الامتحانات الشاملة',
                    subtitle: '٥٠ امتحان تفاعلي مع التصحيح التلقائي',
                    price: '١٥٠ ج.م',
                    oldPrice: '٢٥٠ ج.م',
                    gradient: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                    imageUrl:
                        'https://images.unsplash.com/photo-1523050335392-93851179ae09?q=80&w=400&auto=format&fit=crop',
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'أهم الكورسات المقترحة',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1D2E),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('رؤية المزيد'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const HomeCourseHorizontalCard(
                    title: 'المحاضرة الثالثة',
                    category: 'نحو',
                    lessons: '١٢ درس',
                    instructor: 'أ. عمرو العارف',
                    progress: 0.65,
                    imageUrl:
                        'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?q=80&w=600&auto=format&fit=crop',
                  ),
                  const SizedBox(height: 16),
                  const HomeCourseHorizontalCard(
                    title: 'مراجعة البلاغة',
                    category: 'بلاغة',
                    lessons: '٨ دروس',
                    instructor: 'أ. عمرو العارف',
                    progress: 0.15,
                    imageUrl:
                        'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?q=80&w=600&auto=format&fit=crop',
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageCard extends StatefulWidget {
  final int index;
  final bool visible;
  final String stageName;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _StageCard({
    required this.index,
    required this.visible,
    required this.stageName,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_StageCard> createState() => _StageCardState();
}

class _StageCardState extends State<_StageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.visible ? 1 : 0,
      duration: const Duration(milliseconds: 400),
      child: AnimatedSlide(
        offset: widget.visible ? Offset.zero : const Offset(0, 0.25),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        child: ScaleTransition(
          scale: _scale,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _controller.forward().then((_) {
                  _controller.reverse();
                  widget.onTap();
                });
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.gradient,
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient.first.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.stageName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white.withOpacity(0.9),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
