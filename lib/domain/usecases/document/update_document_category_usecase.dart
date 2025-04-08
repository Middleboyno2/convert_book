import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../../core/utils/enums.dart';
import '../../entities/document_entity.dart';
import '../../repositories/document_repository.dart';

class UpdateDocumentCategoryUseCase implements UseCase<DocumentEntity, UpdateCategoryParams> {
  final DocumentRepository repository;

  UpdateDocumentCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, DocumentEntity>> call(UpdateCategoryParams params) async {
    return await repository.updateDocumentCategory(params.id, params.category);
  }
}

class UpdateCategoryParams extends Equatable {
  final String id;
  final Category category;

  const UpdateCategoryParams({
    required this.id,
    required this.category,
  });

  @override
  List<Object> get props => [id, category];
}