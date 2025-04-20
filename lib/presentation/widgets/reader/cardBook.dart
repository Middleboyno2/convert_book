import 'dart:io';

import 'package:doantotnghiep/presentation/widgets/menu_item/menu_item_book.dart';
import 'package:epub_decoder/epub.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:popover/popover.dart';
import '../../../config/colors/kcolor.dart';
import '../../../core/utils/enums.dart';
import '../../../domain/entities/document_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../bloc/document/document_bloc.dart';
import '../../bloc/document/document_event.dart';
import '../../bloc/reader/reader_bloc.dart';
import '../../bloc/reader/reader_event.dart';
import '../../bloc/reader/reader_state.dart';

class BookCard extends StatefulWidget {
  final DocumentEntity document;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.document,
    required this.onTap,
  });
  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  String? coverPath;
  File? _localFile;
  File? _coverFile;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  void _loadDocument() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      // Get download URL from bloc
      context.read<DocumentReaderBloc>().add(
        LoadDocumentEvent(widget.document, isOnline: true),
      );
        } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
      print('Error in _loadDocument: $e');
    }
  }

  void _processLocalFile(File file) async {
    try {
      // Save local file reference
      setState(() {
        _localFile = file;
      });

      // Only process EPUB files for cover extraction
      if (widget.document.type == DocumentType.epub) {
        await extractEpubCover(_localFile!);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
      print('Error processing local file: $e');
    }
  }

  void deleteDocument(String uid){
    context.read<DocumentBloc>().add(DeleteDocumentEvent(uid));
  }

  Future<void>  extractEpubCover(File file) async{
    final epub = await readEpubFromFile(file);
    // Lấy ảnh bìa
    if (epub.cover != null) {
      final bytes = epub.cover!.fileContent;

      // Lưu ảnh vào thư mục app
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/${widget.document.id}_cover.png';
      final file = File(path);
      await file.writeAsBytes(bytes);
      print(file);

      setState(() {
        coverPath = path;

      });
    } else {
      setState(() {
        _hasError= true;
      });
      print('error');
    }
  }

  Future<Epub> readEpubFromFile(File file) async {
    try {
      // Đọc bytes từ file
      final bytes = await file.readAsBytes();

      final epub = Epub.fromBytes(bytes);

      return epub;
    } catch (e) {
      print('Lỗi đọc file EPUB: $e');
      rethrow;
    }
  }
  @override
  Widget build(BuildContext context) {
    // Tính phần trăm tiến độ đọc
    final progress = widget.document.readingProgress ?? 0.0;
    final progressPercent = (progress * 100).toInt();

    return BlocListener<DocumentReaderBloc, DocumentReaderState>(
        listener: (context, state) {
      if (state is DocumentReaderLoaded &&
          state.document.id == widget.document.id) {
        _processLocalFile(state.file);
      } else if (state is DocumentReaderError) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = state.message;
        });
      }
    },
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: (){
          // deleteDocument(widget.document.id);
          showPopover(
            context: context,
            bodyBuilder: (context) => MenuItemBook(),
            width: 250,
            height: 100
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover and progress indicator
              Stack(
                children: [
                  // Book cover
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 150,
                      child: _buildCoverImage(),
                    ),
                  ),

                  // Progress indicator
                  Positioned(
                    top: 8,
                    left: 8,
                    child: CircularPercentIndicator(
                      radius: 18.0,
                      lineWidth: 3.0,
                      percent: progress,
                      center: Text(
                        "$progressPercent%",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      progressColor: Kolors.kGold,
                      backgroundColor: Colors.grey.withOpacity(0.3),
                    ),
                  ),

                  // Play button
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Kolors.kGold,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Book title
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.document.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Author (if available)
              widget.document.author != null?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  widget.document.author!,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ):
              SizedBox.shrink(),

              // Position/index indicator
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.document.lastReadPage != null
                      ? 'Trang ${widget.document.lastReadPage}'
                      : 'Trang 0',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getBookIcon() {
    return widget.document.type == DocumentType.pdf
        ? Icons.picture_as_pdf
        : Icons.book;
  }

  Widget _buildCoverImage() {
    // If loading
    if (_isLoading) {
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Kolors.kGold),
          ),
        ),
      );
    }

    // If error
    if (_hasError) {
      return Container(
        color: Colors.grey[800],
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getBookIcon(),
                size: 50,
                color: Colors.grey,
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Error',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // If we have extracted a cover image
    if (_coverFile != null && _coverFile!.existsSync()) {
      return Image.file(
        _coverFile!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderCover();
        },
      );
    }

    // If the document has a cover URL
    if(coverPath != null) {
      return Image.file(
        File(coverPath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderCover();
        },
      );
    }

    // Fallback to placeholder
    return _buildPlaceholderCover();
  }

  Widget _buildPlaceholderCover() {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Icon(
          _getBookIcon(),
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }
}