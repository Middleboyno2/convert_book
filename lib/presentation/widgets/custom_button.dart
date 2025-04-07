import 'package:doantotnghiep/config/colors/kcolor.dart';
import 'package:doantotnghiep/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading; // Thêm trạng thái loading
  final bool isSubmit;// trạng thái xử lý
  final String text;
  const CustomButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.isSubmit = false,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed, // Disable khi đang loading
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: Size(ScreenUtil().screenWidth / 2, 50),
        fixedSize: Size(ScreenUtil().screenWidth - 15, 50),
        backgroundColor: Kolors.kGold, // Đổi lại màu cho đúng
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
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.titleMedium
          ),
        ],
      ),
    );
  }
}
