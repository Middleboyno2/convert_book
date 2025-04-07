import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailPasswordUseCase implements UseCase<UserEntity, SignUpWithEmailPasswordParams> {
  final AuthRepository repository;

  SignUpWithEmailPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpWithEmailPasswordParams params) async {
    return await repository.signUpWithEmailAndPassword(
      params.email,
      params.password,
    );
  }
}

class SignUpWithEmailPasswordParams extends Equatable {
  final String email;
  final String password;

  const SignUpWithEmailPasswordParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}