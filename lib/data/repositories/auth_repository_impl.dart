import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Stream<UserEntity?> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return Left(NetworkFailure());
      }

      final user = await remoteDataSource.getCurrentUser();
      if (user == null) {
        return Left(UserNotFoundFailure());
      }

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword(String email,
      String password) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return Left(NetworkFailure());
      }

      final user = await remoteDataSource.signInWithEmailAndPassword(
          email, password);
      return Right(user);
    } on AuthException catch (e) {
      if (e.message.contains('Không tìm thấy tài khoản')) {
        return Left(UserNotFoundFailure(e.message));
      } else if (e.message.contains('Mật khẩu không đúng')) {
        return Left(WrongPasswordFailure(e.message));
      } else if (e.message.contains('Tài khoản này đã bị vô hiệu hóa')) {
        return Left(UserDisabledFailure(e.message));
      } else if (e.message.contains('Email không hợp lệ')) {
        return Left(InvalidEmailFailure(e.message));
      } else {
        return Left(AuthFailure(e.message));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword(String email,
      String password) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return Left(NetworkFailure());
      }

      final user = await remoteDataSource.signUpWithEmailAndPassword(
          email, password);
      return Right(user);
    } on AuthException catch (e) {
      if (e.message.contains('Email này đã được sử dụng')) {
        return Left(EmailAlreadyInUseFailure(e.message));
      } else if (e.message.contains('Email không hợp lệ')) {
        return Left(InvalidEmailFailure(e.message));
      } else if (e.message.contains('Mật khẩu quá yếu')) {
        return Left(WeakPasswordFailure(e.message));
      } else {
        return Left(AuthFailure(e.message));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return Left(NetworkFailure());
      }

      final user = await remoteDataSource.signInWithGoogle();
      return Right(user);
    } on AuthException catch (e) {
      if (e.message.contains('Đăng nhập Google đã bị hủy')) {
        return Left(SignInCancelledFailure(e.message));
      } else {
        return Left(SignInFailedFailure(e.message));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithApple() async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return Left(NetworkFailure());
      }

      final user = await remoteDataSource.signInWithApple();
      return Right(user);
    } on AuthException catch (e) {
      if (e.message.contains('Đăng nhập bằng Apple không khả dụng')) {
        return Left(AppleSignInNotAvailableFailure(e.message));
      } else if (e.message.contains('Đăng nhập Apple đã bị hủy')) {
        return Left(SignInCancelledFailure(e.message));
      } else {
        return Left(SignInFailedFailure(e.message));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return Left(NetworkFailure());
      }

      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      if (e.message.contains('Email không hợp lệ')) {
        return Left(InvalidEmailFailure(e.message));
      } else if (e.message.contains('Không tìm thấy tài khoản')) {
        return Left(UserNotFoundFailure(e.message));
      } else {
        return Left(AuthFailure(e.message));
      }
    }
  }
}