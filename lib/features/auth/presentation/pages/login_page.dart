import 'package:alaref/core/Router/export_routes.dart';
import 'package:alaref/core/Router/routes.dart';
import 'package:alaref/core/utils/helper/extensions.dart';
import 'package:alaref/features/auth/presentation/cubit/cubit/auth_cubit.dart';

import '../widgets/auth_footer.dart';
import '../widgets/auth_social_buttons.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/shared_form_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const _primary = Color(0xFF0D9488);
  static const _inputBg = Color(0xFFF1F5F9);
  static const _sheetBg = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            if (state.user.email == 'admin@admin.com') {
              context.pushNamed(Routes.adminDashboard);
            } else {
              context.pushNamed(Routes.bottomNavBar);
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final authCubit = context.read<AuthCubit>();
          return CustomScrollView(
            slivers: [
              // ─── هيرو: تدرج + موجة سفلي ───
              SliverToBoxAdapter(
                child: _LoginHero(),
              ),
              // ─── شيت النموذج (أبيض، يعلو الهيرو) ───
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -32),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: _sheetBg,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 24,
                          offset: Offset(0, -8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                      child: Form(
                        key: authCubit.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _AuthInput(
                              label: 'البريد الإلكتروني',
                              hint: 'example@email.com',
                              keyboardType: TextInputType.emailAddress,
                              controller: authCubit.emailController,
                            ),
                            const SizedBox(height: 16),
                            AuthPasswordField(
                              labelText: 'كلمة المرور',
                              hintText: 'كلمة المرور',
                              controller: authCubit.passwordController,
                              fillColor: _inputBg,
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(14)),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(14)),
                                borderSide: BorderSide(color: _primary, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'نسيت كلمة المرور؟',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _PrimaryButton(
                              label: state is AuthLoading
                                  ? 'جاري الدخول...'
                                  : 'تسجيل الدخول',
                              onPressed: state is AuthLoading
                                  ? null
                                  : () => authCubit.login(),
                              loading: state is AuthLoading,
                            ),
                            const SizedBox(height: 28),
                            const AuthDivider(text: 'أو تابع باستخدام'),
                            const SizedBox(height: 20),
                            const AuthSocialButtons(),
                            const SizedBox(height: 28),
                            AuthFooter(
                              leadingText: 'ليس لديك حساب؟ ',
                              actionText: 'إنشاء حساب',
                              onActionTap: () =>
                                  context.pushNamed(Routes.registerPage),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// هيرو: تدرج لوني + موجة سفلي + لوجو وعنوان
class _LoginHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 24,
          right: 24,
          bottom: 48,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF0D9488),
              Color(0xFF0F766E),
              Color(0xFF134E4A),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'العارف',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            const Text(
              'مرحباً بعودتك',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سجّل دخولك لمتابعة المحاضرات والامتحانات',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            // زخرفة بسيطة: دوائر
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _Dot(radius: 6),
                const SizedBox(width: 12),
                _Dot(radius: 10),
                const SizedBox(width: 8),
                _Dot(radius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final double radius;

  const _Dot({required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.25),
      ),
    );
  }
}

/// قص الموجة السفلية للهيرو
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height - 32);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 24,
      size.width,
      size.height - 32,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// حقل إدخال بتصميم الشيت (خلفية رمادية فاتحة، بدون إطار ظاهر)
class _AuthInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  const _AuthInput({
    required this.label,
    required this.hint,
    this.keyboardType,
    this.controller,
  });

  static const _fill = Color(0xFFF1F5F9);
  static const _primary = Color(0xFF0D9488);

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide.none,
    );
    const focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: _primary, width: 2),
    );

    return SharedFormField(
      labelText: label,
      hintText: hint,
      keyboardType: keyboardType,
      controller: controller,
      fillColor: _fill,
      enabledBorder: border,
      focusedBorder: focusedBorder,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    );
  }
}

/// زر أساسي: عرض كامل، زوايا دائرية، تدرج
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const _PrimaryButton({
    required this.label,
    this.onPressed,
    this.loading = false,
  });

  static const _primary = Color(0xFF0D9488);
  static const _primaryDark = Color(0xFF0F766E);
  static const _inputBg = Color(0xFFF1F5F9);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: onPressed != null && !loading
              ? const LinearGradient(
                  colors: [_primary, _primaryDark],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: loading ? _inputBg : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: loading ? null : onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(_primary),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 22,
                          textDirection: TextDirection.ltr,
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
