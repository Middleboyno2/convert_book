import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:epub_view/epub_view.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/service/local_storage_service.dart';
import '../../core/utils/enums.dart';
import '../../domain/entities/document_entity.dart';
import '../bloc/document/document_bloc.dart';
import '../bloc/document/document_event.dart';
import '../bloc/document/document_state.dart';
import '../bloc/reader/reader_bloc.dart';
import '../bloc/reader/reader_event.dart';
import '../bloc/reader/reader_state.dart';
import '../widgets/custom_reader/custom_epub_reader.dart';
import '../widgets/custom_reader/custom_epub_reader_2.dart';
import '../widgets/custom_reader/custom_pdf_reader.dart';


class DocumentReaderPage extends StatefulWidget {
  final String documentId;

  const DocumentReaderPage({super.key, required this.documentId});

  @override
  _DocumentReaderPageState createState() => _DocumentReaderPageState();
}

class _DocumentReaderPageState extends State<DocumentReaderPage> {
  // EpubController? _epubController;
  int? _totalPdfPages;
  int _currentPdfPage = 0;
  bool _isLoading = true;
  DocumentEntity? _document;
  late DocumentBloc _documentBloc;
  // bool isHide = true;

  // theo dõi thời gian giữa các lần cập nhật tiến độ
  DateTime? _lastProgressUpdate;
  // Khoảng thời gian tối thiểu giữa các lần cập nhật (20 giây)
  final Duration _progressUpdateInterval = Duration(seconds: 20);
  final LocalStorageService _localStorageService = LocalStorageService();

  // Subscription để theo dõi kết nối mạng
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _documentBloc = context.read<DocumentBloc>();
    _loadDocument();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lưu tham chiếu đến DocumentBloc để sử dụng trong dispose
    _documentBloc = context.read<DocumentBloc>();
  }

  @override
  void dispose() {
    // Lưu tiến độ đọc trước khi dispose
    //_saveReadingProgressSafely();
    // Giải phóng tài nguyên
    //_epubController?.dispose();
    super.dispose();
  }
  void _loadDocument() {
    _documentBloc.add(GetDocumentByIdEvent(widget.documentId));
  }
  void _loadDocumentContent() {
    if (_document == null) return;
    // Tải file từ Firebase Storage hoặc từ bộ nhớ cục bộ tùy thuộc vào kết nối
    context.read<DocumentReaderBloc>().add(
      LoadDocumentEvent(_document!),
    );
  }

  void _saveReadingProgressSafely() {
    try {
      if (_document != null) {
        double progress = 0.0;
        int? currentPage;
        String? currentPosition;

        if (_document!.type == DocumentType.pdf) {
          // xử lý sau
        } else if (_document!.type == DocumentType.epub) {

        }
        // Lưu tiến độ lên Firebase
        _documentBloc.add(
          UpdateReadingProgressEvent(
            id: _document!.id,
            progress: progress,
            lastPage: currentPage,
            lastPosition: currentPosition,
          ),
        );
        _saveReadingProgressToLocal(
            _document!.id,
            progress,
            currentPage,
            currentPosition
        );

      }
    } catch (e) {
      print('Error in _saveReadingProgressSafely: $e');
    }
  }


// Phương thức lưu tiến độ vào local storage
  void _saveReadingProgressToLocal(
      String documentId,
      double progress,
      int? lastPage,
      String? lastPosition
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'reading_progress_$documentId';

      final Map<String, dynamic> progressData = {
        'progress': progress,
        'lastPage': lastPage,
        'lastPosition': lastPosition,
        'timestamp': DateTime.now(),
      };

      await prefs.setString(key, progressData.toString());
      print('Saved reading progress locally: $progress');
    } catch (e) {
      print('Error saving reading progress to local: $e');
    }
  }

  // Cập nhật tiến độ đọc với giới hạn tần suất
  void _updateReadingProgress() {
    final now = DateTime.now();

    // Kiểm tra xem đã đủ thời gian giữa các lần cập nhật chưa
    if (_lastProgressUpdate != null) {
      final difference = now.difference(_lastProgressUpdate!);
      if (difference < _progressUpdateInterval) {
        return;
      }
    }
    _lastProgressUpdate = now;
    _saveReadingProgressSafely();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: _document?.type == DocumentType.epub ? _buildTableOfContentsDrawer() : null,
      body: Center(
        child: Stack(
          children: [
            AppBar(
              title: BlocBuilder<DocumentBloc, DocumentState>(
                builder: (context, state) {
                  if (state is DocumentLoaded) {
                    _document = state.document;
                    return Text(state.document.title);
                  }
                  return Text('Đang tải...');
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () => _showDocumentInfo(),
                ),
              ],
            ),
            BlocConsumer<DocumentBloc, DocumentState>(
              listener: (context, state) {
                if (state is DocumentLoaded) {
                  _document = state.document;
                  setState(() {
                    _isLoading = false;
                  });
                  // Tải nội dung file
                  _loadDocumentContent();
                } else if (state is DocumentError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is DocumentAuthenticationRequired) {
                  context.push('/auth');
                }
              },
              builder: (context, state) {
                if (state is DocumentLoading || _isLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is DocumentLoaded) {
                  return BlocBuilder<DocumentReaderBloc, DocumentReaderState>(
                    builder: (context, readerState) {
                      if (readerState is DocumentReaderLoading) {
                        return Center(child: CircularProgressIndicator());
                      } else if (readerState is DocumentReaderLoaded) {
                        try {
                          return _buildReader(readerState);
                        } catch (e) {
                          print('Error building reader: $e');
                          return _buildErrorView(e.toString());
                        }
                      } else if (readerState is DocumentReaderError) {
                        return _buildErrorView(readerState.message);
                      }
                      return Center(child: Text('Đang tải nội dung...'));
                    },
                  );
                } else if (state is DocumentError) {
                  return _buildErrorView(state.message);
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          SizedBox(height: 16),
          Text(
            'Không thể tải tài liệu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadDocument();
            },
            child: Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildReader(DocumentReaderLoaded state) {
    final document = state.document;
    final file = state.file;
    int lastReadPage = document.lastReadPage ?? 0;
    double lastReadPosition = document.lastReadPosition ?? 0.0;
    try {
      print('Đang xây dựng trình đọc cho file: ${file.path}');

      if (file.existsSync()) {
        print('File tồn tại với kích thước: ${file.lengthSync()} bytes');
      } else {
        print('File không tồn tại: ${file.path}');
        return _buildErrorView('File không tồn tại: ${file.path}');
      }
      print('Loại tài liệu: ${document.type}');
      // Sử dụng trình đọc phù hợp dựa trên loại file
      if (document.type == DocumentType.epub) {
        return CustomEpubReader2(
          file: file,
          lastPosition: lastReadPosition,
          lastPage: lastReadPage,
        );
      } else {
        return CustomPdfReader(
          file: file,
          initialPage: document.lastReadPage ?? 0,
        );
      }
    } catch (e, stackTrace) {
      print('Lỗi khi xây dựng trình đọc: $e');
      print('Stack trace: $stackTrace');
      return _buildErrorView('Lỗi khi hiển thị tài liệu: ${e.toString()}');
    }
  }

  Widget _buildTableOfContentsDrawer() {
    if (_document?.type != DocumentType.epub) {
      return Drawer(
        child: Center(
          child: Text('Đang tải mục lục...'),
        ),
      );
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Mục lục',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(),
            // Expanded(
            //   child: EpubViewTableOfContents(
            //     controller: _epubController!,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _showDocumentInfo() {
    if (_document == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_document!.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_document!.author != null)
              Text('Tác giả: ${_document!.author}'),
            SizedBox(height: 8),
            Text('Ngày tải lên: ${_formatDate(_document!.uploadDate)}'),
            SizedBox(height: 8),
            Text('Định dạng: ${_document!.type == DocumentType.pdf ? "PDF" : "EPUB"}'),
            SizedBox(height: 8),
            Text('Tiến độ đọc: ${((_document!.readingProgress ?? 0) * 100).toInt()}%'),
            if (_document!.lastReadTime != null) ...[
              SizedBox(height: 8),
              Text('Lần đọc cuối: ${_formatDate(_document!.lastReadTime!)}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}