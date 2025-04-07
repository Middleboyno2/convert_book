import 'dart:io';

import 'package:doantotnghiep/presentation/bloc/reader/reader_event.dart';
import 'package:doantotnghiep/presentation/bloc/reader/reader_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;

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

      File file;

      // Check if file is already cached
      if (await localDataSource.isDocumentCached(fileName)) {
        file = await localDataSource.getLocalDocument(fileName);
      } else {
        // Download file
        final downloadUrlResult = await getDownloadUrl(
          FilePathParams(filePath: document.filePath),
        );

        final url = downloadUrlResult.fold(
              (failure) => throw failure,
              (url) => url,
        );

        file = await localDataSource.saveDocumentLocally(url, fileName);
      }

      emit(DocumentReaderLoaded(document: document, file: file));

    } catch (e) {
      String message = 'Không thể tải tài liệu';
      if (e is Failure) {
        message = _mapFailureToMessage(e);
      }
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