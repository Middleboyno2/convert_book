import 'dart:io';

import 'package:doantotnghiep/presentation/bloc/reader/reader_event.dart';
import 'package:doantotnghiep/presentation/bloc/reader/reader_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;

import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/document_entity.dart';
import '../../../data/datasources/local/document_local_datasource.dart';
import '../../../domain/usecases/document/get_download_url_usecase.dart';

class DocumentReaderBloc extends Bloc<DocumentReaderEvent, DocumentReaderState> {
  final GetDownloadUrlUseCase getDownloadUrl;
  final DocumentLocalDataSource localDataSource;

  DocumentReaderBloc({
    required this.getDownloadUrl,
    required this.localDataSource,
  }) : super(DocumentReaderInitial()) {
    on<LoadDocumentEvent>(_onLoadDocument);
    on<SaveReadingProgressEvent>(_onSaveReadingProgress);
  }

  Future<void> _onLoadDocument(
      LoadDocumentEvent event,
      Emitter<DocumentReaderState> emit,
      ) async {
    emit(DocumentReaderLoading());
    try {
      final document = event.document;
      final String fileName = _getFileName(document.filePath);
      File file =  File('');
      bool shouldDownload = event.isOnline;
      // Kiểm tra xem file đã được cache chưa
      bool isCached = false;
      try {
        isCached = await localDataSource.isDocumentCached(fileName);
      } catch (e) {
        print('Error checking cache: $e');
        isCached = false;
      }
      if (isCached) {
        try {
          file = await localDataSource.getLocalDocument(fileName);
          // Kiểm tra file tồn tại và có kích thước > 0
          if (!file.existsSync() || await file.length() == 0) {
            if (event.isOnline) {
              // Nếu đang online và file cached không hợp lệ, tải lại
              shouldDownload = true;
            } else {
              throw CacheException('File đã lưu không hợp lệ');
            }
          } else {
            // File cached hợp lệ, không cần tải lại
            shouldDownload = false;
          }
        } catch (e) {
          print('Error getting cached file: $e');
          if (event.isOnline) {
            shouldDownload = true;
          } else {
            throw CacheException('Không thể đọc file đã lưu: $e');
          }
        }
      } else {
        // File chưa được cache
        if (!event.isOnline) {
          throw CacheException('Không tìm thấy file đã lưu và đang ở chế độ ngoại tuyến');
        }
        shouldDownload = true;
      }
      if (shouldDownload) {
        // Tải file từ server
        try {
          final downloadUrlResult = await getDownloadUrl(
            FilePathParams(filePath: document.filePath),
          );

          final url = downloadUrlResult.fold(
                (failure) => throw failure,
                (url) => url,
          );
          try {
            file = await localDataSource.saveDocumentLocally(url, fileName);
            // Kiểm tra file đã lưu thành công chưa
            if (!file.existsSync() || await file.length() == 0) {
              throw CacheException('File tải về không hợp lệ');
            }
          } catch (e) {
            print('Error saving file locally: $e');
            throw CacheException('Không thể lưu file: $e');
          }
        } catch (e) {
          print('Error downloading file: $e');
          if (e is Failure) {
            throw e;
          } else {
            throw ServerException();
          }
        }
      }
      emit(DocumentReaderLoaded(document: document, file: file));

    } catch (e) {
      String message = 'Không thể tải tài liệu';
      if (e is Failure) {
        message = _mapFailureToMessage(e);
      } else if (e is CacheException) {
        message = e.toString();
      } else {
        message = 'Lỗi: ${e.toString()}';
      }
      print('Document Reader Error: $message');
      emit(DocumentReaderError(message));
    }
  }

  Future<void> _onSaveReadingProgress(
      SaveReadingProgressEvent event,
      Emitter<DocumentReaderState> emit,
      ) async {
    final currentState = state;
    if (currentState is DocumentReaderLoaded) {
      emit(DocumentReaderLoaded(
        document: currentState.document,
        file: currentState.file,
        progress: event.progress,
      ));

      // Here you can also save the progress to a local database or Firestore
      // This is a place where you would implement persistent reading progress
    }
  }

  String _getFileName(String filePath) {
    return path.basename(filePath);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Đã xảy ra lỗi máy chủ';
      case NetworkFailure:
        return 'Không có kết nối mạng';
      case NotFoundFailure:
        return 'Không tìm thấy tài liệu';
      case UnsupportedFileFailure:
        return 'Định dạng file không được hỗ trợ';
      default:
        return 'Đã xảy ra lỗi không xác định';
    }
  }
}