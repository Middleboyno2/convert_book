// lib/presentation/pages/document_reader.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
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


class DocumentReaderPage extends StatefulWidget {
  final String documentId;

  const DocumentReaderPage({super.key, required this.documentId});

  @override
  _DocumentReaderPageState createState() => _DocumentReaderPageState();
}

class _DocumentReaderPageState extends State<DocumentReaderPage> {
  EpubController? _epubController;
  int? _totalPdfPages;
  int _currentPdfPage = 0;
  PDFViewController? _pdfViewController;
  bool _isLoading = true;
  DocumentEntity? _document;
  late DocumentBloc _documentBloc;
  bool _isOnline = true;

  // Để theo dõi thời gian giữa các lần cập nhật tiến độ
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
    _setupConnectivity();
    _loadDocument();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lưu tham chiếu đến DocumentBloc để sử dụng trong dispose
    _documentBloc = context.read<DocumentBloc>();
  }

  Future<void> _setupConnectivity() async {
    final Connectivity connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    _connectivitySubscription =
        connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    setState(() {
      _isOnline = result != ConnectivityResult.none;
    });
  }

  @override
  void dispose() {
    // Lưu tiến độ đọc trước khi dispose
    _saveReadingProgressSafely();

    // Giải phóng tài nguyên
    // _epubController?.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
  void _loadDocument() {
    _documentBloc.add(GetDocumentByIdEvent(widget.documentId));
  }
  void _loadDocumentContent() {
    if (_document == null) return;

    // Tải file từ Firebase Storage hoặc từ bộ nhớ cục bộ tùy thuộc vào kết nối
    context.read<DocumentReaderBloc>().add(
      LoadDocumentEvent(_document!, isOnline: _isOnline),
    );
  }

  void _saveReadingProgressSafely() {
    try {
      if (_document != null) {
        double progress = 0.0;
        int? currentPage;
        String? currentPosition;

        if (_document!.type == DocumentType.pdf) {
          if (_totalPdfPages != null && _totalPdfPages! > 0 && _currentPdfPage >= 0) {
            progress = _currentPdfPage / _totalPdfPages!;
            if (progress > 1.0) progress = 1.0;
            currentPage = _currentPdfPage;
          }
        } else if (_document!.type == DocumentType.epub) {
          if (_epubController != null) {
            try {
              // Lấy tiến độ đọc từ epubController
              final cfi = _epubController!.generateEpubCfi();
              if (cfi != null) {
                // Đây chỉ là giá trị giả định - cần thêm logic để tính chính xác
                progress = 0.5;
                currentPosition = cfi;
              }
            } catch (e) {
              print('Error getting EPUB progress: $e');
            }
          }
        }

        // Lưu tiến độ dựa trên trạng thái kết nối
        if (_isOnline) {
          // Lưu tiến độ lên Firebase
          _documentBloc.add(
            UpdateReadingProgressEvent(
              id: _document!.id,
              progress: progress,
              lastPage: currentPage,
              lastPosition: currentPosition,
            ),
          );
        } else {
          // Lưu tiến độ vào local storage
          _saveReadingProgressToLocal(
              _document!.id,
              progress,
              currentPage,
              currentPosition
          );
        }
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
        'timestamp': DateTime.now().millisecondsSinceEpoch,
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
      appBar: AppBar(
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
      drawer: _document?.type == DocumentType.epub ? _buildTableOfContentsDrawer() : null,
      body: BlocConsumer<DocumentBloc, DocumentState>(
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
      bottomNavigationBar: _document?.type == DocumentType.pdf ? _buildPdfNavigationBar() : null,
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

    // Kiểm tra file tồn tại
    if (!file.existsSync()) {
      throw Exception('File không tồn tại: ${file.path}');
    }

    if (document.type == DocumentType.epub) {
      return _buildEpubReader(file.path, document.lastReadPosition);
    } else {
      return _buildPdfReader(file.path, document.lastReadPage);
    }
  }

  Widget _buildEpubReader(String filePath, String? lastPosition) {
    try {
      print('Đang mở file EPUB từ: $filePath');
      _epubController ??= EpubController(
        document: EpubDocument.openFile(File(filePath)),
        epubCfi: lastPosition,
      );
      return EpubView(
        controller: _epubController!,
        builders: EpubViewBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          chapterDividerBuilder: (_) => const Divider(),
        ),
      );
    } catch (e) {
      print('Lỗi EPUB: $e');
      return Center(
        child: Text(
          'Không thể đọc file EPUB.\nLỗi: ${e.toString()}',
          style: TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }
  }


  Widget _buildPdfReader(String filePath, int? initialPage) {
    try {
      return PDFView(
        filePath: filePath,
        autoSpacing: true,
        pageSnap: true,
        swipeHorizontal: true,
        nightMode: false,
        onViewCreated: (PDFViewController controller) {
          setState(() {
            _pdfViewController = controller;
          });

          if (initialPage != null) {
            controller.setPage(initialPage);
          }
        },
        onRender: (pages) {
          setState(() {
            _totalPdfPages = pages;
            if (initialPage != null) {
              _currentPdfPage = initialPage;
            }
          });
        },
        onPageChanged: (page, total) {
          if (page != null) {
            setState(() {
              _currentPdfPage = page;
            });

            // Cập nhật tiến độ khi thay đổi trang
            _updateReadingProgress();
          }
        },
        onError: (error) {
          print('PDF Error: $error');
        },
        defaultPage: initialPage ?? 0,
      );
    } catch (e) {
      print('Error building PDF reader: $e');
      return Center(
        child: Text(
          'Không thể đọc file PDF.\nLỗi: ${e.toString()}',
          style: TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  Widget _buildTableOfContentsDrawer() {
    if (_document?.type != DocumentType.epub || _epubController == null) {
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
            Expanded(
              child: EpubViewTableOfContents(
                controller: _epubController!,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildPdfNavigationBar() {
    if (_document?.type != DocumentType.pdf || _totalPdfPages == null) {
      return null;
    }

    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: _currentPdfPage > 0
                  ? () {
                _pdfViewController?.setPage(_currentPdfPage - 1);
              }
                  : null,
            ),
            Text(
              'Trang ${_currentPdfPage + 1} / $_totalPdfPages',
              style: TextStyle(fontSize: 16),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right),
              onPressed: _currentPdfPage < (_totalPdfPages! - 1)
                  ? () {
                _pdfViewController?.setPage(_currentPdfPage + 1);
              }
                  : null,
            ),
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
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: _isOnline ? Colors.green : Colors.grey,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(_isOnline ? 'Đang đọc trực tuyến' : 'Đang đọc ngoại tuyến'),
              ],
            ),
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