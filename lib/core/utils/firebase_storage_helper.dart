// lib/core/utils/firebase_storage_helper.dart

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class FirebaseStorageHelper {
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  FirebaseStorageHelper({
    required FirebaseStorage storage,
    required FirebaseAuth auth,
  })  : _storage = storage,
        _auth = auth;

  /// Upload một file đến Firebase Storage và trả về đường dẫn
  Future<String> uploadDocument(File file) async {
    try {
      // Check if user is authenticated
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate a uuid for the file to avoid name conflicts
      final uuid = const Uuid().v4();

      // Get file extension
      final fileExtension = path.extension(file.path);

      // Create a reference with a specific path
      final fileName = '$uuid$fileExtension';
      final storageRef = _storage.ref().child('documents/${user.uid}/$fileName');

      // Log reference path for debugging
      debugPrint('Uploading to path: documents/${user.uid}/$fileName');

      // Metadata for the file
      final metadata = SettableMetadata(
        contentType: _getContentType(fileExtension),
        customMetadata: {
          'userId': user.uid,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Start upload task
      final uploadTask = storageRef.putFile(file, metadata);

      // Handle upload errors
      uploadTask.catchError((error) {
        debugPrint('Upload error: $error');
        throw error;
      });

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get the storage path
      final storagePath = snapshot.ref.fullPath;
      debugPrint('Upload successful. Path: $storagePath');

      return storagePath;
    } catch (e) {
      debugPrint('Error uploading document: $e');
      rethrow;
    }
  }

  /// Lấy URL download từ đường dẫn storage
  Future<String> getDownloadUrl(String storagePath) async {
    try {
      final ref = _storage.ref(storagePath);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Error getting download URL: $e');
      rethrow;
    }
  }

  /// Xóa file từ Firebase Storage
  Future<void> deleteFile(String storagePath) async {
    try {
      await _storage.ref(storagePath).delete();
    } catch (e) {
      debugPrint('Error deleting file: $e');
      // Don't throw if file not found
      if (!e.toString().contains('object-not-found')) {
        rethrow;
      }
    }
  }

  /// Kiểm tra xem đường dẫn storage có tồn tại không
  Future<bool> checkIfFileExists(String storagePath) async {
    try {
      final ref = _storage.ref(storagePath);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Lấy content type dựa trên phần mở rộng của file
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.pdf':
        return 'application/pdf';
      case '.epub':
        return 'application/epub+zip';
      default:
        return 'application/octet-stream';
    }
  }
}