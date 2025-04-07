import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/document_entity.dart';
import '../../repositories/document_repository.dart';

class UploadDocumentUseCase implements UseCase<DocumentEntity, UploadDocumentParams> {
  final DocumentRepository repository;

  UploadDocumentUseCase(this.repository);

  @override
  Future<Either<Failure, DocumentEntity>> call(UploadDocumentParams params) async {
    return await repository.uploadDocument(params.file, params.title, author: params.author);
  }
}

class UploadDocumentParams extends Equatable {
  final File file;
  final String title;
  final String? author;

  const UploadDocumentParams({
    required this.file,
    required this.title,
    this.author,
  });

  @override
  List<Object?> get props => [file, title, author];
}

