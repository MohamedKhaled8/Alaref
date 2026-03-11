import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});
  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  List<LessonModel> _packages = [];
  bool _loading = true;
  int _visibleCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final snap = await FirebaseFirestore.instance
        .collection('lessons')
        .where('isPackage', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();
    setState(() {
      _packages = snap.docs
          .map((d) => LessonModel.fromMap(d.data(), d.id))
          .toList();
      _loading = false;
    });
    for (int i = 0; i < _packages.length; i++) {
      Future.delayed(Duration(milliseconds: 150 + i * 100), () {
        if (mounted) setState(() => _visibleCount = i + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
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
                        'عروض مميزة',
                        style: TextStyle(
                          color: Color(0xFFFF9800),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'الباقات',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1D2E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'وفر أكتر مع باقاتنا المتكاملة',
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            _loading
                ? const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF335EF7),
                      ),
                    ),
                  )
                : _packages.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_rounded,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا يوجد باقات حالياً',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, i) {
                        final pkg = _packages[i];
                        final visible = i < _visibleCount;
                        return AnimatedOpacity(
                          opacity: visible ? 1 : 0,
                          duration: const Duration(milliseconds: 500),
                          child: AnimatedSlide(
                            offset: visible
                                ? Offset.zero
                                : const Offset(0, 0.15),
                            duration: const Duration(milliseconds: 600),
                            child: _PackageCard(
                              package: pkg,
                              onTap: () => _openPackage(pkg),
                            ),
                          ),
                        );
                      }, childCount: _packages.length),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _openPackage(LessonModel pkg) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _PackageDetailScreen(package: pkg)),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final LessonModel package;
  final VoidCallback onTap;
  const _PackageCard({required this.package, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  package.imageUrl.isNotEmpty
                      ? Image.network(
                          package.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: const Color(0xFF335EF7)),
                        )
                      : Container(color: const Color(0xFF335EF7)),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.75),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'باقة • ${package.packageItems.length} حصة',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          package.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${package.price.toStringAsFixed(0)} ج.م',
                                style: const TextStyle(
                                  color: Color(0xFF335EF7),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              package.teacherName,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===== PACKAGE DETAIL SCREEN =====
class _PackageDetailScreen extends StatefulWidget {
  final LessonModel package;
  const _PackageDetailScreen({required this.package});
  @override
  State<_PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<_PackageDetailScreen> {
  final _codeCtrl = TextEditingController();
  bool _unlocked = false;
  bool _validating = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _validateCode() async {
    if (_codeCtrl.text.isEmpty) return;
    setState(() => _validating = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _validating = false);
      return;
    }

    final snap = await FirebaseFirestore.instance
        .collection('codes')
        .where('code', isEqualTo: _codeCtrl.text)
        .where('isUsed', isEqualTo: false)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      await snap.docs.first.reference.update({
        'isUsed': true,
        'usedByStudentId': user.uid,
        'usedByStudentName': user.displayName ?? '',
        'usedAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _unlocked = true;
        _validating = false;
      });
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ تم فتح الباقة بنجاح!'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
    } else {
      setState(() => _validating = false);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('❌ الكود غير صالح أو مستخدم'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  widget.package.imageUrl.isNotEmpty
                      ? Image.network(
                          widget.package.imageUrl,
                          height: 260,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 260,
                            color: const Color(0xFF335EF7),
                          ),
                        )
                      : Container(height: 260, color: const Color(0xFF335EF7)),
                  Container(
                    height: 260,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.package.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.package.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Price & Teacher
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF335EF7),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${widget.package.price.toStringAsFixed(0)} ج.م',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.package.teacherName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '${widget.package.packageItems.length} حصة',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Code Input
                  if (!_unlocked) ...[
                    const Text(
                      'أدخل الكود لفتح الباقة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1D2E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _codeCtrl,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                            decoration: InputDecoration(
                              hintText: '00000000',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _validating ? null : _validateCode,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF335EF7), Color(0xFF5B7AFF)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: _validating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.lock_open_rounded,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Lessons List
                  Text(
                    _unlocked ? 'الحصص المتاحة' : 'محتويات الباقة',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1D2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.package.packageItems.asMap().entries.map((e) {
                    final i = e.key;
                    final item = e.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: const Color(0xFF335EF7).withOpacity(0.1),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF335EF7),
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF1A1D2E),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _unlocked
                                ? Icons.play_circle_rounded
                                : Icons.lock_rounded,
                            color: _unlocked
                                ? const Color(0xFF4CAF50)
                                : Colors.grey[300],
                            size: 28,
                          ),
                        ],
                      ),
                    );
                  }),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
