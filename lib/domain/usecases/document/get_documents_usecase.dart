import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/document_entity.dart';
import '../../repositories/document_repository.dart';

class GetDocumentsUseCase implements UseCase<List<DocumentEntity>, NoParams> {
  final DocumentRepository repository;

  GetDocumentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<DocumentEntity>>> call(NoParams params) async {
    return await repository.getDocuments();
  }
}