import 'package:alaref/core/Router/export_routes.dart';
import 'package:alaref/core/Router/routes.dart';
import 'package:alaref/core/utils/helper/extensions.dart';
import 'package:alaref/features/auth/presentation/cubit/cubit/auth_cubit.dart';

import '../widgets/auth_header.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_social_buttons.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/shared_button.dart';
import '../widgets/shared_form_field.dart';
import '../widgets/stage_dropdown.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = EdgeInsets.symmetric(horizontal: 24);
    final authCubit = context.read<AuthCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.pushNamed(Routes.homeScreen);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Form(
            key: authCubit.formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const AuthHeader(
                    title: 'أنشاء\nحساب جديد',
                    subtitle:
                        'انضم إلينا الآن وابدأ رحلتك التعليمية الممتعة مع أفضل المعلمين',
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: horizontalPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _AuthBrand(),
                        const SizedBox(height: 24),
                        SharedFormField(
                          labelText: 'الاسم بالكامل',
                          hintText: 'أدخل اسمك بالكامل',
                          keyboardType: TextInputType.name,
                          controller: authCubit.nameController,
                        ),
                        const SizedBox(height: 16),
                        SharedFormField(
                          labelText: 'البريد الإلكتروني',
                          hintText: 'أدخل بريدك الإلكتروني',
                          keyboardType: TextInputType.emailAddress,
                          controller: authCubit.emailController,
                        ),
                        const SizedBox(height: 16),
                        SharedFormField(
                          labelText: 'رقم الهاتف',
                          hintText: 'أدخل رقم هاتفك',
                          keyboardType: TextInputType.phone,
                          controller: authCubit.phoneController,
                        ),
                        const SizedBox(height: 16),
                        SharedFormField(
                          labelText: 'رقم ولي الأمر',
                          hintText: 'أدخل رقم ولي الأمر',
                          keyboardType: TextInputType.phone,
                          controller: authCubit.parentPhoneController,
                        ),
                        const SizedBox(height: 16),
                        StageDropdown(
                          selectedStage: authCubit.selectedStage,
                          onSelected: (stage) {
                            if (stage != null) {
                              authCubit.updateStage(stage);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        AuthPasswordField(
                          labelText: 'كلمة المرور',
                          hintText: 'أدخل كلمة المرور',
                          controller: authCubit.passwordController,
                        ),

                        const SizedBox(height: 24),
                        SharedButton(
                          text: state is AuthLoading
                              ? 'جاري التحميل...'
                              : 'إنشاء الحساب',
                          onPressed: state is AuthLoading
                              ? null
                              : () => authCubit.register(),
                          height: 56,
                          borderRadius: 16,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1363DF), Color(0xFF3FA9F5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const AuthDivider(text: 'أو الاستمرار بواسطة'),
                        const SizedBox(height: 24),
                        const AuthSocialButtons(),
                        const SizedBox(height: 24),
                        AuthFooter(
                          leadingText: 'لديك حساب بالفعل؟ ',
                          actionText: 'تسجيل الدخول',
                          onActionTap: () {
                            context.pushNamed(Routes.loginPage);
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AuthBrand extends StatelessWidget {
  const _AuthBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.widgets_rounded, color: Color(0xFF1363DF), size: 20),
        SizedBox(width: 8),
        Text(
          'etudier',
          style: TextStyle(
            color: Color(0xFF1363DF),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
