import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injector.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/posts/presentation/bloc/post_list_bloc.dart';
import 'features/posts/presentation/cubit/post_create_cubit.dart';
import 'features/posts/data/posts_repository.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(getIt<IAuthRepository>()),
        ),
        BlocProvider<PostListBloc>(
          create: (context) => PostListBloc(getIt<IPostsRepository>()),
        ),
        BlocProvider<PostCreateCubit>(
          create: (context) => PostCreateCubit(getIt<IPostsRepository>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'ThinkEasy Mini',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3), // Material Blue
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
