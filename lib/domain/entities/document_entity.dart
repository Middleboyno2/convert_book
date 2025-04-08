import 'package:equatable/equatable.dart';

import '../../core/utils/enums.dart';


class DocumentEntity extends Equatable {
  final String id;
  final String title;
  final String? author;
  final DateTime uploadDate;
  final String filePath;
  final DocumentType type;
  final Category category;
  final String userId;
  final String? coverUrl; // url anh
  final double? readingProgress; // tien do doc
  final int? lastReadPage; // Trang đọc cuối cùng (pdf)
  final String? lastReadPosition; // Vị trí đọc cuối (EPUB)
  final DateTime? lastReadTime; // Thời gian đọc cuối cùng

  const DocumentEntity({
    required this.id,
    required this.title,
    required this.uploadDate,
    required this.filePath,
    required this.type,
    required this.category,
    required this.userId,
    this.author,
    this.coverUrl,
    this.readingProgress,
    this.lastReadPage,
    this.lastReadPosition,
    this.lastReadTime,
  });

  @override
  List<Object?> get props => [id, title, author, uploadDate, filePath, type,
    category, userId, coverUrl, readingProgress, lastReadPage, lastReadPosition,
    lastReadTime];
}