

import 'package:dartz/dartz.dart';
import 'package:doantotnghiep/core/error/failures.dart';
import 'package:doantotnghiep/domain/repositories/document_repository.dart';
import 'package:equatable/equatable.dart';

import '../../../core/usecase/usecase.dart';

class IsDocumentCachedUseCase implements UseCase<bool, IsDocumentCachedParams>{
  final DocumentRepository repository;
  IsDocumentCachedUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(IsDocumentCachedParams params) async{
    return await repository.isDocumentCached(params.fileName);
  }

}

class IsDocumentCachedParams extends Equatable{
  final String fileName;
  const IsDocumentCachedParams({required this.fileName});

  @override
  List<Object?> get props => [fileName];

}