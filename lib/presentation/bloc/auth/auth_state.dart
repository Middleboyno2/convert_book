import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable{

  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthEmailPassLoading extends AuthState {}

class AuthGoogleLoading extends AuthState {}

class AuthAppleLoading extends AuthState {}

class AuthSendEmailLoading extends AuthState {}

class AuthSignOutLoading extends AuthState {}

class UploadLoading extends AuthState{}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);
  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailureState extends AuthState {
  final Failure failure;

  const AuthFailureState(this.failure);

  @override
  List<Object> get props => [failure];
}

class UploadImageCompleted extends AuthState{}

class UploadProfileImageError extends AuthState{
  final Failure failure;

  const UploadProfileImageError(this.failure);

  @override
  List<Object> get props => [failure];
}

class AuthPasswordResetEmailSent extends AuthState {
  final String email;

  const AuthPasswordResetEmailSent(this.email);

  @override
  List<Object> get props => [email];
}
