import 'package:go_router/go_router.dart';
import '../views/auth/login_page.dart';
import '../views/auth/signup_page.dart';
import '../views/home/home_page.dart';
import '../views/vault/credential_page.dart'; // Adjust if renamed
import '../views/settings/settings_page.dart';
import '../views/splash/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash', // Set splash as the initial route
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/vault',
      builder: (context, state) => const CredentialPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
