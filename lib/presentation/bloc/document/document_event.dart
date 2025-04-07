import 'dart:io';

import 'package:equatable/equatable.dart';

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
