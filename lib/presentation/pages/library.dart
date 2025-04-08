import 'package:doantotnghiep/domain/entities/document_entity.dart';
import 'package:doantotnghiep/presentation/bloc/document/document_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/document/document_event.dart';
import 'package:doantotnghiep/presentation/bloc/document/document_state.dart';
import 'package:doantotnghiep/presentation/widgets/CustomSearch.dart';
import 'package:doantotnghiep/presentation/widgets/empty/empty_book.dart';
import 'package:doantotnghiep/presentation/widgets/tab_bar.dart';
import 'package:doantotnghiep/presentation/widgets/tabbar/completed.dart';
import 'package:doantotnghiep/presentation/widgets/tabbar/unread.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final TextEditingController _searchController = TextEditingController();
  bool isSearch = false;
  // Thêm biến lưu trữ danh sách tài liệu đã tải xuống
  List<DocumentEntity> _documents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu khi trang được tạo
    _loadBooks();
  }

  void _loadBooks() {
    // Gọi BLoC để tải danh sách tài liệu
    context.read<DocumentBloc>().add(GetDocumentsEvent());
  }

  void changeSearch() {
    setState(() {
      isSearch = !isSearch;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(75), // search 45 + tabbar 30
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomSearch(controller: _searchController),
                CustomTabBar(),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                context.push('/storage');
              },
              icon: Icon(Icons.add),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_vert),
            ),
          ],
        ),
        // Bọc TabBarView trong BlocConsumer để xử lý state
        body: BlocConsumer<DocumentBloc, DocumentState>(
          listener: (context, state) {
            if (state is DocumentsLoaded) {
              // Cập nhật state khi dữ liệu được tải xuống
              setState(() {
                _documents = state.documents;
                _isLoading = false;
                _errorMessage = null;
              });
            } else if (state is DocumentError) {
              // Xử lý lỗi
              setState(() {
                _isLoading = false;
                _errorMessage = state.message;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is DocumentLoading) {
              setState(() {
                _isLoading = true;
              });
            } else if (state is DocumentAuthenticationRequired) {
              // Xử lý yêu cầu đăng nhập
              context.push('/auth');
            } else if (state is DocumentUploaded) {
              // Tải lại danh sách sau khi tải lên
              _loadBooks();
            } else if (state is DocumentDeleted) {
              // Tải lại danh sách sau khi xóa
              _loadBooks();
            } else if (state is DocumentCategoryUpdated ||
                state is ReadingProgressUpdated ||
                state is DocumentCoverUpdated) {
              // Tải lại danh sách sau khi cập nhật
              _loadBooks();
            }
          },
          builder: (context, state) {
            // Hiển thị loading nếu đang tải
            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Hiển thị lỗi nếu có
            if (_errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_errorMessage!),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadBooks,
                      child: Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            // Hiển thị TabBarView với dữ liệu đã tải
            return TabBarView(
              children: [
                // Truyền documents vào UnreadBook
                UnreadBook(documents: _documents),
                // Truyền documents vào CompletedBook
                CompletedBook(documents: _documents),
              ],
            );
          },
        ),
      ),
    );
  }
}