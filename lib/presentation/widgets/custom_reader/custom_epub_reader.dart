import 'dart:io';
import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart' hide Image;
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:shared_preferences/shared_preferences.dart';

class CustomEpubReader extends StatefulWidget {
  final File file;
  final String? lastPosition;

  const CustomEpubReader({
    super.key,
    required this.file,
    this.lastPosition,
  });

  @override
  _CustomEpubReaderState createState() => _CustomEpubReaderState();
}

class _CustomEpubReaderState extends State<CustomEpubReader> {
  EpubBook? _epubBook;
  List<EpubChapter>? _chapters;
  List<Map<String, dynamic>> _flatChapters = [];
  int _currentChapter = 0;
  bool _isLoading = true;
  PageController _pageController = PageController();
  double _textSize = 16.0;
  String _fontFamily = 'Roboto';
  Color _backgroundColor = Colors.white;
  Color _textColor = Colors.black87;

  @override
  void initState() {
    super.initState();
    _loadEpub();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _textSize = prefs.getDouble('epub_text_size') ?? 16.0;
      _fontFamily = prefs.getString('epub_font_family') ?? 'Roboto';
      _backgroundColor = Color(prefs.getInt('epub_background_color') ?? Colors.white.value);
      _textColor = Color(prefs.getInt('epub_text_color') ?? Colors.black87.value);
    });
  }

  Future<void> _loadEpub() async {
    try {
      setState(() {
        _isLoading = true;
      });
      // Read EPUB file as bytes
      final bytes = await widget.file.readAsBytes();
      // Open the book from bytes
      final epubBookRef = await EpubReader.openBook(bytes.toList());
      // Get the full book content
      _epubBook = await EpubReader.readBook(bytes);

      // Process chapters and HTML content
      await _processEpubContent(epubBookRef);

      // Find starting position if provided
      if (widget.lastPosition != null) {
        // Parse the position and set current chapter
        _currentChapter = _parsePositionToChapterIndex(widget.lastPosition!) ?? 0;
      }

      _pageController = PageController(initialPage: _currentChapter);

      setState(() {
        _isLoading = false;
      });
    } catch (e, stack) {
      print('Error loading EPUB: $e');
      print('Stack trace: $stack');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _processEpubContent(EpubBookRef epubBookRef) async {
    // Get all the HTML content files
    final contentMap = await EpubReader.readTextContentFiles(epubBookRef.Content!.Html!);

    // Get chapter information
    _chapters = _epubBook?.Chapters ?? [];

    // Flatten all chapters with content
    List<Map<String, dynamic>> flatChapters = [];

    // Process all HTML files if no chapters are available or as fallback
    if (_chapters == null || _chapters!.isEmpty) {
      // Use content files as chapters
      contentMap.forEach((key, value) {
        String title = key.split('/').last.replaceAll('.html', '').replaceAll('_', ' ');
        String content = value.Content ?? '';

        flatChapters.add({
          'title': title,
          'htmlContent': content,
          'textContent': _extractTextFromHtml(content),
          'id': key,
        });
      });
    } else {
      // Process actual chapters
      _processChaptersRecursively(_chapters!, flatChapters, contentMap);
    }

    if (flatChapters.isEmpty && contentMap.isNotEmpty) {
      // Fallback if no chapters were processed
      contentMap.forEach((key, value) {
        String title = key.split('/').last.replaceAll('.html', '').replaceAll('_', ' ');
        String content = value.Content ?? '';

        flatChapters.add({
          'title': title,
          'htmlContent': content,
          'textContent': _extractTextFromHtml(content),
          'id': key,
        });
      });
    }

    _flatChapters = flatChapters;
  }

  void _processChaptersRecursively(
      List<EpubChapter> chapters,
      List<Map<String, dynamic>> flatChapters,
      Map<String, EpubTextContentFile> contentMap
      ) {
    for (final chapter in chapters) {
      String? htmlContent;

      // Try to find content for this chapter
      if (chapter.ContentFileName != null && contentMap.containsKey(chapter.ContentFileName)) {
        htmlContent = contentMap[chapter.ContentFileName]?.Content;
      }

      // Only add chapter if it has content
      if (htmlContent != null) {
        flatChapters.add({
          'title': chapter.Title,
          'htmlContent': htmlContent,
          'textContent': _extractTextFromHtml(htmlContent),
          'id': chapter.ContentFileName,
        });
      }

      // Process subchapters
      if (chapter.SubChapters != null && chapter.SubChapters!.isNotEmpty) {
        _processChaptersRecursively(chapter.SubChapters!, flatChapters, contentMap);
      }
    }
  }

  String _extractTextFromHtml(String html) {
    try {
      final document = htmlparser.parse(html);
      return document.body?.text ?? '';
    } catch (e) {
      print('Error extracting text from HTML: $e');
      return '';
    }
  }

  int? _parsePositionToChapterIndex(String position) {
    // Parse the position string to get the chapter index
    try {
      final regex = RegExp(r'chapter(\d+)');
      final match = regex.firstMatch(position);
      if (match != null) {
        final index = int.parse(match.group(1)!) - 1;
        if (index >= 0 && index < _flatChapters.length) {
          return index;
        }
      }
    } catch (e) {
      print('Error parsing position: $e');
    }
    return null;
  }

  String _generatePosition() {
    // Generate a position string
    return 'chapter${_currentChapter + 1}';
  }

  void _saveReadingProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final position = _generatePosition();
      final key = 'epub_position_${widget.file.path.hashCode}';
      await prefs.setString(key, position);

      // Calculate reading progress percentage
      if (_flatChapters.isNotEmpty) {
        final progress = (_currentChapter + 1) / _flatChapters.length;
        await prefs.setDouble('epub_progress_${widget.file.path.hashCode}', progress);
      }
    } catch (e) {
      print('Error saving reading progress: $e');
    }
  }

  @override
  void dispose() {
    _saveReadingProgress();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_flatChapters.isEmpty) {
      return Center(
        child: Text('Không thể đọc nội dung EPUB này. Vui lòng thử file khác.'),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(_epubBook?.Title ?? 'EPUB Reader'),
        actions: [
          IconButton(
            icon: Icon(Icons.format_size),
            onPressed: _showTextSettings,
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: _showTableOfContents,
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _flatChapters.length,
        itemBuilder: (context, index) {
          final chapter = _flatChapters[index];
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (chapter['title'] != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      chapter['title'],
                      style: TextStyle(
                        fontSize: _textSize + 4,
                        fontWeight: FontWeight.bold,
                        fontFamily: _fontFamily,
                        color: _textColor,
                      ),
                    ),
                  ),
                Html(
                  data: chapter['htmlContent'] ?? '<p>Không có nội dung</p>',
                  style: {
                    "body": Style(
                      fontSize: FontSize(_textSize),
                      fontFamily: _fontFamily,
                      color: _textColor,
                    ),
                    "p": Style(
                      margin: Margins.symmetric(horizontal: 8),
                    ),
                  },
                ),
              ],
            ),
          );
        },
        onPageChanged: (index) {
          setState(() {
            _currentChapter = index;
          });
        },
      ),
      bottomNavigationBar: Container(
        height: 50,
        color: Colors.black87,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _currentChapter > 0
                  ? () {
                _pageController.previousPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
                  : null,
            ),
            Text(
              'Chương ${_currentChapter + 1}/${_flatChapters.length}',
              style: TextStyle(color: Colors.white),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward, color: Colors.white),
              onPressed: _currentChapter < _flatChapters.length - 1
                  ? () {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showTextSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Cỡ chữ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: _textSize,
                    min: 12,
                    max: 24,
                    divisions: 6,
                    label: _textSize.round().toString(),
                    onChanged: (value) {
                      setModalState(() {
                        _textSize = value;
                      });
                      setState(() {
                        _textSize = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Text('Chủ đề', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        child: Text('Sáng'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _backgroundColor = Colors.white;
                            _textColor = Colors.black87;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ElevatedButton(
                        child: Text('Tối'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _backgroundColor = Colors.black;
                            _textColor = Colors.white;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ElevatedButton(
                        child: Text('Nâu'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF8F1E3),
                          foregroundColor: Color(0xFF5F4B32),
                        ),
                        onPressed: () {
                          setState(() {
                            _backgroundColor = Color(0xFFF8F1E3);
                            _textColor = Color(0xFF5F4B32);
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showTableOfContents() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mục lục',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _flatChapters.length,
                      itemBuilder: (context, index) {
                        final chapter = _flatChapters[index];
                        return ListTile(
                          title: Text(chapter['title'] ?? 'Chương ${index + 1}'),
                          selected: index == _currentChapter,
                          onTap: () {
                            Navigator.pop(context);
                            _pageController.animateToPage(
                              index,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Phương thức để trích xuất tất cả văn bản từ EPUB (có thể sử dụng cho text-to-speech)
  String extractAllText() {
    List<String> allText = [];
    for (var chapter in _flatChapters) {
      if (chapter['textContent'] != null && chapter['textContent'].isNotEmpty) {
        allText.add(chapter['textContent']);
      }
    }
    return allText.join('\n\n');
  }
}