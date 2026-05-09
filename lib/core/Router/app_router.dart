import 'package:alaref/core/Router/export_routes.dart';
import 'package:alaref/core/Router/routes.dart';
import 'package:alaref/core/utils/di/get_it.dart';
import 'package:alaref/features/auth/presentation/cubit/cubit/auth_cubit.dart';
import 'package:alaref/features/auth/presentation/pages/login_page.dart';
import 'package:alaref/features/auth/presentation/pages/register_page.dart';
import 'package:alaref/features/bottom_nav_bar/presentation/pages/main_wrapper.dart';
import 'package:alaref/features/admin/dashBoard/presentation/pages/admin_dashboard_page.dart';
import 'package:alaref/features/packages/presentation/pages/packages_screen.dart';
import 'package:alaref/features/exams/presentation/pages/exams_screen.dart';
import 'package:alaref/features/home/presentation/pages/home_screen.dart';

class AppRouter {
  Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.homeScreen:
        return _buildRoute(const HomeScreen(), settings);
      case Routes.loginPage:
        return _buildRoute(
          BlocProvider(
            create: (context) =>
                AuthCubit(loginUseCase: sl(), registerUseCase: sl()),
            child: const LoginPage(),
          ),
          settings,
        );
      case Routes.registerPage:
        return _buildRoute(
          BlocProvider(
            create: (context) =>
                AuthCubit(loginUseCase: sl(), registerUseCase: sl()),
            child: const RegisterPage(),
          ),
          settings,
        );
      case Routes.bottomNavBar:
        return _buildRoute(const BottomNavBar(), settings);
      case Routes.adminDashboard:
        return _buildRoute(const AdminDashboardPage(), settings);
      case Routes.packagesScreen:
        return _buildRoute(const PackagesScreen(), settings);
      case Routes.examsScreen:
        return _buildRoute(const ExamsScreen(), settings);
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("No route defined"))),
        );
    }
  }

  /// Smooth slide + fade transition for all routes
  PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.15, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
}
