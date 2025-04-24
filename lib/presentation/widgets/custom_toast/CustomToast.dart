import 'package:doantotnghiep/config/colors/kcolor.dart';
import 'package:flutter/material.dart';

class CustomToast extends StatelessWidget {
  final String message;
  final Color? backgroundColor;
  final IconData? icon;

  const CustomToast({
    super.key,
    required this.message,
    this.backgroundColor = Kolors.kGrayLight,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
          child: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(12),
            color: backgroundColor,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null)
                    Icon(icon),
                  if (icon != null) SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      message,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class Toast{
  static void showCustomToast(BuildContext context, String message, {Color? color, IconData? icon}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => CustomToast(message: message, backgroundColor: color, icon: icon),
    );
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3)).then((_) => overlayEntry.remove());
  }
}

