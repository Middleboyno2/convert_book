import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/colors/kcolor.dart';
import '../../core/localization/app_localizations.dart';

class CustomButtonAuth extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading; // Thêm trạng thái loading
  final bool isSubmit;
  final Widget? icon;
  final String text;
  final Color? background;
  const CustomButtonAuth({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.isSubmit = false,
    this.icon,
    required this.text,
    this.background = Kolors.kGold,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed, // Disable khi đang loading
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: Size(ScreenUtil().screenWidth / 2, 50),
        fixedSize: Size(ScreenUtil().screenWidth - 15, 50),
        backgroundColor: background, // Đổi lại màu cho đúng
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Chỉnh borderRadius ở đây
        ),
      ),
      child: isLoading?
      SizedBox(
        width: 24,
        height: 24,
        child: isSubmit?
        Icon(Icons.done)
            :
        CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
          :
      Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: icon!
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleSmall?.
                    copyWith(fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }
}
