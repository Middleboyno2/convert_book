// lib/data/datasources/remote/document_remote_datasource.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/utils/enums.dart';
import '../../../core/utils/firebase_storage_helper.dart';
import '../../../domain/entities/document_entity.dart';
import '../../models/document_model.dart';

abstract class DocumentRemoteDataSource {
  Future<List<DocumentModel>> getDocuments();
  Future<DocumentModel> getDocumentById(String id);
  Future<DocumentModel> uploadDocument(File file, String title, {String? author});
  Future<void> deleteDocument(String id);
  Future<String> getDownloadUrl(String filePath);
  Future<bool> isAuthenticated();
  Future<DocumentModel> updateDocumentCategory(String id, Category category);
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
    return auth.currentUser != null;
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
        throw e;
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

      final documentSnapshot = await firestore.collection('documents').doc(id).get();

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

      final fileName = path.basename(file.path);
      final fileExtension = path.extension(fileName).toLowerCase();

      // Kiểm tra loại file
      DocumentType docType;
      if (fileExtension == '.pdf') {
        docType = DocumentType.pdf;
      } else if (fileExtension == '.epub') {
        docType = DocumentType.epub;
      } else {
        throw UnsupportedFileException();
      }

      // Tải file lên Firebase Storage bằng helper
      final storagePath = await storageHelper.uploadDocument(file);

      // Tạo bản ghi tài liệu trong Firestore
      final docData = {
        'title': title,
        'uploadDate': DateTime.now().toIso8601String(),
        'filePath': storagePath,
        'type': docType.toString().split('.').last,
        'category': Category.unread.toString().split('.').last,
        'userId': userId,
        'author': author,
      };

      final docRef = await firestore.collection('documents').add(docData);

      return DocumentModel.fromJson({...docData, 'id': docRef.id});
    } catch (e) {
      debugPrint('Error uploading document: $e');
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
}