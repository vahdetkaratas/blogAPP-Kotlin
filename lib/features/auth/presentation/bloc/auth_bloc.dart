import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart';
import '../../../../core/error/failures.dart';

// Events
abstract class AuthEvent {}

class AuthSignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstname;
  final String lastname;
  AuthSignupRequested({required this.email, required this.password, required this.firstname, required this.lastname});
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested({required this.email, required this.password});
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckStatusRequested extends AuthEvent {}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _repository;
  AuthBloc(this._repository) : super(AuthInitial()) {
    on<AuthSignupRequested>(_onSignup);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthCheckStatusRequested>(_onCheck);
  }

  Future<void> _onSignup(AuthSignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _repository.signup(
        email: event.email,
        password: event.password,
        firstname: event.firstname,
        lastname: event.lastname,
      );
      emit(AuthAuthenticated());
    } on AppException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('Signup failed: ${e.toString()}'));
    }
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _repository.login(email: event.email, password: event.password);
      emit(AuthAuthenticated());
    } on AppException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('Login failed: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _repository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheck(AuthCheckStatusRequested event, Emitter<AuthState> emit) async {
    final ok = _repository.isAuthenticated();
    emit(ok ? AuthAuthenticated() : AuthUnauthenticated());
  }
}
