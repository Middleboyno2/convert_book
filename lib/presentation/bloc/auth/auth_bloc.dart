import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../../core/usecase/usecase.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/get_current_user_usecase.dart';
import '../../../domain/usecases/send_password_reset_email_usecase.dart';
import '../../../domain/usecases/sign_in_with_apple_usecase.dart';
import '../../../domain/usecases/sign_in_with_email_password_usecase.dart';
import '../../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../../domain/usecases/sign_out_usecase.dart';
import '../../../domain/usecases/sign_up_with_email_password_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUserUseCase getCurrentUser;
  final SignInWithEmailPasswordUseCase signInWithEmailPassword;
  final SignUpWithEmailPasswordUseCase signUpWithEmailPassword;
  final SignInWithGoogleUseCase signInWithGoogle;
  final SignInWithAppleUseCase signInWithApple;
  final SignOutUseCase signOut;
  final SendPasswordResetEmailUseCase sendPasswordResetEmail;
  final AuthRepository authRepository;

  StreamSubscription<UserEntity?>? _authStateSubscription;

  AuthBloc({
    required this.getCurrentUser,
    required this.signInWithEmailPassword,
    required this.signUpWithEmailPassword,
    required this.signInWithGoogle,
    required this.signInWithApple,
    required this.signOut,
    required this.sendPasswordResetEmail,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInWithEmailPasswordRequested>(_onAuthSignInWithEmailPasswordRequested);
    on<AuthSignUpWithEmailPasswordRequested>(_onAuthSignUpWithEmailPasswordRequested);
    on<AuthSignInWithGoogleRequested>(_onAuthSignInWithGoogleRequested);
    on<AuthSignInWithAppleRequested>(_onAuthSignInWithAppleRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthSendPasswordResetEmailRequested>(_onAuthSendPasswordResetEmailRequested);

    // Lắng nghe sự thay đổi trạng thái xác thực từ Firebase
    _authStateSubscription = authRepository.authStateChanges.listen((user) {
      if (user != null) {
        add(AuthCheckRequested());
      }
    });
  }

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event,
      Emitter<AuthState> emit
      ) async {
    emit(AuthLoading());
    final result = await getCurrentUser(NoParams());
    result.fold(
          (failure) => emit(AuthUnauthenticated()),
          (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAuthSignInWithEmailPasswordRequested(
      AuthSignInWithEmailPasswordRequested event,
      Emitter<AuthState> emit
      ) async {
    emit(AuthEmailPassLoading());

    final result = await signInWithEmailPassword(
      SignInWithEmailPasswordParams(
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
          (failure) => emit(AuthFailureState(failure)),
          (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAuthSignUpWithEmailPasswordRequested(
      AuthSignUpWithEmailPasswordRequested event,
      Emitter<AuthState> emit
      ) async {
    emit(AuthEmailPassLoading());

    final result = await signUpWithEmailPassword(
      SignUpWithEmailPasswordParams(
        email: event.email,
        password: event.password,
        name: event.name,
        phone: event.phone,
      ),
    );

    result.fold(
          (failure) => emit(AuthFailureState(failure)),
          (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAuthSignInWithGoogleRequested(
      AuthSignInWithGoogleRequested event,
      Emitter<AuthState> emit
      ) async {
    emit(AuthGoogleLoading());

    final result = await signInWithGoogle(NoParams());

    result.fold(
          (failure) => emit(AuthFailureState(failure)),
          (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAuthSignInWithAppleRequested(
      AuthSignInWithAppleRequested event,
      Emitter<AuthState> emit
      ) async {
    emit(AuthAppleLoading());

    final result = await signInWithApple(NoParams());

    result.fold(
          (failure) => emit(AuthFailureState(failure)),
          (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAuthSignOutRequested(
      AuthSignOutRequested event,
      Emitter<AuthState> emit
      ) async {
    emit(AuthSignOutLoading());

    final result = await signOut(NoParams());

    result.fold(
          (failure) => emit(AuthFailureState(failure)),
          (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onAuthSendPasswordResetEmailRequested(
      AuthSendPasswordResetEmailRequested event,
      Emitter<AuthState> emit
      ) async {
    emit(AuthSendEmailLoading());

    final result = await sendPasswordResetEmail(
      SendPasswordResetEmailParams(email: event.email),
    );

    result.fold(
          (failure) => emit(AuthFailureState(failure)),
          (_) => emit(AuthPasswordResetEmailSent(event.email)),
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
