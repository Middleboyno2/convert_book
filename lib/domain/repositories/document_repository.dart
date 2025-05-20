import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/utils/enums.dart';
import '../entities/document_entity.dart';

abstract class DocumentRepository {
  // lay toan bo document
  Future<Either<Failure, List<DocumentEntity>>> getDocuments();
  // lay document theo document id
  Future<Either<Failure, DocumentEntity>> getDocumentById(String id);
  // day file len firebase
  Future<Either<Failure, DocumentEntity>> uploadDocument(File file, String title, {String? author});
  // xoa document
  Future<Either<Failure, void>> deleteDocument(String id);
  // lay url document trong storage
  Future<Either<Failure, String>> getDownloadUrl(String filePath);
  // cap nhat category document
  Future<Either<Failure, DocumentEntity>> updateDocumentCategory(String id, Category category);
  // cap nhat tien do doc cua document
  Future<Either<Failure, DocumentEntity>> updateReadingProgress(
      String id, double progress, int? lastPage, String? lastPosition);
  // cap nhat anh document
  Future<Either<Failure, DocumentEntity>> updateDocumentCover(String id, File coverFile);
  // luu document local
  Future<Either<Failure, File>> saveDocumentLocally(String url, String filename);
  // kiem tra file ton tai
  Future<Either<Failure, bool>> isDocumentCached(String fileName);
  // lay file Document luu local
  Future<Either<Failure, File>> getLocalDocument(String fileName);
}