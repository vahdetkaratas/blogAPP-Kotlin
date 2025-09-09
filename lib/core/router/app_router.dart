import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../storage/token_storage.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/posts/presentation/pages/posts_page.dart';
import '../../features/posts/presentation/pages/post_create_page.dart';
import '../../features/posts/presentation/pages/post_detail_page.dart';

class AppRouter {
  static final _getIt = GetIt.instance;
  
  static GoRouter get router => _router;
  
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    redirect: _authRedirect,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const PostsPage(),
      ),
      GoRoute(
        path: '/create',
        builder: (context, state) => const PostCreatePage(),
      ),
      GoRoute(
        path: '/user/:id',
        builder: (context, state) {
          final userId = state.pathParameters['id'];
          return PostsPage(userId: userId);
        },
      ),
      GoRoute(
        path: '/post/:id',
        builder: (context, state) {
          final postId = state.pathParameters['id'];
          if (postId == null) {
            return const Scaffold(
              body: Center(
                child: Text('Post ID not found'),
              ),
            );
          }
          return PostDetailPage(postId: postId);
        },
      ),
    ],
  );

  static String? _authRedirect(BuildContext context, GoRouterState state) {
    try {
      final tokenStorage = _getIt<TokenStorage>();
      final hasToken = tokenStorage.hasTokenSync();
      final isLoginRoute = state.matchedLocation == '/login';

      // If no token and not on login page, redirect to login
      if (!hasToken && !isLoginRoute) {
        return '/login';
      }

      // If has token and on login page, redirect to home
      if (hasToken && isLoginRoute) {
        return '/';
      }

      // No redirect needed
      return null;
    } catch (e) {
      // If dependency injection is not ready, redirect to login
      return '/login';
    }
  }
}
