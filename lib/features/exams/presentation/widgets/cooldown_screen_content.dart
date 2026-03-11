import 'dart:async';
import 'package:flutter/material.dart';

class CooldownScreenContent extends StatefulWidget {
  final DateTime nextRetakeTime;
  final VoidCallback onExit;

  const CooldownScreenContent({
    super.key,
    required this.nextRetakeTime,
    required this.onExit,
  });

  @override
  State<CooldownScreenContent> createState() => _CooldownScreenContentState();
}

class _CooldownScreenContentState extends State<CooldownScreenContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Timer _timer;
  Duration _remaining = Duration.zero;

  static const _errorRed = Color(0xFFEF4444);
  static const _primaryBlue = Color(0xFF335EF7);
  static const _darkText = Color(0xFF1A1D2E);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateRemaining();
        });
      }
    });
  }

  void _updateRemaining() {
    final now = DateTime.now();
    if (widget.nextRetakeTime.isAfter(now)) {
      _remaining = widget.nextRetakeTime.difference(now);
    } else {
      _remaining = Duration.zero;
      _timer.cancel();
      // If time is up, maybe exit
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _animController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds <= 0) return 'جاهز الآن!';
    int days = d.inDays;
    int hours = d.inHours.remainder(24);
    int minutes = d.inMinutes.remainder(60);
    int seconds = d.inSeconds.remainder(60);

    List<String> parts = [];
    if (days > 0) parts.add('$days يوم');
    if (hours > 0) parts.add('$hours ساعة');
    if (minutes > 0) parts.add('$minutes دقيقة');
    if (days == 0 && hours == 0) parts.add('$seconds ثانية');

    return parts.join(' و ');
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime =
        '${widget.nextRetakeTime.year}/${widget.nextRetakeTime.month.toString().padLeft(2, '0')}/${widget.nextRetakeTime.day.toString().padLeft(2, '0')} ${widget.nextRetakeTime.hour.toString().padLeft(2, '0')}:${widget.nextRetakeTime.minute.toString().padLeft(2, '0')}';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FF),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 40,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Animated Icon
                        AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Opacity(
                                opacity: _fadeAnimation.value,
                                child: Container(
                                  padding: const EdgeInsets.all(40),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        _errorRed.withOpacity(0.2),
                                        _errorRed.withOpacity(0.05),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.4, 0.7, 1.0],
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(28),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: _errorRed.withOpacity(0.15),
                                          blurRadius: 30,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.lock_clock_rounded,
                                      size: 80,
                                      color: _errorRed,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'ذاكر وتعالى تاني! 📚',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: _darkText,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لم تحقق النتيجة المطلوبة في الامتحان السابق. يرجى مراجعة دروسك والاستعداد جيداً للإعادة.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        // Glassmorphism Timer Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: _darkText.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'الوقت المتبقي للإعادة',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _formatDuration(_remaining),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: _errorRed,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 12),
                              Divider(color: Colors.grey[200]),
                              const SizedBox(height: 12),
                              Text(
                                'متاح يوم: $formattedTime',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Exit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: widget.onExit,
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'تراجع (العودة إلى السابقة)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 5,
                              shadowColor: _primaryBlue.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
