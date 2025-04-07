// login_required_dialog.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<void> showLoginRequiredDialog({
  required BuildContext context,
  required Function() onAddPressed,
  }) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.grey[850],
      title: const Text(
        'Yêu cầu đăng nhập',
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        'Bạn cần đăng nhập để tải lên tài liệu.',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop();
            onAddPressed();
          },
          child: const Text(
            'Hủy',
            style: TextStyle(color: Colors.lightBlue),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Đóng dialog
            context.push("/auth"); // Mặc định điều hướng
          },
          child: const Text(
            'Đăng nhập',
            style: TextStyle(color: Colors.lightBlue),
          ),
        ),
      ],
    ),
  );
}
