import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dentconnect_app/features/auth/screens/splash_screen.dart';
import 'package:dentconnect_app/features/auth/screens/login_screen.dart';
import 'package:dentconnect_app/features/auth/screens/register_screen.dart';
import 'package:dentconnect_app/features/auth/screens/role_selection_screen.dart';
import 'package:dentconnect_app/features/auth/screens/otp_screen.dart';

// Route constants
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const roleSelection = '/role-selection';
  static const otp = '/otp';

  // Dentist routes
  static const dentistHome = '/dentist';
  static const dentistProfile = '/dentist/profile';
  static const editDentistProfile = '/dentist/profile/edit';

  // Clinic routes
  static const clinicHome = '/clinic';
  static const clinicProfile = '/clinic/profile';
  static const editClinicProfile = '/clinic/profile/edit';

  // Job routes
  static const jobs = '/jobs';
  static const jobDetail = '/jobs/:id';
  static const createJob = '/jobs/create';
  static const myJobs = '/my-jobs';
  static const savedJobs = '/saved-jobs';

  // Application routes
  static const myApplications = '/applications';
  static const applicationDetail = '/applications/:id';

  // Notifications
  static const notifications = '/notifications';

  // Settings
  static const settings = '/settings';
}

/// GoRouter provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Auth routes
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'DENTIST';
          return LoginScreen(role: role);
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'DENTIST';
          return RegisterScreen(role: role);
        },
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        name: 'roleSelection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        name: 'otp',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'DENTIST';
          return OtpScreen(role: role);
        },
      ),

      // Dentist Shell
      ShellRoute(
        builder: (context, state, child) => _BottomNavShell(
          currentPath: state.uri.toString(),
          role: 'dentist',
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.dentistHome,
            name: 'dentistHome',
            builder: (context, state) => const _PlaceholderScreen(title: 'Home'),
          ),
          GoRoute(
            path: AppRoutes.jobs,
            name: 'jobs',
            builder: (context, state) => const _PlaceholderScreen(title: 'Jobs'),
          ),
          GoRoute(
            path: AppRoutes.myApplications,
            name: 'myApplications',
            builder: (context, state) => const _PlaceholderScreen(title: 'Applications'),
          ),
          GoRoute(
            path: AppRoutes.dentistProfile,
            name: 'dentistProfile',
            builder: (context, state) => const _PlaceholderScreen(title: 'Profile'),
          ),
        ],
      ),

      // Clinic Shell
      ShellRoute(
        builder: (context, state, child) => _BottomNavShell(
          currentPath: state.uri.toString(),
          role: 'clinic',
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.clinicHome,
            name: 'clinicHome',
            builder: (context, state) => const _PlaceholderScreen(title: 'Dashboard'),
          ),
          GoRoute(
            path: AppRoutes.myJobs,
            name: 'myJobs',
            builder: (context, state) => const _PlaceholderScreen(title: 'My Jobs'),
          ),
          GoRoute(
            path: AppRoutes.clinicProfile,
            name: 'clinicProfile',
            builder: (context, state) => const _PlaceholderScreen(title: 'Clinic Profile'),
          ),
        ],
      ),

      // Standalone routes
      GoRoute(
        path: AppRoutes.jobDetail,
        name: 'jobDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _PlaceholderScreen(title: 'Job: $id');
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const _PlaceholderScreen(title: 'Notifications'),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const _PlaceholderScreen(title: 'Settings'),
      ),
    ],
  );
});

// ── Placeholder Screen (will be replaced by real screens) ──
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

// ── Bottom Navigation Shell ──
class _BottomNavShell extends StatelessWidget {
  final String currentPath;
  final String role;
  final Widget child;

  const _BottomNavShell({
    required this.currentPath,
    required this.role,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDentist = role == 'dentist';

    final destinations = isDentist
        ? const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Jobs'),
            NavigationDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description), label: 'Applied'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ]
        : const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'My Jobs'),
            NavigationDestination(icon: Icon(Icons.business_outlined), selectedIcon: Icon(Icons.business), label: 'Clinic'),
          ];

    int selectedIndex = 0;
    if (isDentist) {
      if (currentPath.startsWith('/jobs')) selectedIndex = 1;
      if (currentPath.startsWith('/applications')) selectedIndex = 2;
      if (currentPath.startsWith('/dentist/profile')) selectedIndex = 3;
    } else {
      if (currentPath.startsWith('/my-jobs')) selectedIndex = 1;
      if (currentPath.startsWith('/clinic/profile')) selectedIndex = 2;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        destinations: destinations,
        onDestinationSelected: (index) {
          if (isDentist) {
            switch (index) {
              case 0: context.go(AppRoutes.dentistHome);
              case 1: context.go(AppRoutes.jobs);
              case 2: context.go(AppRoutes.myApplications);
              case 3: context.go(AppRoutes.dentistProfile);
            }
          } else {
            switch (index) {
              case 0: context.go(AppRoutes.clinicHome);
              case 1: context.go(AppRoutes.myJobs);
              case 2: context.go(AppRoutes.clinicProfile);
            }
          }
        },
      ),
    );
  }
}
