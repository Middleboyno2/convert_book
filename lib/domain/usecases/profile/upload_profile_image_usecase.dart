import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:doantotnghiep/core/error/failures.dart';
import 'package:doantotnghiep/core/usecase/usecase.dart';
import 'package:doantotnghiep/domain/entities/user_entity.dart';

import 'package:doantotnghiep/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

class UploadProfileImageUseCase implements UseCase<void, UpLoadProfileImageParams>{
  final AuthRepository repository;

  UploadProfileImageUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpLoadProfileImageParams params) async{
    return await repository.upLoadProfileImage(params.file);
  }
}

class UpLoadProfileImageParams extends Equatable {
  final File file;

  const UpLoadProfileImageParams({
    required this.file
  });

  @override
  List<Object> get props => [file];
}