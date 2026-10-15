import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/iwash/iwash_screen.dart';
import 'features/iwash/repositories/iwash_repository.dart';

import 'screens/car_wash_detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'features/profile/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/welcome_screen.dart';

import 'widgets/app_shell.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',

  errorBuilder: (context, state) {
    return Scaffold(
      body: Center(
        child: Text(
          'Page not found\n${state.uri}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  },

  routes: [
    // --------------------------------------------------
    // AUTH / SCREENS WITHOUT BOTTOM NAVIGATION
    // --------------------------------------------------

    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),

    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),

    // --------------------------------------------------
    // MAIN APPLICATION
    // --------------------------------------------------
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },

      branches: [
        // HOME
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => HomeScreen(
                onSearchTap: () {
                  context.go('/search');
                },
              ),
            ),
          ],
        ),

        // SEARCH
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),

              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final idString = state.pathParameters['id'];

                    final id = int.tryParse(idString ?? '');

                    if (id == null) {
                      return const Scaffold(
                        body: Center(child: Text('Invalid car wash id')),
                      );
                    }

                    return CarWashDetailScreen(id: id);
                  },

                  routes: [
                    GoRoute(
                      path: 'map',
                      builder: (context, state) {
                        final idString = state.pathParameters['id'];

                        final id = int.tryParse(idString ?? '');

                        if (id != 3) {
                          return const Scaffold(
                            body: Center(
                              child: Text('Map is not available for this wash'),
                            ),
                          );
                        }

                        const repository = IWashRepository();

                        return IWashScreen(state: repository.getCurrentState());
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // PROFILE
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
