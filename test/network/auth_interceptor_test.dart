import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:thinkeasy_mini/core/network/interceptors/auth_interceptor.dart';
import 'package:thinkeasy_mini/core/storage/token_storage.dart';
import 'package:thinkeasy_mini/features/auth/data/auth_repository.dart';

class MockDio extends Mock implements Dio {}

class MockTokenStorage extends Mock implements TokenStorage {}

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/test'));
    registerFallbackValue(Response(requestOptions: RequestOptions(path: '/test')));
  });

  group('AuthInterceptor', () {
    late MockDio mockDio;
    late MockTokenStorage mockTokenStorage;
    late MockAuthRepository mockAuthRepository;
    late AuthInterceptor authInterceptor;

    setUp(() {
      mockDio = MockDio();
      mockTokenStorage = MockTokenStorage();
      mockAuthRepository = MockAuthRepository();
      authInterceptor = AuthInterceptor(
        mockDio,
        mockTokenStorage,
        mockAuthRepository,
      );
    });

    tearDown(() {
      reset(mockDio);
      reset(mockTokenStorage);
      reset(mockAuthRepository);
    });

    test('injects Authorization header when token exists', () {
      // Arrange
      const token = 'test_access_token';
      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();

      when(() => mockTokenStorage.getAccessToken()).thenReturn(token);

      // Act
      authInterceptor.onRequest(options, handler);

      // Assert
      expect(options.headers['Authorization'], equals('Bearer $token'));
      verify(() => handler.next(options)).called(1);
      verify(() => mockTokenStorage.getAccessToken()).called(1);
    });

    test('on 401 refreshes once and retries', () async {
      // Arrange
      const oldToken = 'old_token';
      const newToken = 'new_token';
      
      final options = RequestOptions(
        path: '/test',
        headers: {'Authorization': 'Bearer $oldToken'},
      );
      
      final dioException = DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 401,
        ),
      );
      
      final handler = MockErrorInterceptorHandler();
      final successResponse = Response(
        requestOptions: options,
        statusCode: 200,
        data: {'success': true},
      );

      when(() => mockTokenStorage.getAccessToken()).thenReturn(newToken);
      when(() => mockAuthRepository.refreshToken()).thenAnswer((_) async {});
      when(() => mockDio.fetch(any())).thenAnswer((_) async => successResponse);

      // Act
      await authInterceptor.onError(dioException, handler);

      // Assert
      verify(() => mockAuthRepository.refreshToken()).called(1);
      verify(() => handler.resolve(successResponse)).called(1);
      
      final capturedOptions = verify(() => mockDio.fetch(captureAny())).captured.first as RequestOptions;
      expect(capturedOptions.headers['Authorization'], equals('Bearer $newToken'));
      expect(capturedOptions.extra['retried'], equals(true));
    });

    test('if already refreshing -> logout and error', () async {
      // Arrange
      const token = 'expired_token';
      
      final options1 = RequestOptions(
        path: '/test1',
        headers: {'Authorization': 'Bearer $token'},
      );
      
      final options2 = RequestOptions(
        path: '/test2',
        headers: {'Authorization': 'Bearer $token'},
      );
      
      final dioException1 = DioException(
        requestOptions: options1,
        response: Response(
          requestOptions: options1,
          statusCode: 401,
        ),
      );
      
      final dioException2 = DioException(
        requestOptions: options2,
        response: Response(
          requestOptions: options2,
          statusCode: 401,
        ),
      );
      
      final handler1 = MockErrorInterceptorHandler();
      final handler2 = MockErrorInterceptorHandler();

      when(() => mockTokenStorage.getAccessToken()).thenReturn('new_token');
      when(() => mockAuthRepository.refreshToken()).thenAnswer((_) async {});
      when(() => mockAuthRepository.logout()).thenAnswer((_) async {});

      // Act - Trigger both errors concurrently
      final future1 = authInterceptor.onError(dioException1, handler1);
      final future2 = authInterceptor.onError(dioException2, handler2);
      
      await Future.wait([future1, future2]);

      // Assert - refreshToken called once, logout called at least once
      verify(() => mockAuthRepository.refreshToken()).called(1);
      verify(() => mockAuthRepository.logout()).called(greaterThan(0));
      verify(() => handler1.next(dioException1)).called(1);
      verify(() => handler2.next(dioException2)).called(1);
    });
  });
}
