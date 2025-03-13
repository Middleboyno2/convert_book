import 'package:doantotnghiep/config/colors/kcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/resource.dart';


class LogoSplash extends StatelessWidget {
  const LogoSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // tao khung bao quanh logo
      decoration: BoxDecoration(
        color: Kolors.kGold,
        // border: Border.all(
        //   color: Kolors.kGray,
        //   width: 2.0,
        // ),
        borderRadius: BorderRadius.circular(
          ScreenUtil().screenWidth/4
        ),
      ),
      child: Image.asset(
        R.ASSETS_IMAGE_LOGO_SPLASH,
        width: ScreenUtil().screenWidth/2,
        height: ScreenUtil().screenWidth/2,
        fit: BoxFit.cover,
      ),
    );
  }
}
