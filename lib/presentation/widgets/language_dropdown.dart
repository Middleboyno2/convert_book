import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/language_constants.dart';
import '../bloc/language/language_bloc.dart';
import '../bloc/language/language_event.dart';
import '../bloc/language/language_state.dart';

class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        // Lấy locale hiện tại
        Locale currentLocale = state is LanguageChangedState
            ? state.locale
            : const Locale('en', 'US'); // Mặc định là tiếng Anh

        String currentLanguageCode = currentLocale.languageCode;

        return DropdownButton<String>(
          value: currentLanguageCode,
          icon: const Icon(Icons.language),
          elevation: 16,
          underline: Container(
            height: 2,
            color: Theme.of(context).primaryColor,
          ),
          onChanged: (String? newValue) {
            if (newValue != null && newValue != currentLanguageCode) {
              // Dispatch event để thay đổi ngôn ngữ
              context.read<LanguageBloc>().add(
                  ChangeLanguageEvent(languageCode: newValue)
              );
            }
          },
          items: LanguageCode.values.map<DropdownMenuItem<String>>((LanguageCode language) {
            return DropdownMenuItem<String>(
              value: language.code,
              child: Row(
                children: [
                  // Tuỳ chọn: thêm cờ quốc gia
                  // Image.asset('assets/flags/${language.code}.png', width: 24),
                  // SizedBox(width: 10),
                  Text(language.name),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
