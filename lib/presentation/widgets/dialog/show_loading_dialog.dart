import 'package:doantotnghiep/config/colors/kcolor.dart';
import 'package:flutter/material.dart';

Future<void> showLoadingDialog(BuildContext context, {String? message}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.grey[850],
      content: Row(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Kolors.kGold),
          ),
          const SizedBox(width: 16),
          Text(
            'Loading...',
          ),
        ],
      ),
    ),
  );
}
