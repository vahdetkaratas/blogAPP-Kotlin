import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../storage/token_storage.dart';
import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/posts/data/posts_repository.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDI() async {
  // Core services
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  );
  
  // Token storage
  final tokenStorage = TokenStorage(
    sharedPreferences: getIt<SharedPreferences>(),
    secureStorage: getIt<FlutterSecureStorage>(),
  );
  await tokenStorage.init();
  getIt.registerSingleton<TokenStorage>(tokenStorage);
  
  // Register Dio client
  getIt.registerLazySingleton<Dio>(() => DioClient.buildDio());

  // Repositories
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepository(getIt<Dio>(), getIt<TokenStorage>()),
  );

  getIt.registerLazySingleton<IPostsRepository>(
    () => PostsRepository(dio: getIt<Dio>()),
  );

  // Add auth interceptor to Dio after all dependencies are ready
  _addAuthInterceptor();
}

void _addAuthInterceptor() {
  final dio = getIt<Dio>();
  final authRepository = getIt<IAuthRepository>();
  final tokenStorage = getIt<TokenStorage>();
  
  dio.interceptors.add(AuthInterceptor(dio, tokenStorage, authRepository));
}
