// lib/presentation/bloc/document/document_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../../domain/usecases/document/delete_document_usecase.dart';
import '../../../domain/usecases/document/get_document_usecase.dart';
import '../../../domain/usecases/document/get_documents_usecase.dart';
import '../../../domain/usecases/document/get_download_url_usecase.dart';
import '../../../domain/usecases/document/update_document_category_usecase.dart';
import '../../../domain/usecases/document/update_document_cover_usecase.dart';
import '../../../domain/usecases/document/update_reading_progress_usecase.dart';
import '../../../domain/usecases/document/upload_document_usecase.dart';
import '../auth/auth_bloc.dart';
import '../auth/auth_event.dart';
import '../auth/auth_state.dart';
import 'document_event.dart';
import 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final GetDocumentsUseCase getDocuments;
  final GetDocumentUseCase getDocument;
  final UploadDocumentUseCase uploadDocument;
  final GetDownloadUrlUseCase getDownloadUrl;
  final DeleteDocumentUseCase deleteDocument;
  final UpdateDocumentCategoryUseCase updateDocumentCategory;
  final UpdateReadingProgressUseCase updateReadingProgress;
  final UpdateDocumentCoverUseCase updateDocumentCover;
  final AuthBloc authBloc;

  DocumentBloc({
    required this.getDocuments,
    required this.getDocument,
    required this.uploadDocument,
    required this.getDownloadUrl,
    required this.deleteDocument,
    required this.updateDocumentCategory,
    required this.authBloc,
    required this.updateReadingProgress,
    required this.updateDocumentCover,
  }) : super(DocumentInitial()) {
    on<GetDocumentsEvent>(_onGetDocuments);
    on<GetDocumentByIdEvent>(_onGetDocumentById);
    on<UploadDocumentEvent>(_onUploadDocument);
    on<GetDownloadUrlEvent>(_onGetDownloadUrl);
    on<DeleteDocumentEvent>(_onDeleteDocument);
    on<UpdateDocumentCategoryEvent>(_onUpdateDocumentCategory);
    on<UpdateReadingProgressEvent>(_onUpdateReadingProgress);
    on<UpdateDocumentCoverEvent>(_onUpdateDocumentCover);
  }

  Future<void> _onGetDocuments(
      GetDocumentsEvent event,
      Emitter<DocumentState> emit,
      ) async {
    emit(DocumentLoading());

    // Kiểm tra trạng thái xác thực
    if (await authBloc.state is! AuthAuthenticated) {
      emit(DocumentAuthenticationRequired());
      return;
    }

    final result = await getDocuments(NoParams());
    result.fold(
          (failure) {
        if (failure is NotAuthenticatedFailure) {
          emit(DocumentAuthenticationRequired());
        } else {
          emit(DocumentError(_mapFailureToMessage(failure)));
        }
      },
          (documents) => emit(DocumentsLoaded(documents)),
    );
  }

  Future<void> _onGetDocumentById(
      GetDocumentByIdEvent event,
      Emitter<DocumentState> emit,
      ) async {
    emit(DocumentLoading());

    // Kiểm tra trạng thái xác thực
    if ( await authBloc.state is! AuthAuthenticated) {
      emit(DocumentAuthenticationRequired());
      return;
    }

    final result = await getDocument(DocumentParams(id: event.id));
    result.fold(
          (failure) {
        if (failure is NotAuthenticatedFailure) {
          emit(DocumentAuthenticationRequired());
        } else {
          emit(DocumentError(_mapFailureToMessage(failure)));
        }
      },
          (document) => emit(DocumentLoaded(document)),
    );
  }

  Future<void> _onUploadDocument(
      UploadDocumentEvent event,
      Emitter<DocumentState> emit,
      ) async {
    emit(DocumentLoading());

    // Kiểm tra trạng thái xác thực
    if (await authBloc.state is! AuthAuthenticated) {
      emit(DocumentAuthenticationRequired());
      return;
    }

    final result = await uploadDocument(
      UploadDocumentParams(
        file: event.file,
        title: event.title,
        author: event.author,
      ),
    );
    result.fold(
          (failure) {
        if (failure is NotAuthenticatedFailure) {
          emit(DocumentAuthenticationRequired());
        } else {
          emit(DocumentError(_mapFailureToMessage(failure)));
        }
      },
          (document) => emit(DocumentUploaded(document)),
    );
  }

  Future<void> _onGetDownloadUrl(
      GetDownloadUrlEvent event,
      Emitter<DocumentState> emit,
      ) async {
    emit(DocumentLoading());

    // Kiểm tra trạng thái xác thực
    if (await authBloc.state is! AuthAuthenticated) {
      emit(DocumentAuthenticationRequired());
      return;
    }

    final result = await getDownloadUrl(FilePathParams(filePath: event.filePath));
    result.fold(
          (failure) {
        if (failure is NotAuthenticatedFailure) {
          emit(DocumentAuthenticationRequired());
        } else {
          emit(DocumentError(_mapFailureToMessage(failure)));
        }
      },
          (url) => emit(DocumentUrlLoaded(url)),
    );
  }

  Future<void> _onDeleteDocument(
      DeleteDocumentEvent event,
      Emitter<DocumentState> emit,
      ) async {
    emit(DocumentLoading());

    // Kiểm tra trạng thái xác thực
    if (await authBloc.state is! AuthAuthenticated) {
      emit(DocumentAuthenticationRequired());
      return;
    }

    final result = await deleteDocument(DeleteDocumentParams(id: event.id));
    result.fold(
          (failure) {
        if (failure is NotAuthenticatedFailure) {
          emit(DocumentAuthenticationRequired());
        } else {
          emit(DocumentError(_mapFailureToMessage(failure)));
        }
      },
          (_) => emit(DocumentDeleted()),
    );
  }

  Future<void> _onUpdateDocumentCategory(
      UpdateDocumentCategoryEvent event,
      Emitter<DocumentState> emit,
      ) async {
    emit(DocumentLoading());

    // Kiểm tra trạng thái xác thực
    if (await authBloc.state is! AuthAuthenticated) {
      emit(DocumentAuthenticationRequired());
      return;
    }

    final result = await updateDocumentCategory(
      UpdateCategoryParams(
        id: event.id,
        category: event.newCategory,
      ),
    );
    result.fold(
          (failure) {
        if (failure is NotAuthenticatedFailure) {
          emit(DocumentAuthenticationRequired());
        } else {
          emit(DocumentError(_mapFailureToMessage(failure)));
        }
      },
          (document) => emit(DocumentCategoryUpdated(document)),
    );
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
      case NotAuthenticatedFailure:
        return 'Vui lòng đăng nhập để tiếp tục';
      case StorageFailure:
        return 'Lỗi khi tải lên file. Vui lòng thử lại.';
      case CoverUpdateFailure:
        return 'Không thể cập nhật ảnh bìa. Vui lòng thử lại.';
      default:
        return 'Đã xảy ra lỗi không xác định';
    }
  }

  Future<void> _onUpdateReadingProgress(
      UpdateReadingProgressEvent event,
      Emitter<DocumentState> emit,
      ) async {
    try {
      final result = await updateReadingProgress(
        UpdateReadingProgressParams(
          id: event.id,
          progress: event.progress,
          lastPage: event.lastPage,
          lastPosition: event.lastPosition,
        ),
      );

      result.fold(
            (failure) {
          // Không emit lỗi để tránh gián đoạn UX khi đọc
          print('Failure updating reading progress: ${_mapFailureToMessage(failure)}');
        },
            (document) => emit(ReadingProgressUpdated(document)),
      );
    } catch (e) {
      print('Error updating reading progress: $e');
    }
  }

  Future<void> _onUpdateDocumentCover(
      UpdateDocumentCoverEvent event,
      Emitter<DocumentState> emit,
      ) async {
    emit(DocumentLoading());

    // Kiểm tra trạng thái xác thực
    if ( await authBloc.state is! AuthAuthenticated) {
      emit(DocumentAuthenticationRequired());
      return;
    }

    final result = await updateDocumentCover(
      UpdateDocumentCoverParams(
        id: event.id,
        coverFile: event.coverFile,
      ),
    );

    result.fold(
          (failure) {
        if (failure is NotAuthenticatedFailure) {
          emit(DocumentAuthenticationRequired());
        } else {
          emit(DocumentError(_mapFailureToMessage(failure)));
        }
      },
          (document) => emit(DocumentCoverUpdated(document)),
    );
  }
}