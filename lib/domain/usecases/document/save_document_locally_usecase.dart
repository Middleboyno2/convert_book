
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:doantotnghiep/core/error/failures.dart';
import 'package:doantotnghiep/core/usecase/usecase.dart';
import 'package:doantotnghiep/domain/repositories/document_repository.dart';
import 'package:equatable/equatable.dart';

class SaveDocumentLocallyUseCase implements UseCase<File, SaveDocumentLocallyParams>{
  final DocumentRepository repository;
  const SaveDocumentLocallyUseCase(this.repository);
  @override
  Future<Either<Failure, File>> call(SaveDocumentLocallyParams params) async{
    return await repository.saveDocumentLocally(params.url, params.fileName);
  }
}

class SaveDocumentLocallyParams extends Equatable{
  final String url;
  final String fileName;
  const SaveDocumentLocallyParams({required this.url, required this.fileName});

  @override
  List<Object?> get props => [url, fileName];
}