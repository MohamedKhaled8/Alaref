import 'package:alaref/core/Router/export_routes.dart';
import 'package:alaref/core/Router/routes.dart';
import 'package:alaref/core/utils/helper/extensions.dart';
import 'package:alaref/features/auth/presentation/cubit/cubit/auth_cubit.dart';

import '../widgets/auth_footer.dart';
import '../widgets/auth_social_buttons.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/shared_form_field.dart';
import '../widgets/stage_dropdown.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static const _primary = Color(0xFF059669);
  static const _inputBg = Color(0xFFF1F5F9);
  static const _sheetBg = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.pushNamed(Routes.bottomNavBar);
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
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _RegisterHero(),
              ),
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
                              label: 'الاسم بالكامل',
                              hint: 'كما في المدرسة',
                              keyboardType: TextInputType.name,
                              controller: authCubit.nameController,
                            ),
                            const SizedBox(height: 16),
                            _AuthInput(
                              label: 'البريد الإلكتروني',
                              hint: 'example@email.com',
                              keyboardType: TextInputType.emailAddress,
                              controller: authCubit.emailController,
                            ),
                            const SizedBox(height: 16),
                            _AuthInput(
                              label: 'رقم الهاتف',
                              hint: 'رقمك الشخصي',
                              keyboardType: TextInputType.phone,
                              controller: authCubit.phoneController,
                            ),
                            const SizedBox(height: 16),
                            _AuthInput(
                              label: 'رقم ولي الأمر',
                              hint: 'رقم ولي الأمر',
                              keyboardType: TextInputType.phone,
                              controller: authCubit.parentPhoneController,
                            ),
                            const SizedBox(height: 16),
                            StageDropdown(
                              selectedStage: authCubit.selectedStage,
                              onSelected: (stage) {
                                if (stage != null) authCubit.updateStage(stage);
                              },
                            ),
                            const SizedBox(height: 16),
                            AuthPasswordField(
                              labelText: 'كلمة المرور',
                              hintText: 'كلمة مرور قوية',
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
                            const SizedBox(height: 24),
                            _RegisterButton(
                              label: state is AuthLoading
                                  ? 'جاري إنشاء الحساب...'
                                  : 'إنشاء حساب',
                              onPressed: state is AuthLoading
                                  ? null
                                  : () => authCubit.register(),
                              loading: state is AuthLoading,
                            ),
                            const SizedBox(height: 28),
                            const AuthDivider(text: 'أو تابع باستخدام'),
                            const SizedBox(height: 20),
                            const AuthSocialButtons(),
                            const SizedBox(height: 28),
                            AuthFooter(
                              leadingText: 'لديك حساب؟ ',
                              actionText: 'تسجيل الدخول',
                              onActionTap: () =>
                                  context.pushNamed(Routes.loginPage),
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

class _RegisterHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _RegisterWaveClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 24,
          right: 24,
          bottom: 40,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF059669),
              Color(0xFF047857),
              Color(0xFF065F46),
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
                    Icons.person_add_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'إنشاء حساب جديد',
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
              'انضم للمنصة وابدأ متابعة دروسك مع أفضل المعلمين',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _RegDot(radius: 5),
                const SizedBox(width: 10),
                _RegDot(radius: 8),
                const SizedBox(width: 6),
                _RegDot(radius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RegDot extends StatelessWidget {
  final double radius;

  const _RegDot({required this.radius});

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

class _RegisterWaveClipper extends CustomClipper<Path> {
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

  static const _inputBg = Color(0xFFF1F5F9);
  static const _primary = Color(0xFF059669);

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
      fillColor: _inputBg,
      enabledBorder: border,
      focusedBorder: focusedBorder,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const _RegisterButton({
    required this.label,
    this.onPressed,
    this.loading = false,
  });

  static const _primary = Color(0xFF059669);
  static const _primaryDark = Color(0xFF047857);
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
