import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/document_repository.dart';

class DeleteDocumentUseCase implements UseCase<void, DeleteDocumentParams> {
  final DocumentRepository repository;

  DeleteDocumentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteDocumentParams params) async {
    return await repository.deleteDocument(params.id);
  }
}

class DeleteDocumentParams extends Equatable {
  final String id;

  const DeleteDocumentParams({required this.id});

  @override
  List<Object> get props => [id];
}
