import 'package:dio/dio.dart';
import '../../storage/token_storage.dart';
import '../../../features/auth/data/auth_repository.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  final IAuthRepository _authRepository;

  // Simple flag to prevent concurrent refresh attempts
  bool _isRefreshing = false;

  AuthInterceptor(
    this._dio,
    this._tokenStorage,
    this._authRepository,
  );

  bool _requiresAuth(RequestOptions options) {
    final requires = options.extra['requiresAuth'];
    if (requires is bool) return requires;
    return true; // default true
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_requiresAuth(options)) {
      final token = _tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final options = err.requestOptions;

    // If status != 401 OR requiresAuth == false -> handler.next(err)
    if (statusCode != 401 || !_requiresAuth(options)) {
      return handler.next(err);
    }

    // If options.extra['retried'] == true -> handler.next(err)
    if (options.extra['retried'] == true) {
      return handler.next(err);
    }

    // If _isRefreshing == true: logout and do not queue
    if (_isRefreshing) {
      await _authRepository.logout();
      return handler.next(err);
    }

    // Else: attempt refresh
    _isRefreshing = true;
    try {
      await _authRepository.refreshToken();
      _isRefreshing = false;

      // Set new token and retry flag
      final newToken = _tokenStorage.getAccessToken();
      if (newToken != null && newToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $newToken';
      }
      options.extra['retried'] = true;

      // Retry original request
      final response = await _dio.fetch(options.copyWith(
        method: options.method,
        path: options.path,
        data: options.data,
        queryParameters: options.queryParameters,
        headers: Map<String, dynamic>.from(options.headers),
      ));
      return handler.resolve(response);
    } catch (e) {
      await _authRepository.logout();
      _isRefreshing = false;
      return handler.next(err);
    }
  }
}
