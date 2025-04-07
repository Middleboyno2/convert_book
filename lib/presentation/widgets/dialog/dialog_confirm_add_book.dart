import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;

import '../../../config/colors/kcolor.dart';

Future<bool?> showAddBookDialog({
  required BuildContext context,
  required Set<File> selectedFiles,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.grey[850],
      title: const Text(
        'Add books?',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You can choose which books you want to add. You can edit Title and Cover image of the book later. The loading process can take up to several minutes.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            // Sử dụng Container với chiều cao cố định và SingleChildScrollView thay vì ListView
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.3, // Giới hạn chiều cao
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: selectedFiles.map((file) {
                    final title = path.basenameWithoutExtension(file.path);
                    final fileName = path.basename(file.path);
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        _getFileIcon(file.path),
                        color: Kolors.kGold,
                        size: 20,
                      ),
                      title: Text(
                        fileName,
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(
                        Icons.check_circle_rounded,
                        color: Kolors.kGold,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tổng cộng: ${selectedFiles.length} file',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        TextButton(
          onPressed: () {
            context.pop(true);
          },
          child: const Text(
            'Add',
            style: TextStyle(color: Kolors.kGold),
          ),
        ),
      ],
    ),
  );
}

// Helper function để xác định icon dựa trên loại file
IconData _getFileIcon(String filePath) {
  final extension = path.extension(filePath).toLowerCase();
  if (extension == '.pdf') {
    return Icons.picture_as_pdf;
  } else if (extension == '.epub') {
    return Icons.book;
  }
  return Icons.insert_drive_file;
}