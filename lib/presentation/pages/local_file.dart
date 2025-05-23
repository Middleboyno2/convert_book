import 'dart:io';
import 'package:doantotnghiep/config/colors/kcolor.dart';
import 'package:doantotnghiep/presentation/widgets/dialog/dialog_nav_to_login.dart';
import 'package:doantotnghiep/presentation/widgets/dialog/show_loading_dialog.dart';
import 'package:epub_decoder/epub.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../bloc/document/document_bloc.dart';
import '../bloc/document/document_event.dart';
import '../bloc/document/document_state.dart';
import '../widgets/dialog/dialog_confirm_add_book.dart';

class FilePickerPage extends StatefulWidget {
  const FilePickerPage({Key? key}) : super(key: key);

  @override
  _FilePickerPageState createState() => _FilePickerPageState();
}

class _FilePickerPageState extends State<FilePickerPage> {
  List<File> _files = [];
  Set<File> _selectedFiles = {};
  bool _isLoading = false;
  int _pendingUploads = 0;
  int _completedUploads = 0;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // _loadRecentFiles();
  }

  Future<void> _loadRecentFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use FilePicker with withData option to get bytes for cloud storage files
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub'],
        allowMultiple: true,
        withData: true, // Important: get file data as bytes
      );

      if (result != null && result.files.isNotEmpty) {
        for (var pickedFile in result.files) {
          try {
            File? file;
            if (pickedFile.bytes != null) {
              // Google Drive or other cloud file
              final tempDir = await getTemporaryDirectory();
              final tempFile = File('${tempDir.path}/${pickedFile.name}');
              await tempFile.writeAsBytes(pickedFile.bytes!);
              file = tempFile;
            } else if (pickedFile.path != null) {
              final maybeFile = File(pickedFile.path!);
              if (await maybeFile.exists()) {
                file = maybeFile;
              }
            }
            if(file != null){
              _addFileIfNotDuplicate(file);
            }
          } catch (e) {
            print('Error processing file ${pickedFile.name}: $e');
            // Continue with next file
          }
        }
      }
    } catch (e) {
      print('Error picking files: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể truy cập file: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addFileIfNotDuplicate(File file) {
    bool isDuplicate = false;
    for (var existingFile in _files) {
      final selectedFileName = path.basename(existingFile.path);
      if (selectedFileName == path.basename(file.path)) {
        isDuplicate = true;
        break;
      }
    }
    // Only add if not a duplicate
    if (!isDuplicate) {
      setState(() {
        _files.add(file);
        _selectedFiles.add(file);
      });
    }
  }

  void _selectFile(File file) {
    if (_isUploading) return; // Không cho phép thay đổi selection khi đang upload

    setState(() {
      if (_selectedFiles.contains(file)) {
        _selectedFiles.remove(file);
      } else {
        _selectedFiles.add(file);
      }
    });
  }
  // xac nhan day file lên firebase
  Future<void> _confirmAddBook() async {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một file'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Hiển thị dialog xác nhận
    final result = await showAddBookDialog(
      context: context,
      selectedFiles: _selectedFiles,
    );

    // Nếu người dùng xác nhận việc tải lên
    if (result == true) {
      setState(() {
        _isUploading = true;
      });
      _uploadSelectedFiles();
    }
  }

  void _uploadSelectedFiles() async{
    // Đặt lại bộ đếm
    _pendingUploads = _selectedFiles.length;
    _completedUploads = 0;

    // Hiển thị dialog loading
    showLoadingDialog(context);

    // Lặp qua từng file đã chọn và tải lên
    for (var file in _selectedFiles) {
      final epub = await readEpubFromFile(file);
      final String author = epub.authors.join(',');
      print(author);
      final String title = epub.title;
      print(title);
      // final fileName = path.basenameWithoutExtension(file.path);
      _uploadSingleFile(file, title, author);
    }
  }

  // Tải lên một file
  void _uploadSingleFile(File file, String title, String author) {
    // Gọi BLoC để tải lên file
    context.read<DocumentBloc>().add(
      UploadDocumentEvent(
        file: file,
        title: title,
        author: author
      ),
    );
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

  // điều hướng đến trang đăng nhập nếu chưa đăng nhập
  void _navigateToLoginPage(BuildContext context) {
    // Hiển thị dialog thông báo
    showLoginRequiredDialog(context: context, onAddPressed: () {
      _loadRecentFiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Internal storage',
        ),
        leading: BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              _confirmAddBook();
            },
          ),
        ],
      ),
      body: BlocListener<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state is DocumentUploaded) {
            // Tăng số lượng upload đã hoàn thành
            setState(() {
              _completedUploads++;
            });
            // Kiểm tra xem đã hoàn thành tất cả upload chưa
            if (_completedUploads >= _pendingUploads) {
              // Đã hoàn thành tất cả upload, đóng dialog loading
              if (context.canPop()) {
                context.pop();
              }
              // Hiển thị thông báo thành công
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tất cả sách đã được thêm thành công'),
                  backgroundColor: Colors.green,
                ),
              );
              // Quay về trang chủ
              context.go('/entrypoint');
            }
          } else if (state is DocumentError) {
            // Tăng số lượng upload đã xử lý (dù lỗi)
            setState(() {
              _completedUploads++;
            });

            // Hiển thị thông báo lỗi
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );

            // Nếu đã xử lý tất cả các file (dù thành công hay lỗi)
            if (_completedUploads >= _pendingUploads) {
              // Đóng dialog loading
              if (context.canPop()) {
                context.pop();
              }
              setState(() {
                _isUploading = false;
              });
              // Quay về trang chủ nếu ít nhất 1 file được tải lên thành công
              if (_completedUploads > 0) {
                context.go('/');
              }
            }
          } else if (state is DocumentAuthenticationRequired) {
            // Đóng dialog loading nếu đang hiển thị
            if (context.canPop()) {
              context.pop();
            }
            setState(() {
              _isUploading = false;
            });
            // Điều hướng đến trang đăng nhập
            _navigateToLoginPage(context);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị thông tin số file đã chọn
            if (_files.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Đã chọn ${_selectedFiles.length}/${_files.length} file',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_files.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No files selected. Tap the button below to select a file.',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(child: _buildFileList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadRecentFiles,
        backgroundColor: Kolors.kGold,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFileList() {
    return ListView.builder(
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final file = _files[index];
        final fileName = path.basename(file.path);
        final fileDate = _getFileModifiedDate(file);
        final isSelected = _selectedFiles.contains(file);

        return ListTile(
          leading: Icon(
            _getFileIcon(file.path),
          ),
          title: Text(
            fileName,
          ),
          subtitle: Text(
            fileDate,
          ),
          trailing: isSelected
              ? Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Kolors.kGold,
            ),
            child: const Icon(
              Icons.check,
              size: 16,
            ),
          )
              : const Icon(Icons.circle_outlined),
          onTap: () => _selectFile(file),
          enabled: !_isUploading,
        );
      },
    );
  }

  IconData _getFileIcon(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    if (extension == '.pdf') {
      return Icons.picture_as_pdf;
    } else if (extension == '.epub') {
      return Icons.book;
    }
    return Icons.insert_drive_file;
  }

  String _getFileModifiedDate(File file) {
    try {
      final stat = file.statSync();
      final dateTime = stat.modified;
      return '${dateTime.day} tháng ${dateTime.month} ${dateTime.year}';
    } catch (e) {
      return '';
    }
  }

}