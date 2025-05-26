import 'package:go_router/go_router.dart';
import '../views/auth/login_page.dart';
import '../views/auth/signup_page.dart';
import '../views/home/home_page.dart';
import '../views/vault/credential_page.dart'; // Adjust if renamed
// import '../views/settings/settings_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login', // or dynamic logic
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(path: '/vault', builder: (context, state) => const CredentialPage()),
    // GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
  ],
);
