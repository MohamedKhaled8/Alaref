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
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case Routes.loginPage:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                AuthCubit(loginUseCase: sl(), registerUseCase: sl()),
            child: const LoginPage(),
          ),
        );
      case Routes.registerPage:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                AuthCubit(loginUseCase: sl(), registerUseCase: sl()),
            child: const RegisterPage(),
          ),
        );
      case Routes.bottomNavBar:
        return MaterialPageRoute(builder: (_) => const BottomNavBar());
      case Routes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardPage());
      case Routes.packagesScreen:
        return MaterialPageRoute(builder: (_) => const PackagesScreen());
      case Routes.examsScreen:
        return MaterialPageRoute(builder: (_) => const ExamsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("No route defined"))),
        );
    }
  }
}
