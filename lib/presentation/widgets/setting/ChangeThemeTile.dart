import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/setting/setting_bloc.dart';
import '../../bloc/setting/setting_event.dart';
import '../../bloc/setting/setting_state.dart';


class ChangeThemeTile extends StatelessWidget {
  const ChangeThemeTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingBloc, SettingState> (
      builder: (context, state){
        bool isDark = state is SettingLoadedState?
        state.isDarkMode
            :
        false;
        return ListTile(
          leading: isDark? Icon(Icons.dark_mode): Icon(Icons.light_mode),
          title: Text('Dark mode'),
          trailing: Switch(
            value: isDark,
            onChanged: (value) {
              context.read<SettingBloc>().add(
                ThemeChangedEvent(isDarkMode: value),
              );
            }
          ),
        );
      },
    );
  }
}
