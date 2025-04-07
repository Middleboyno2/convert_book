import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/document_entity.dart';
import '../../repositories/document_repository.dart';


class GetDocumentUseCase implements UseCase<DocumentEntity, DocumentParams> {
  final DocumentRepository repository;

  GetDocumentUseCase(this.repository);

  @override
  Future<Either<Failure, DocumentEntity>> call(DocumentParams params) async {
    return await repository.getDocumentById(params.id);
  }
}
class DocumentParams extends Equatable {
  final String id;

  const DocumentParams({required this.id});

  @override
  List<Object> get props => [id];
}
