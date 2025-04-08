// lib/domain/usecases/update_reading_progress_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/document_entity.dart';
import '../../repositories/document_repository.dart';

class UpdateReadingProgressUseCase implements UseCase<DocumentEntity, UpdateReadingProgressParams> {
  final DocumentRepository repository;

  UpdateReadingProgressUseCase(this.repository);

  @override
  Future<Either<Failure, DocumentEntity>> call(UpdateReadingProgressParams params) async {
    return await repository.updateReadingProgress(params.id, params.progress, params.lastPage, params.lastPosition);
  }
}

class UpdateReadingProgressParams extends Equatable {
  final String id;
  final double progress;
  final int? lastPage;
  final String? lastPosition;

  const UpdateReadingProgressParams({
    required this.id,
    required this.progress,
    this.lastPage,
    this.lastPosition,
  });

  @override
  List<Object?> get props => [id, progress, lastPage, lastPosition];
}