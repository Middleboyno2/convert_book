import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/error/exceptions.dart';
import '../../../core/utils/enums.dart';
import '../../../core/utils/firebase_storage_helper.dart';
import '../../models/document_model.dart';

abstract class DocumentRemoteDataSource {
  Future<List<DocumentModel>> getDocuments();
  Future<DocumentModel> getDocumentById(String id);
  Future<DocumentModel> uploadDocument(File file, String title, {String? author});
  Future<void> deleteDocument(String id);
  Future<String> getDownloadUrl(String filePath);
  Future<bool> isAuthenticated();
  Future<DocumentModel> updateDocumentCategory(String id, Category category);
  Future<DocumentModel> updateReadingProgress(String id, double progress, int? lastPage, String? lastPosition);
  Future<DocumentModel> updateDocumentCover(String id, File coverFile);
}

class DocumentRemoteDataSourceImpl implements DocumentRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorageHelper storageHelper;

  DocumentRemoteDataSourceImpl({
    required this.firestore,
    required this.auth,
    required FirebaseStorage storage,
  }) : storageHelper = FirebaseStorageHelper(storage: storage, auth: auth);

  @override
  Future<bool> isAuthenticated() async {
    final user = auth.currentUser;
    print('AUTH CHECK: Current user is ${user != null ? "present" : "null"}');
    if (user != null) {
      print('AUTH CHECK: User ID = ${user.uid}');
    }
    return user != null;
  }

  String get userId {
    final user = auth.currentUser;
    if (user == null) {
      throw NotAuthenticatedException();
    }
    return user.uid;
  }

  @override
  Future<List<DocumentModel>> getDocuments() async {
    try {
      // Kiểm tra xác thực
      if (!await isAuthenticated()) {
        throw NotAuthenticatedException();
      }
      final documentSnapshot = await firestore
          .collection('documents')
          .where('userId', isEqualTo: userId)
          .get();

      return documentSnapshot.docs
          .map((doc) => DocumentModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Error getting documents: $e');
      if (e is NotAuthenticatedException) {
        rethrow;
      }
      throw ServerException();
    }
  }

  @override
  Future<DocumentModel> getDocumentById(String id) async {
    try {
      // Kiểm tra xác thực
      if (!await isAuthenticated()) {
        throw NotAuthenticatedException();
      }
      final documentSnapshot = await firestore
          .collection('documents')
          .doc(id)
          .get();

      if (!documentSnapshot.exists) {
        throw NotFoundException();
      }

      return DocumentModel.fromJson({...documentSnapshot.data()!, 'id': documentSnapshot.id});
    } catch (e) {
      debugPrint('Error getting document by id: $e');
      if (e is NotAuthenticatedException || e is NotFoundException) {
        throw e;
      }
      throw ServerException();
    }
  }

  @override
  Future<DocumentModel> uploadDocument(File file, String title, {String? author}) async {
    try {
      // Kiểm tra xác thực
      if (!await isAuthenticated()) {
        throw NotAuthenticatedException();
      }
      // lay path
      final String fileName = path.basename(file.path);
      final String fileExtension = path.extension(fileName).toLowerCase();

      // Kiểm tra loại file
      DocumentType docType;
      if (fileExtension == '.pdf') {
        docType = DocumentType.pdf;
      } else if (fileExtension == '.epub') {
        docType = DocumentType.epub;
      } else {
        throw UnsupportedFileException();
      }

      // Tải file lên Firebase Storage
      final String storagePath = await storageHelper.uploadDocument(file);

      // Trích xuất ảnh bìa (nếu có thể)
      String? coverUrl;
      try {
        coverUrl = await extractBookCover(file, docType);
      } catch (e) {
        print('Error extracting book cover: $e');
        // Tiếp tục mà không có ảnh bìa nếu có lỗi
      }

      // Tạo bản ghi tài liệu trong Firestore
      final docData = {
        'title': title,
        'uploadDate': DateTime.now().toIso8601String(),
        'filePath': storagePath,
        'type': docType.toString().split('.').last,
        'category': Category.unread.toString().split('.').last,
        'userId': userId,
        'author': author,
        'coverUrl': coverUrl,
        'readingProgress': 0.0, // Mặc định là 0%
        'lastReadTime': DateTime.now().toIso8601String(),
      };

      final docRef = await firestore.collection('documents').add(docData);

      return DocumentModel.fromJson({...docData, 'id': docRef.id});
    } catch (e) {
      if (e is UnsupportedFileException || e is NotAuthenticatedException) {
        throw e;
      }
      if (e.toString().contains('storage')) {
        throw StorageException();
      }
      throw ServerException();
    }
  }

  @override
  Future<void> deleteDocument(String id) async {
    try {
      // Kiểm tra xác thực
      if (!await isAuthenticated()) {
        throw NotAuthenticatedException();
      }

      // Lấy document để lấy đường dẫn storage
      final docSnapshot = await firestore.collection('documents').doc(id).get();

      if (!docSnapshot.exists) {
        throw NotFoundException();
      }

      final String filePath = docSnapshot.data()!['filePath'];

      // Xóa file từ storage bằng helper
      await storageHelper.deleteFile(filePath);

      // Xóa bản ghi từ Firestore
      await firestore.collection('documents').doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting document: $e');
      if (e is NotFoundException || e is NotAuthenticatedException) {
        throw e;
      }
      throw ServerException();
    }
  }

  @override
  Future<String> getDownloadUrl(String filePath) async {
    try {
      // Kiểm tra xác thực
      if (!await isAuthenticated()) {
        throw NotAuthenticatedException();
      }
      // Lấy URL download bằng helper
      return await storageHelper.getDownloadUrl(filePath);
    } catch (e) {
      debugPrint('Error getting download URL: $e');
      if (e is NotAuthenticatedException) {
        throw e;
      }
      throw ServerException();
    }
  }

  @override
  Future<DocumentModel> updateDocumentCategory(String id, Category category) async {
    try {
      // Kiểm tra xác thực
      if (!await isAuthenticated()) {
        throw NotAuthenticatedException();
      }
      // Lấy document hiện tại
      final documentSnapshot = await firestore.collection('documents').doc(id).get();

      if (!documentSnapshot.exists) {
        throw NotFoundException();
      }
      // Cập nhật category
      await firestore.collection('documents').doc(id).update({
        'category': category.toString().split('.').last,
      });
      // Lấy document đã cập nhật
      final updatedSnapshot = await firestore.collection('documents').doc(id).get();

      return DocumentModel.fromJson({...updatedSnapshot.data()!, 'id': updatedSnapshot.id});
    } catch (e) {
      debugPrint('Error updating document category: $e');
      if (e is NotFoundException || e is NotAuthenticatedException) {
        throw e;
      }
      throw ServerException();
    }
  }

  @override
  Future<DocumentModel> updateReadingProgress(String id, double progress, int? lastPage, String? lastPosition) async {
    try {
      // Kiểm tra xác thực
      if (!await isAuthenticated()) {
        throw NotAuthenticatedException();
      }

      // Lấy document hiện tại
      final documentSnapshot = await firestore.collection('documents').doc(id).get();

      if (!documentSnapshot.exists) {
        throw NotFoundException();
      }

      // Cập nhật tiến độ đọc và thời gian
      final updatedData = {
        'readingProgress': progress,
        'lastReadTime': DateTime.now().toIso8601String(),
      };

      // Thêm trang đọc cuối nếu có
      if (lastPage != null) {
        updatedData['lastReadPage'] = lastPage;
      }

      // Thêm vị trí đọc cuối nếu có
      if (lastPosition != null && lastPosition.isNotEmpty) {
        print("Updating lastReadPosition to: $lastPosition");
        updatedData['lastReadPosition'] = lastPosition;
      }

      // Nếu tiến độ đọc lớn hơn 80%, tự động cập nhật category sang completed
      if (progress > 0.8) {
        updatedData['category'] = Category.completed.toString().split('.').last;
      }

      // Cập nhật document
      await firestore.collection('documents').doc(id).update(updatedData);

      // Lấy lại document đã cập nhật
      final updatedSnapshot = await firestore.collection('documents').doc(id).get();

      return DocumentModel.fromJson({...updatedSnapshot.data()!, 'id': updatedSnapshot.id});
    } catch (e) {
      print("Error updating reading progress: $e");
      if (e is NotFoundException || e is NotAuthenticatedException) {
        throw e;
      }
      throw ServerException();
    }
  }

  @override
  Future<DocumentModel> updateDocumentCover(String id, File coverFile) async {
    try {
      // Kiểm tra xác thực
      if (!await isAuthenticated()) {
        throw NotAuthenticatedException();
      }
      final FirebaseStorage storage = FirebaseStorage.instance;

      // Lấy document hiện tại để kiểm tra
      final documentSnapshot = await firestore.collection('documents').doc(id).get();

      if (!documentSnapshot.exists) {
        throw NotFoundException();
      }
      // Tải ảnh bìa lên Firebase Storage
      final coverFileName = path.basename(coverFile.path);
      final coverStoragePath = 'covers/$userId/${id}_$coverFileName';
      final storageRef = storage.ref().child(coverStoragePath);

      // Tải file lên
      await storageRef.putFile(coverFile);

      // Lấy URL download
      final coverUrl = await storageRef.getDownloadURL();

      // Cập nhật document với URL ảnh bìa mới
      await firestore.collection('documents').doc(id).update({
        'coverUrl': coverUrl,
      });

      // Lấy lại document đã cập nhật
      final updatedSnapshot = await firestore.collection('documents').doc(id).get();

      return DocumentModel.fromJson({...updatedSnapshot.data()!, 'id': updatedSnapshot.id});
    } catch (e) {
      if (e is NotFoundException || e is NotAuthenticatedException) {
        throw e;
      }
      throw ServerException();
    }
  }

  Future<String?> extractBookCover(File file, DocumentType type) async {
    try {
      final FirebaseStorage storage = FirebaseStorage.instance;

      if (type == DocumentType.pdf) {
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/cover_${DateTime.now().millisecondsSinceEpoch}.png';
        final coverFile = File(tempPath);

        // Tạo một placeholder image đơn giản
        final pdf = pw.Document();
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Text('PDF Cover', style: pw.TextStyle(fontSize: 40)),
              );
            },
          ),
        );
        final bytes = await pdf.save();
        await coverFile.writeAsBytes(bytes);
        // Tải ảnh lên Firebase Storage
        final coverStoragePath = 'covers/$userId/${path.basename(file.path)}_cover.png';
        final storageRef = storage.ref().child(coverStoragePath);
        await storageRef.putFile(coverFile);
        // Lấy URL download
        final coverUrl = await storageRef.getDownloadURL();
        // Xóa file tạm
        await coverFile.delete();
        return coverUrl;
      } else if (type == DocumentType.epub) {
        // Sử dụng package epubx để đọc dữ liệu EPUB
        return null;
      }
      return null;
    } catch (e) {
      print('Error extracting cover: $e');
      return null;
    }
  }
}