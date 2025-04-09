import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomPdfReader extends StatefulWidget {
  final File file;
  final int initialPage;

  const CustomPdfReader({
    super.key,
    required this.file,
    this.initialPage = 0,
  });

  @override
  _CustomPdfReaderState createState() => _CustomPdfReaderState();
}

class _CustomPdfReaderState extends State<CustomPdfReader> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  late GlobalKey<SfPdfViewerState> _pdfViewerKey;
  bool _isLoading = true;
  int _pageCount = 0;
  int _currentPage = 0;
  double _zoom = 1.0;
  bool _showToolbar = true;

  @override
  void initState() {
    super.initState();
    _pdfViewerKey = GlobalKey();
    _currentPage = widget.initialPage;

    // Đặt hẹn giờ để ẩn thanh công cụ sau một thời gian
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showToolbar = false;
        });
      }
    });
  }

  void _toggleToolbar() {
    setState(() {
      _showToolbar = !_showToolbar;
    });
  }

  void _saveReadingProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'pdf_last_page_${widget.file.path.hashCode}';
      await prefs.setInt(key, _currentPage);

      // Lưu tiến độ đọc
      if (_pageCount > 0) {
        final progress = (_currentPage + 1) / _pageCount;
        await prefs.setDouble('pdf_progress_${widget.file.path.hashCode}', progress);
      }
    } catch (e) {
      print('Lỗi khi lưu tiến độ đọc: $e');
    }
  }

  @override
  void dispose() {
    _saveReadingProgress();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _toggleToolbar,
        child: Stack(
          children: [
            // PDF Viewer
            SfPdfViewer.file(
              widget.file,
              key: _pdfViewerKey,
              controller: _pdfViewerController,
              initialScrollOffset: Offset(0, 0),
              initialZoomLevel: _zoom,
              enableDoubleTapZooming: true,
              enableTextSelection: true,
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                setState(() {
                  _isLoading = false;
                  _pageCount = details.document.pages.count;

                  // Set initial page after document loads
                  if (widget.initialPage > 0 && widget.initialPage < _pageCount) {
                    Future.microtask(() {
                      _pdfViewerController.jumpToPage(widget.initialPage);
                    });
                  }
                });
              },
              onPageChanged: (PdfPageChangedDetails details) {
                setState(() {
                  _currentPage = details.newPageNumber - 1;
                });
              },
              onZoomLevelChanged: (PdfZoomDetails details) {
                setState(() {
                  _zoom = details.newZoomLevel;
                });
              },
            ),

            // Loading indicator
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),

            // Toolbar kiểm soát - hiển thị/ẩn khi nhấn vào màn hình
            if (_showToolbar)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.black.withOpacity(0.6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nút quay lại trang trước
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: _currentPage > 0
                            ? () {
                          _pdfViewerController.previousPage();
                        }
                            : null,
                      ),

                      // Hiển thị số trang
                      Text(
                        'Trang ${_currentPage + 1} / $_pageCount',
                        style: TextStyle(color: Colors.white),
                      ),

                      // Nút đến trang tiếp theo
                      IconButton(
                        icon: Icon(Icons.arrow_forward, color: Colors.white),
                        onPressed: (_pageCount > 0 && _currentPage < _pageCount - 1)
                            ? () {
                          _pdfViewerController.nextPage();
                        }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),

            // Thanh công cụ mở rộng (tùy chọn)
            if (_showToolbar)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.black.withOpacity(0.6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Nút thu nhỏ
                      IconButton(
                        icon: Icon(Icons.zoom_out, color: Colors.white),
                        onPressed: () {
                          _pdfViewerController.zoomLevel = _zoom - 0.25;
                        },
                      ),

                      // Nút phóng to
                      IconButton(
                        icon: Icon(Icons.zoom_in, color: Colors.white),
                        onPressed: () {
                          _pdfViewerController.zoomLevel = _zoom + 0.25;
                        },
                      ),

                      // // Nút tìm kiếm
                      // IconButton(
                      //   icon: Icon(Icons.search, color: Colors.white),
                      //   onPressed: () {
                      //     _pdfViewerKey.currentState?.;
                      //   },
                      // ),

                      // Nút bookmark (tùy chọn)
                      IconButton(
                        icon: Icon(Icons.bookmark_border, color: Colors.white),
                        onPressed: () {
                          // Triển khai tính năng bookmark
                          _pdfViewerKey.currentState?.openBookmarkView();
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}