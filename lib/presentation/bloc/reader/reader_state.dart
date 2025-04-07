import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/document_entity.dart';

abstract class DocumentReaderState extends Equatable {
  const DocumentReaderState();

  @override
  List<Object?> get props => [];
}

class DocumentReaderInitial extends DocumentReaderState {}

class DocumentReaderLoading extends DocumentReaderState {}

class DocumentReaderLoaded extends DocumentReaderState {
  final DocumentEntity document;
  final File file;
  final double? progress;

  const DocumentReaderLoaded({
    required this.document,
    required this.file,
    this.progress,
  });

  @override
  List<Object?> get props => [document, file, progress];
}

class DocumentReaderError extends DocumentReaderState {
  final String message;

  const DocumentReaderError(this.message);

  @override
  List<Object?> get props => [message];
}