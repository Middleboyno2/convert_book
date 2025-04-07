import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailPasswordUseCase implements UseCase<UserEntity, SignInWithEmailPasswordParams> {
  final AuthRepository repository;

  SignInWithEmailPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInWithEmailPasswordParams params) async {
    return await repository.signInWithEmailAndPassword(
      params.email,
      params.password,
    );
  }
}

class SignInWithEmailPasswordParams extends Equatable {
  final String email;
  final String password;

  const SignInWithEmailPasswordParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}