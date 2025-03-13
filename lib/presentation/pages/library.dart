import 'package:doantotnghiep/presentation/widgets/empty/empty_book.dart';
import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../widgets/language_dropdown.dart';

class HomePage extends StatelessWidget{
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy translation không có tham số
    String title = AppLocalizations.of(context).translate('library.title');

    // vi du: Lấy translation có tham số
    String welcome = AppLocalizations.of(context).translateWithArgs(
        'library.welcome',
        args: {'name': 'John Doe'}
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            AppLocalizations.of(context).translate('library.language'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const LanguageDropdown(),
          const SizedBox(height: 8),
          EmptyBook(),
          // Các cài đặt khác
        ],
      ),
    );
  }

}