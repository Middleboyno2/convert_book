import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/localization/language_constants.dart';
import '../../bloc/setting/setting_bloc.dart';
import '../../bloc/setting/setting_event.dart';
import '../../bloc/setting/setting_state.dart';


class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingBloc, SettingState>(
      builder: (context, state) {
        // Lấy locale hiện tại
        Locale currentLocale = state is SettingLoadedState
            ? state.locale
            : const Locale('en', 'US'); // Mặc định là tiếng Anh

        String currentLanguageCode = currentLocale.languageCode;

        return ListTile(
          leading: Icon(Icons.language),
          title: Text("Language"),
          trailing: DropdownButton<String>(
            value: currentLanguageCode,
            elevation: 16,
            onChanged: (String? newValue) {
              if (newValue != null && newValue != currentLanguageCode) {
                // Dispatch event để thay đổi ngôn ngữ
                context.read<SettingBloc>().add(
                    ChangeLanguageEvent(languageCode: newValue)
                );
              }
            },
            items: LanguageCode.values.map<DropdownMenuItem<String>>((LanguageCode language) {
              return DropdownMenuItem<String>(
                value: language.code,
                child: Row(
                  children: [
                    Text(
                      language.name,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 10
                    ),
                    Image.asset(
                      'assets/images/language/${language.code}.png',
                      width: 24
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
