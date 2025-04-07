import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/document_entity.dart';

abstract class DocumentRepository {
  Future<Either<Failure, List<DocumentEntity>>> getDocuments();
  Future<Either<Failure, DocumentEntity>> getDocumentById(String id);
  Future<Either<Failure, DocumentEntity>> uploadDocument(File file, String title, {String? author});
  Future<Either<Failure, void>> deleteDocument(String id);
  Future<Either<Failure, String>> getDownloadUrl(String filePath);
}