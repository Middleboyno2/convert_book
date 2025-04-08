// lib/data/models/document_model.dart

import '../../core/utils/enums.dart';
import '../../domain/entities/document_entity.dart';

class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required String id,
    required String title,
    required DateTime uploadDate,
    required String filePath,
    required DocumentType type,
    required Category category,
    required String userId,
    String? author,
    String? coverUrl,
    double? readingProgress,
    int? lastReadPage,
    String? lastReadPosition,
    DateTime? lastReadTime,
  }) : super(
    id: id,
    title: title,
    uploadDate: uploadDate,
    filePath: filePath,
    type: type,
    category: category,
    userId: userId,
    author: author,
    coverUrl: coverUrl,
    readingProgress: readingProgress,
    lastReadPage: lastReadPage,
    lastReadPosition: lastReadPosition,
    lastReadTime: lastReadTime,
  );

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      title: json['title'],
      uploadDate: DateTime.parse(json['uploadDate']),
      filePath: json['filePath'],
      type: _parseDocumentType(json['type']),
      category: _parseCategory(json['category']),
      userId: json['userId'],
      author: json['author'],
      coverUrl: json['coverUrl'],
      readingProgress: json['readingProgress'] != null ? (json['readingProgress'] as num).toDouble() : null,
      lastReadPage: json['lastReadPage'],
      lastReadPosition: json['lastReadPosition'],
      lastReadTime: json['lastReadTime'] != null ? DateTime.parse(json['lastReadTime']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'uploadDate': uploadDate.toIso8601String(),
      'filePath': filePath,
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
      'userId': userId,
      'author': author,
      'coverUrl': coverUrl,
      'readingProgress': readingProgress,
      'lastReadPage': lastReadPage,
      'lastReadPosition': lastReadPosition,
      'lastReadTime': lastReadTime?.toIso8601String(),
    };
  }

  static DocumentType _parseDocumentType(String typeStr) {
    return typeStr == 'pdf' ? DocumentType.pdf : DocumentType.epub;
  }

  static Category _parseCategory(String categoryStr) {
    return categoryStr == 'completed' ? Category.completed : Category.unread;
  }
}