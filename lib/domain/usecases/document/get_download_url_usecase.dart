// lib/domain/usecases/get_download_url_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/document_repository.dart';



class GetDownloadUrlUseCase implements UseCase<String, FilePathParams> {
  final DocumentRepository repository;

  GetDownloadUrlUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(FilePathParams params) async {
    return await repository.getDownloadUrl(params.filePath);
  }
}

class FilePathParams extends Equatable {
  final String filePath;

  const FilePathParams({required this.filePath});

  @override
  List<Object> get props => [filePath];
}