import 'package:dio/dio.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/error/failures.dart';
import 'models/login_request.dart';
import 'models/signup_request.dart';
import 'models/auth_response.dart';

abstract class IAuthRepository {
  Future<void> signup({required String email, required String password, required String firstname, required String lastname});
  Future<void> login({required String email, required String password});
  Future<void> refreshToken();
  Future<void> logout();
  bool isAuthenticated();
}

class AuthRepository implements IAuthRepository {
  final Dio _dio;
  final TokenStorage _storage;
  AuthRepository(this._dio, this._storage);

  @override
  Future<void> signup({required String email, required String password, required String firstname, required String lastname}) async {
    try {
      final request = SignupRequest(
        email: email,
        password: password,
        firstname: firstname,
        lastname: lastname,
      );
      final response = await _dio.post(
        ApiPaths.signup,
        data: request.toJson(),
        options: Options(extra: const {'requiresAuth': false}),
      );
      final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      await _storage.setTokens(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      );
    } on DioException catch (e) {
      throw ErrorMapper.mapDioException(e);
    }
  }

  @override
  Future<void> login({required String email, required String password}) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _dio.post(
        ApiPaths.login,
        data: request.toJson(),
        options: Options(extra: const {'requiresAuth': false}),
      );
      final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      await _storage.setTokens(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      );
    } on DioException catch (e) {
      throw ErrorMapper.mapDioException(e);
    }
  }

  @override
  Future<void> refreshToken() async {
    try {
      final refresh = _storage.getRefreshToken();
      if (refresh == null || refresh.isEmpty) {
        throw StateError('No refresh token available');
      }
      final response = await _dio.post(
        ApiPaths.refresh,
        data: <String, dynamic>{'token': refresh},
        options: Options(extra: const {'requiresAuth': false}),
      );
      final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      await _storage.setTokens(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      );
    } on DioException catch (e) {
      throw ErrorMapper.mapDioException(e);
    }
  }

  @override
  Future<void> logout() async {
    await _storage.clear();
  }

  @override
  bool isAuthenticated() => _storage.getAccessToken() != null;
}
