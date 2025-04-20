import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../config/colors/kcolor.dart';

Future<void> showCustomDialog(BuildContext context, {String? message}) {
  return showDialog(
    context: context,
    // cho phep dong dialog khi nhan ra ngoai dialog
    barrierDismissible: true,
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

