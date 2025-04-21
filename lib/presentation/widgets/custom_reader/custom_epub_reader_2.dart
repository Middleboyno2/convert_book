import 'dart:io';

import 'package:epub_decoder/epub_decoder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';


class CustomEpubReader2 extends StatefulWidget {
  final File file;
  final double lastPosition;
  final int lastPage;
  const CustomEpubReader2({super.key, required this.file, required this.lastPosition, required this.lastPage});

  @override
  State<CustomEpubReader2> createState() => _CustomEpubReader2State();
}

class _CustomEpubReader2State extends State<CustomEpubReader2> {
  List<Section> sectionEpub = [];
  List<String> content = [];
  bool _isLoading = true;
  ScrollController _scrollController = ScrollController();
  List<Map<String, String>> chapterFiles = [];
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      setState(() {
        _progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
      });
    });
    extractEpub(widget.file);
  }
  Future<void> extractEpub(File file) async{
    final epub = await readEpubFromFile(file);
    final dir = await getApplicationDocumentsDirectory();
    // Lấy sections
    try{
      sectionEpub = epub.sections;
      for (var section in sectionEpub) {
        final href = section.content.href; // ví dụ: Text/p001.xhtml
        final filename = href.split('/').last;
        final name = section.content.fileName;

        final bytes = section.content.fileContent; // Uint8List
        final path = '${dir.path}/$filename';
        final file = File(path);
        await file.writeAsBytes(bytes);
        chapterFiles.add({'title': name, 'path': path});
      }
      // load toan bo section_path de lay noi dung
      await loadAllContent();
      setState(() {
        _isLoading = false;
      });
    }catch(e){
      print('Error extract Epub file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error extract Epub file: ${e.toString()}')),
      );
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
  Future<void> loadAllContent() async{
    for(var i in chapterFiles){
      final htmlPath = i['path'] ?? '';
        await loadHtmlContent(htmlPath);
    }
  }

  Future<void> loadHtmlContent(String htmlFilePath) async {
    try {
      final rawHtml = await File(htmlFilePath).readAsString();

      // Tách phần thân từ <body> nếu có
      String htmlContent = rawHtml;
      print("RAW HTML:\n$rawHtml");
      final bodyStart = rawHtml.indexOf('<body');
      final bodyEnd = rawHtml.indexOf('</body>');
      if (bodyStart != -1 && bodyEnd != -1) {
        final startTagEnd = rawHtml.indexOf('>', bodyStart) + 1;
        htmlContent = rawHtml.substring(startTagEnd, bodyEnd);
      }
      // phần này phục vụ cho việc chuyển nội dung file thành String sử dụng cho text to speech
      // final plainText = extractTextFromHtml(rawHtml);
      // print("Plain text: $plainText");

      setState(() {
        // _plainText = plainText;
        content.add(htmlContent);
      });
    } catch (e) {
      print('Lỗi load HTML: $e');
      setState(() {
        // _plainText = 'Không đọc được nội dung';
        content.add('Không đọc được nội dung');
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return _isLoading
      ? const Center(child: CircularProgressIndicator())
      : SizedBox(
        height: ScreenUtil().screenHeight,
        width: ScreenUtil().screenWidth,
        child: SingleChildScrollView(
          child: SelectionArea(
            // onSelectionChanged: (SelectedContent? content) {
            //   _selectedContent = content?.plainText ?? '';
            // },
            contextMenuBuilder: (context, selectableRegionState) {
              return AdaptiveTextSelectionToolbar.buttonItems(
                anchors: selectableRegionState.contextMenuAnchors,
                buttonItems: [
                  ContextMenuButtonItem(
                    onPressed: () {
                      selectableRegionState.copySelection(SelectionChangedCause.toolbar);
                    },
                    type: ContextMenuButtonType.copy,
                  ),
                  ContextMenuButtonItem(
                    onPressed: () {
                      selectableRegionState.selectAll(SelectionChangedCause.toolbar);
                    },
                    type: ContextMenuButtonType.selectAll,
                  ),
                  ContextMenuButtonItem(
                    onPressed: () {
                      // addMarkdown(_selectedContent);
                    },
                    type: ContextMenuButtonType.custom,
                    label: 'markdown',
                  ),
                ],
              );
            },
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: chapterFiles.length,
              itemBuilder: (context, index){
                final htmlFilePath = content[index];
                return Html(
                  data: htmlFilePath,
                  onLinkTap: (url, _, __) {
                    if (url == null) return;
                    final uri = Uri.parse(url);
                    launchUrl(uri, mode: LaunchMode.externalApplication).catchError((e) {
                      debugPrint("Không mở được link: $e");
                      return false;
                    });
                  },
                );
              }
            ),
        ),
            ),
      );

  }
}


