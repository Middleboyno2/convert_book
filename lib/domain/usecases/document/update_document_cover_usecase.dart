import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/document_entity.dart';
import '../../repositories/document_repository.dart';



class UpdateDocumentCoverUseCase implements UseCase<DocumentEntity, UpdateDocumentCoverParams> {
  final DocumentRepository repository;

  UpdateDocumentCoverUseCase(this.repository);

  @override
  Future<Either<Failure, DocumentEntity>> call(UpdateDocumentCoverParams params) async {
    return await repository.updateDocumentCover(params.id, params.coverFile);
  }
}

class UpdateDocumentCoverParams extends Equatable {
  final String id;
  final File coverFile;

  const UpdateDocumentCoverParams({
    required this.id,
    required this.coverFile,
  });

  @override
  List<Object> get props => [id, coverFile];
}