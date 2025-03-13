import 'package:doantotnghiep/core/localization/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/resource.dart';

class EmptyBook extends StatelessWidget {
  const EmptyBook({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: ScreenUtil().screenHeight/3,
      width: ScreenUtil().screenWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            R.ASSETS_IMAGE_EMTY_BOOK,
            width: 220,
            height: 220,
            fit: BoxFit.cover,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            AppLocalizations.of(context).translate("empty.title"),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            softWrap: true,
          ),
        ],
      ),
    );
  }
}
