// lib/presentation/bloc/document/document_state.dart

import 'package:equatable/equatable.dart';

import '../../../domain/entities/document_entity.dart';

abstract class DocumentState extends Equatable {
  const DocumentState();

  @override
  List<Object?> get props => [];
}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentsLoaded extends DocumentState {
  final List<DocumentEntity> documents;

  const DocumentsLoaded(this.documents);

  @override
  List<Object?> get props => [documents];
}

class DocumentLoaded extends DocumentState {
  final DocumentEntity document;

  const DocumentLoaded(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentUploaded extends DocumentState {
  final DocumentEntity document;

  const DocumentUploaded(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentDeleted extends DocumentState {}

class DocumentUrlLoaded extends DocumentState {
  final String url;

  const DocumentUrlLoaded(this.url);

  @override
  List<Object?> get props => [url];
}

class DocumentError extends DocumentState {
  final String message;

  const DocumentError(this.message);

  @override
  List<Object?> get props => [message];
}

class DocumentCategoryUpdated extends DocumentState {
  final DocumentEntity document;

  const DocumentCategoryUpdated(this.document);

  @override
  List<Object?> get props => [document];
}

// Thêm state mới cho yêu cầu xác thực
class DocumentAuthenticationRequired extends DocumentState {}