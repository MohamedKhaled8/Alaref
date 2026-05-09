import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const _darkText = Color(0xFF1A1D2E);
  static const _supportEmail = 'support@alaref.app';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: _darkText),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'المساعدة والدعم',
            style: TextStyle(
              color: _darkText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _FaqTile(
              question: 'كيف أبدأ مشاهدة الدروس؟',
              answer:
                  'من تبويب الكورسات أو الرئيسية اختر المادة ثم الدرس. قد يُطلب منك '
                  'اجتياز امتحان مسبق أو شراء محتوى مدفوع حسب إعدادات الدرس.',
            ),
            _FaqTile(
              question: 'نسيت كلمة المرور',
              answer:
                  'استخدم خيار «نسيت كلمة المرور» من شاشة تسجيل الدخول (إن وُجد)، '
                  'أو تواصل مع الدعم عبر البريد أدناه.',
            ),
            _FaqTile(
              question: 'كيف تُحسب درجة الامتحان؟',
              answer:
                  'تُجمع درجات الأسئلة التي أجبت عنها بشكل صحيح وتقارن بالدرجة الكلية '
                  'للاختبار. يمكنك مراجعة نتائجك من «شهاداتي الدراسية».',
            ),
            const SizedBox(height: 16),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => _openEmail(context),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF335EF7).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.email_outlined,
                          color: Color(0xFF335EF7),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تواصل مع الدعم',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              _supportEmail,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF335EF7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.open_in_new_rounded, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEmail(BuildContext context) async {
    final uri = Uri.parse(
      'mailto:$_supportEmail?subject=${Uri.encodeComponent('دعم منصة العارف')}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('انسخ البريد يدوياً: $_supportEmail'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Text(
              question,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  answer,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
