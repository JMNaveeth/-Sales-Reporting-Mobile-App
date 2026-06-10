import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/login/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/customers/customers_screen.dart';
import '../screens/reports/reports_screen.dart';

// ── Route Names ──────────────────────────────────────────────────────────────

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String customers = '/customers';
  static const String reports = '/reports';
}

// ── Router Provider ──────────────────────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  // Listenable that triggers router re-evaluation on auth state changes
  final authNotifier = _AuthListenable(ref);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState is AuthAuthenticated;
      final isInitializing = authState is AuthInitial;
      final isOnLoginPage = state.matchedLocation == AppRoutes.login;

      // Still initializing — don't redirect yet
      if (isInitializing) return null;

      // Not authenticated and not on login → send to login
      if (!isAuthenticated && !isOnLoginPage) return AppRoutes.login;

      // Authenticated and on login → send to dashboard
      if (isAuthenticated && isOnLoginPage) return AppRoutes.dashboard;

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Shell route wraps dashboard, customers, and reports with the
      // bottom nav bar so it persists across tab switches
      ShellRoute(
        builder: (context, state, child) {
          return _MainShell(child: child, state: state);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.customers,
            name: 'customers',
            builder: (context, state) => const CustomersScreen(),
          ),
          GoRoute(
            path: AppRoutes.reports,
            name: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});

// ── Auth Listenable (bridge between Riverpod & GoRouter) ────────────────────

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

// ── Main Shell (Bottom Nav Bar) ──────────────────────────────────────────────

class _MainShell extends StatelessWidget {
  const _MainShell({required this.child, required this.state});

  final Widget child;
  final GoRouterState state;

  int _currentIndex(String location) {
    if (location.startsWith(AppRoutes.dashboard)) return 0;
    if (location.startsWith(AppRoutes.customers)) return 1;
    if (location.startsWith(AppRoutes.reports)) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(state.matchedLocation);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go(AppRoutes.dashboard);
            case 1:
              context.go(AppRoutes.customers);
            case 2:
              context.go(AppRoutes.reports);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
