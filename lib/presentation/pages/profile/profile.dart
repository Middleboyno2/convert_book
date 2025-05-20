import 'package:doantotnghiep/presentation/widgets/profile/avatar.dart';
import 'package:doantotnghiep/presentation/widgets/profile/profile_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/resource.dart';
import '../../../core/localization/app_localizations.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_toast/CustomToast.dart';
import '../../widgets/setting/language_dropdown.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _uid;
  String? _coverUrl;
  @override
  void initState() {
    super.initState();
    _loadUser();
  }
  void _loadUser(){
    context.read<AuthBloc>().add(AuthCheckRequested());
  }
  void _submit() {
    context.read<AuthBloc>().add(
      AuthSignOutRequested(),
    );
  }
  @override
  Widget build(BuildContext context) {
    final applocalization = AppLocalizations.of(context);
    return BlocListener<AuthBloc, AuthState>(
      listener: (BuildContext context, state) {

        if(state is AuthUnauthenticated){
          Toast.showCustomToast(
            context,
            AppLocalizations.of(context).translate('sign_out')
          );
          context.push('/auth');
        }else if(state is AuthAuthenticated){
          setState(() {
            _uid = state.user.id;
            _coverUrl = state.user.photoUrl;
          });
        }
      },
      child: Scaffold(
        body: SizedBox(
          height: ScreenUtil().screenHeight,
          width: ScreenUtil().screenWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AvatarProfile(avatarUrl: _coverUrl ?? '', id: _uid ?? '',),
              SizedBox(height: 50,),
              ProfileItem(
                name: R.ASSETS_ICON_INSTRUCTION,
                title: applocalization.translate('profile.instruction_manual'),
                onTap: (){
                  context.push('/manual');
                }
              ),
              ProfileItem(
                name: R.ASSETS_ICON_SETTING,
                title: applocalization.translate('profile.setting'),
                onTap: (){
                  context.push('/setting');
                }
              ),
              ProfileItem(
                name: R.ASSETS_ICON_QUESTION,
                title: applocalization.translate('profile.support'),
                onTap: (){
                  context.push('/support');
                }
              ),
              const LanguageDropdown(),
              const SizedBox(height: 8),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return CustomButton(
                    onPressed: (){
                      state is AuthSignOutLoading ? null: _submit();
                    },
                    isLoading: state is AuthSignOutLoading ? true: false,
                    isSubmit: state is AuthSignOutLoading ? false: true,
                    text: applocalization.translate('profile.sign_out'),
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
