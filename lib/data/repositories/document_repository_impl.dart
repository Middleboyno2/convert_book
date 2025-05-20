import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/utils/enums.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/local/document_local_datasource.dart';
import '../datasources/remote/document_remote_datasource.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource remoteDataSource;
  final DocumentLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  DocumentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<DocumentEntity>>> getDocuments() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteDocuments = await remoteDataSource.getDocuments();
        return Right(remoteDocuments);
      } on ServerException {
        return Left(ServerFailure());
      } on NotAuthenticatedException {
        return Left(NotAuthenticatedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> getDocumentById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteDocument = await remoteDataSource.getDocumentById(id);
        return Right(remoteDocument);
      } on ServerException {
        return Left(ServerFailure());
      } on NotFoundException {
        return Left(NotFoundFailure());
      } on NotAuthenticatedException {
        return Left(NotAuthenticatedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> uploadDocument(File file, String title, {String? author}) async {
    if (await networkInfo.isConnected) {
      try {
        // // Kiểm tra xác thực
        // final isAuthenticated = await remoteDataSource.isAuthenticated();
        // if (!isAuthenticated) {
        //   return Left(NotAuthenticatedFailure());
        // }

        final uploadedDocument = await remoteDataSource.uploadDocument(file, title, author: author);
        return Right(uploadedDocument);
      } on ServerException {
        return Left(ServerFailure());
      } on UnsupportedFileException {
        return Left(UnsupportedFileFailure());
      } on NotAuthenticatedException {
        return Left(NotAuthenticatedFailure());
      } on StorageException {
        return Left(StorageFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteDocument(id);
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure());
      } on NotFoundException {
        return Left(NotFoundFailure());
      } on NotAuthenticatedException {
        return Left(NotAuthenticatedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> getDownloadUrl(String filePath) async {
    if (await networkInfo.isConnected) {
      try {
        final url = await remoteDataSource.getDownloadUrl(filePath);
        return Right(url);
      } on ServerException {
        return Left(ServerFailure());
      } on NotAuthenticatedException {
        return Left(NotAuthenticatedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }


  @override
  Future<Either<Failure, DocumentEntity>> updateReadingProgress(
      String id, double progress, int? lastPage, String? lastPosition) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedDocument = await remoteDataSource.updateReadingProgress(
            id, progress, lastPage, lastPosition);
        return Right(updatedDocument);
      } on ServerException {
        return Left(ServerFailure());
      } on NotFoundException {
        return Left(NotFoundFailure());
      } on NotAuthenticatedException {
        return Left(NotAuthenticatedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> updateDocumentCover(String id, File coverFile) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedDocument = await remoteDataSource.updateDocumentCover(id, coverFile);
        return Right(updatedDocument);
      } on ServerException {
        return Left(ServerFailure());
      } on NotFoundException {
        return Left(NotFoundFailure());
      } on NotAuthenticatedException {
        return Left(NotAuthenticatedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> updateDocumentCategory(String id, Category category) async {
    if (await networkInfo.isConnected) {
      try {
        // Lấy document hiện tại
        final document = await remoteDataSource.getDocumentById(id);

        // Cập nhật category trong Firestore
        await remoteDataSource.updateDocumentCategory(id, category);

        // Trả về document đã cập nhật
        final updatedDocument = await remoteDataSource.getDocumentById(id);
        return Right(updatedDocument);
      } on ServerException {
        return Left(ServerFailure());
      } on NotFoundException {
        return Left(NotFoundFailure());
      } on NotAuthenticatedException {
        return Left(NotAuthenticatedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, File>> getLocalDocument(String fileName) async{
    if (await networkInfo.isConnected) {
      try {
        final localDocument = await localDataSource.getLocalDocument(fileName);
        return Right(localDocument);
      } on CacheException {
        return Left(CacheFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isDocumentCached(String fileName) async{
    if (await networkInfo.isConnected) {
      try {
        final isDocument = await localDataSource.isDocumentCached(fileName);
        return Right(isDocument);
      } catch(e){
        print("error: $e");
        return Left(CacheFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, File>> saveDocumentLocally(String url, String fileName) async{
    if (await networkInfo.isConnected) {
      try {
        final localDocument = await localDataSource.saveDocumentLocally(url, fileName);
        return Right(localDocument);
      } on CacheException {
        return Left(CacheFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

}