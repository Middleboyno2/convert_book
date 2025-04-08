import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../../core/utils/enums.dart';

abstract class DocumentEvent extends Equatable {
  const DocumentEvent();

  @override
  List<Object?> get props => [];
}

class GetDocumentsEvent extends DocumentEvent {}

class GetDocumentByIdEvent extends DocumentEvent {
  final String id;

  const GetDocumentByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class UploadDocumentEvent extends DocumentEvent {
  final File file;
  final String title;
  final String? author;

  const UploadDocumentEvent({
    required this.file,
    required this.title,
    this.author,
  });

  @override
  List<Object?> get props => [file, title, author];
}

class DeleteDocumentEvent extends DocumentEvent {
  final String id;

  const DeleteDocumentEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class GetDownloadUrlEvent extends DocumentEvent {
  final String filePath;

  const GetDownloadUrlEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class UpdateDocumentCategoryEvent extends DocumentEvent {
  final String id;
  final Category newCategory;

  const UpdateDocumentCategoryEvent({
    required this.id,
    required this.newCategory,
  });

  @override
  List<Object?> get props => [id, newCategory];
}

// Thêm sự kiện này
class UpdateReadingProgressEvent extends DocumentEvent {
  final String id;
  final double progress;
  final int? lastPage;
  final String? lastPosition;

  const UpdateReadingProgressEvent({
    required this.id,
    required this.progress,
    this.lastPage,
    this.lastPosition,
  });

  @override
  List<Object?> get props => [id, progress, lastPage, lastPosition];
}

class UpdateDocumentCoverEvent extends DocumentEvent {
  final String id;
  final File coverFile;

  const UpdateDocumentCoverEvent({
    required this.id,
    required this.coverFile,
  });

  @override
  List<Object> get props => [id, coverFile];
}