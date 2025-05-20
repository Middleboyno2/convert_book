

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:doantotnghiep/core/error/failures.dart';
import 'package:equatable/equatable.dart';

import '../../../core/usecase/usecase.dart';
import '../../repositories/document_repository.dart';

class GetLocalDocumentUseCase implements UseCase<File, GetLocalDocumentParams>{
  final DocumentRepository repository;

  GetLocalDocumentUseCase(this.repository);
  @override
  Future<Either<Failure, File>> call(GetLocalDocumentParams params) async{
    return await repository.getLocalDocument(params.fileName);
  }

}

class GetLocalDocumentParams extends Equatable{
  final String fileName;
  const GetLocalDocumentParams({required this.fileName});

  @override
  List<Object?> get props => [fileName];
}