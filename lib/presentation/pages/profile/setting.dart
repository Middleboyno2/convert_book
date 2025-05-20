import 'package:doantotnghiep/presentation/widgets/setting/ChangeThemeTile.dart';
import 'package:doantotnghiep/presentation/widgets/setting/language_dropdown.dart';
import 'package:flutter/material.dart';

import '../../../config/colors/kcolor.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
      ),
      body: Column(
        children: [
          ChangeThemeTile(),
          LanguageDropdown()
        ],
      ),
    );
  }
}
