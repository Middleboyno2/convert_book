import 'package:doantotnghiep/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../config/colors/kcolor.dart';

class CustomSearch extends StatelessWidget {
  final TextEditingController controller;
  const CustomSearch({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.only(left: 10.0,right: 10,bottom: 5),
      height: 45,
      child: SearchBar(
        controller: controller,
        leading: Icon(Icons.search),
        hintText: AppLocalizations.of(context).translate('search.search'),
        backgroundColor: WidgetStateProperty.all(
          isDarkMode?Kolors.kDarkGray: Kolors.kOffWhite
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          )
        ),
        shadowColor: WidgetStateProperty.all(
          Kolors.kTransparent
        ),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: 5)
        ),

      ),
    );
  }
}
