import 'package:doantotnghiep/config/colors/kcolor.dart';
import 'package:doantotnghiep/core/localization/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/resource.dart';

class EmptyBook extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback onPressed;
  const EmptyBook({super.key, required this.title, required this.buttonText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      // height: ScreenUtil().screenHeight/3,
      width: ScreenUtil().screenWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            child: Image.asset(
              R.ASSETS_IMAGE_EMTY_BOOK,
              width: ScreenUtil().screenWidth,
              fit: BoxFit.cover,
            ),
          ),


          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style: Theme.of(context).textTheme.labelLarge
                  ),
                  TextSpan(
                    text: buttonText,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Kolors.kPrimary),
                    recognizer: TapGestureRecognizer()
                      ..onTap = (){
                        onPressed();
                      }
                  )
                ]
              )
            ),
          ),
        ],
      ),
    );
  }
}
