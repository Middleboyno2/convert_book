import 'dart:io';

import 'package:doantotnghiep/domain/usecases/document/get_local_document_usecase.dart';
import 'package:doantotnghiep/domain/usecases/document/is_document_cached_usecase.dart';
import 'package:doantotnghiep/domain/usecases/document/save_document_locally_usecase.dart';
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
  final GetLocalDocumentUseCase getLocalDocument;
  final IsDocumentCachedUseCase isDocumentCached;
  final SaveDocumentLocallyUseCase saveDocumentLocally;

  DocumentReaderBloc({
    required this.getDownloadUrl,
    required this.getLocalDocument,
    required this.isDocumentCached,
    required this.saveDocumentLocally
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
      // Kiểm tra xem file đã được cache chưa
      bool isCached = false;
      bool shouldDownload = false;
      final result = await isDocumentCached(IsDocumentCachedParams(fileName: fileName));
      result.fold(
              (failure) => {
            emit(DocumentReaderError(failure.message))
          },
              (isDocumentCached) => {
            isCached = isDocumentCached
          }
      );
      if (isCached) {
        final result = await getLocalDocument(GetLocalDocumentParams(fileName: fileName));
        result.fold(
                (failure) => {
              emit(DocumentReaderError(failure.message))
            },
                (getFile) => file = getFile
        );
        // Kiểm tra file tồn tại và có kích thước > 0
        if (!file.existsSync() || await file.length() == 0) {
          // Nếu đang online và file cached không hợp lệ, tải lại
          shouldDownload = true;
        } else {
          // File cached hợp lệ, không cần tải lại
          shouldDownload = false;
        }
      } else {
        // File chưa được cache
        print('Không tìm thấy file đã lưu');
        shouldDownload = true;
      }
      if (shouldDownload) {
        // Tải file từ server
        try {
          final downloadUrlResult = await getDownloadUrl(
            FilePathParams(filePath: document.filePath),
          );
          late String urlDoc;
          downloadUrlResult.fold(
                (failure) => emit(DocumentReaderError(failure.message)),
                (url) => urlDoc = url,
          );
          final result = await saveDocumentLocally(SaveDocumentLocallyParams(url: urlDoc, fileName: fileName));
          result.fold(
                  (failure) => {
                emit(DocumentReaderError(failure.message))
              },
                  (newFile) => file = newFile
          );
          // Kiểm tra file đã lưu thành công chưa
          if (!file.existsSync() || await file.length() == 0) {
            print("luu file thanh công");
          }

        } catch (e) {
          print('Error downloading file: $e');
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