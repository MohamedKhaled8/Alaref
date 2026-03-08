import 'package:flutter/material.dart';
import 'package:alaref/core/utils/enums/stage.dart';
import 'stage_subjects_screen.dart';

// ============================================
// OTHER SCREENS
// ============================================
class StagesScreen extends StatefulWidget {
  const StagesScreen({super.key});

  @override
  State<StagesScreen> createState() => _StagesScreenState();
}

class _StagesScreenState extends State<StagesScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerOpacity;
  late Animation<Offset> _headerSlide;
  int _visibleCount = 0;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerOpacity = CurvedAnimation(
      parent: _headerController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _headerController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _headerController.forward();
    _runEntranceAnimation();
  }

  void _runEntranceAnimation() {
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: 300 + (i * 200)), () {
        if (mounted) setState(() => _visibleCount = i + 1);
      });
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF335EF7).withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SlideTransition(
                    position: _headerSlide,
                    child: FadeTransition(
                      opacity: _headerOpacity,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 40, 28, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF335EF7).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'مستقبلك يبدأ من هنا',
                                style: TextStyle(
                                  color: Color(0xFF335EF7),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'المراحل الدراسية',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1D2E),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'اختر طريقك التعليمي للوصول إلى القمة',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _PremiumStageCard(
                        index: 0,
                        visible: _visibleCount > 0,
                        title: 'المرحلة الابتدائية',
                        desc: 'تأسيس قوي لمستقبل مشرق',
                        icon: Icons.auto_stories_rounded,
                        color: const Color(0xFF2E7D32),
                        tags: const ['تأسيس', 'ألعاب تعليمية'],
                        onTap: () =>
                            _openStage(context, 'الابتدائية', Stage.primary),
                      ),
                      const SizedBox(height: 20),
                      _PremiumStageCard(
                        index: 1,
                        visible: _visibleCount > 1,
                        title: 'المرحلة الإعدادية',
                        desc: 'تطوير المهارات والمعرفة الأساسية',
                        icon: Icons.psychology_rounded,
                        color: const Color(0xFFE65100),
                        tags: const ['تطوير', 'لغات'],
                        onTap: () =>
                            _openStage(context, 'الإعدادية', Stage.preparatory),
                      ),
                      const SizedBox(height: 20),
                      _PremiumStageCard(
                        index: 2,
                        visible: _visibleCount > 2,
                        title: 'المرحلة الثانوية',
                        desc: 'رحلة النجاح نحو الجامعة',
                        icon: Icons.workspace_premium_rounded,
                        color: const Color(0xFF1565C0),
                        tags: const ['تخصص', 'أوائل'],
                        onTap: () =>
                            _openStage(context, 'الثانوية', Stage.secondary),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openStage(BuildContext context, String name, Stage stage) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StageSubjectsScreen(stage: stage, stageName: name),
      ),
    );
  }
}

class _PremiumStageCard extends StatelessWidget {
  final int index;
  final bool visible;
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final List<String> tags;
  final VoidCallback onTap;

  const _PremiumStageCard({
    required this.index,
    required this.visible,
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    required this.tags,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 600),
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 0.2),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutQuart,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(30),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(icon, color: color, size: 36),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: tags
                                .map(
                                  (tag) => Container(
                                    margin: const EdgeInsets.only(left: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1D2E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            desc,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.grey[300],
                      size: 28,
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