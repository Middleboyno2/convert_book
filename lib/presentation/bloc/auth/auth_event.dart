import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable{
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

// dang nhap bang email/password
class AuthSignInWithEmailPasswordRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInWithEmailPasswordRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

// dang ky bang email/password
class AuthSignUpWithEmailPasswordRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String phone;

  const AuthSignUpWithEmailPasswordRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
  });

  @override
  List<Object> get props => [email, password, name, phone];
}

// dang nhap bang google
class AuthSignInWithGoogleRequested extends AuthEvent {}

// dang nhap bang apple id
class AuthSignInWithAppleRequested extends AuthEvent {}

// dang xuat
class AuthSignOutRequested extends AuthEvent {}

// gui email khoi phuc
class AuthSendPasswordResetEmailRequested extends AuthEvent {
  final String email;

  const AuthSendPasswordResetEmailRequested({required this.email});

  @override
  List<Object> get props => [email];
}
