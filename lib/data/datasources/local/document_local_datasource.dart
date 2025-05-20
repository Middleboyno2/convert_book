import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/error/exceptions.dart';

abstract class DocumentLocalDataSource {
  Future<File> saveDocumentLocally(String url, String fileName);
  Future<bool> isDocumentCached(String fileName);
  Future<File> getLocalDocument(String fileName);
}

class DocumentLocalDataSourceImpl implements DocumentLocalDataSource {
  // final Future<Directory> Function() getDirectory;
  // DocumentLocalDataSourceImpl({
  //   required this.getDirectory,
  // });

  @override
  Future<bool> isDocumentCached(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      return file.existsSync() && await file.length() > 0;
    } catch (e) {
      print('Error checking cached file: $e');
      return false;
    }
  }

  @override
  Future<File> saveDocumentLocally(String url, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      // Xóa file cũ nếu tồn tại
      if (file.existsSync()) {
        await file.delete();
      }
      // Tạo thư mục nếu chưa tồn tại
      if (!directory.existsSync()) {
        await directory.create(recursive: true);
      }
      // Tải file từ URL
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw CacheException('Không thể tải file từ firebase: ${response.statusCode}');
      }
      // Lưu file
      final sink = file.openWrite();
      await response.pipe(sink);
      await sink.flush();
      await sink.close();

      // Kiểm tra file đã được lưu thành công
      if (!file.existsSync() || await file.length() == 0) {
        throw CacheException('File lưu không hợp lệ');
      }

      return file;
    } catch (e) {
      print('Error saving document locally: $e');
      throw CacheException('Không thể lưu file: ${e.toString()}');
    }
  }

  @override
  Future<File> getLocalDocument(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      if (!file.existsSync()) {
        throw CacheException('File không tồn tại trong bộ nhớ cục bộ');
      }

      if (await file.length() == 0) {
        throw CacheException('File rỗng');
      }

      return file;
    } catch (e) {
      print('Error getting local document: $e');
      throw CacheException('Không thể đọc file: ${e.toString()}');
    }
  }
}