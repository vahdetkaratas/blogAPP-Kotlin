import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:thinkeasy_mini/features/auth/data/auth_repository.dart';
import 'package:thinkeasy_mini/features/auth/presentation/bloc/auth_bloc.dart' as auth_bloc;
import 'package:thinkeasy_mini/core/error/failures.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  group('AuthBloc', () {
    late MockAuthRepository mockAuthRepository;
    late auth_bloc.AuthBloc authBloc;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      authBloc = auth_bloc.AuthBloc(mockAuthRepository);
    });

    tearDown(() {
      authBloc.close();
    });

    group('AuthLoginRequested', () {
      const email = 'test@example.com';
      const password = 'password123';

      blocTest<auth_bloc.AuthBloc, auth_bloc.AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when login succeeds',
        build: () {
          when(() => mockAuthRepository.login(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenAnswer((_) async {});
          return authBloc;
        },
        act: (bloc) => bloc.add(auth_bloc.AuthLoginRequested(
          email: email,
          password: password,
        )),
        expect: () => [
          isA<auth_bloc.AuthLoading>(),
          isA<auth_bloc.AuthAuthenticated>(),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.login(
                email: email,
                password: password,
              )).called(1);
        },
      );

      blocTest<auth_bloc.AuthBloc, auth_bloc.AuthState>(
        'emits [AuthLoading, AuthFailure] when login fails',
        build: () {
          when(() => mockAuthRepository.login(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenThrow(const AppException('Invalid credentials'));
          return authBloc;
        },
        act: (bloc) => bloc.add(auth_bloc.AuthLoginRequested(
          email: email,
          password: password,
        )),
        expect: () => [
          isA<auth_bloc.AuthLoading>(),
          isA<auth_bloc.AuthFailure>(),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.login(
                email: email,
                password: password,
              )).called(1);
        },
      );
    });

    group('AuthLogoutRequested', () {
      blocTest<auth_bloc.AuthBloc, auth_bloc.AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when logout succeeds',
        build: () {
          when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
          return authBloc;
        },
        act: (bloc) => bloc.add(auth_bloc.AuthLogoutRequested()),
        expect: () => [
          isA<auth_bloc.AuthLoading>(),
          isA<auth_bloc.AuthUnauthenticated>(),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.logout()).called(1);
        },
      );
    });
  });
}
