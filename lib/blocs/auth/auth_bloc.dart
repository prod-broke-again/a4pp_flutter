import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:achpp/models/user.dart';
import 'package:achpp/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckTokenRequested>(_onCheckTokenRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadInProgress());
    try {
      final response = await _authRepository.login(event.email, event.password);
      emit(AuthLoadSuccess(user: response['user'] as User));
    } catch (e) {
      emit(AuthLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadInProgress());
    try {
      final response = await _authRepository.register(
        firstname: event.firstname,
        lastname: event.lastname,
        email: event.email,
        password: event.password,
        passwordConfirmation: event.password,
        phone: event.phone,
      );
      emit(AuthLoadSuccess(user: response['user'] as User));
    } catch (e) {
      emit(AuthLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadInProgress());
    try {
      await _authRepository.logout();
      emit(AuthInitial());
    } catch (e) {
      // Даже если выход на сервере не удался, выходим локально
      emit(AuthInitial());
    }
  }

  Future<void> _onCheckTokenRequested(
    AuthCheckTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    final hasToken = await _authRepository.hasToken();
    if (!hasToken) {
      emit(AuthInitial());
      return;
    }

    try {
      final profile = await _authRepository.getProfile();
      emit(AuthTokenValid(user: profile.user));
    } catch (e) {
      emit(AuthInitial());
    }
  }
}
