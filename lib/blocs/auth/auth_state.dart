part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoadInProgress extends AuthState {}

class AuthLoadSuccess extends AuthState {
  final User user;

  const AuthLoadSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthLoadFailure extends AuthState {
  final String error;

  const AuthLoadFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class AuthTokenValid extends AuthState {
  final User user;

  const AuthTokenValid({required this.user});

  @override
  List<Object> get props => [user];
}
