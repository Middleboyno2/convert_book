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
  final Future<Directory> Function() getDirectory;


  DocumentLocalDataSourceImpl({
    required this.getDirectory,
  });

  @override
  Future<File> saveDocumentLocally(String url, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      // Download file from URL
      // Using HttpClient to download file
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();

      final bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);

      return file;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<bool> isDocumentCached(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      return file.existsSync();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<File> getLocalDocument(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      if (!file.existsSync()) {
        throw CacheException();
      }

      return file;
    } catch (e) {
      throw CacheException();
    }
  }
}