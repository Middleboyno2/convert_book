import 'package:equatable/equatable.dart';

import '../../../domain/entities/document_entity.dart';

abstract class DocumentReaderEvent extends Equatable {
  const DocumentReaderEvent();

  @override
  List<Object?> get props => [];
}

class LoadDocumentEvent extends DocumentReaderEvent {
  final DocumentEntity document;

  const LoadDocumentEvent(this.document);

  @override
  List<Object?> get props => [document];
}

class SaveReadingProgressEvent extends DocumentReaderEvent {
  final double progress;

  const SaveReadingProgressEvent(this.progress);

  @override
  List<Object?> get props => [progress];
}