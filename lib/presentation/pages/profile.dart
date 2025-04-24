import 'package:doantotnghiep/presentation/widgets/profile/avatar.dart';
import 'package:doantotnghiep/presentation/widgets/profile/profile_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_toast/CustomToast.dart';
import '../widgets/setting/language_dropdown.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _submit() {
    context.read<AuthBloc>().add(
      AuthSignOutRequested(),
    );
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener(
      listener: (BuildContext context, state) {
        if(state is AuthUnauthenticated){
          Toast.showCustomToast(
            context,
            AppLocalizations.of(context).translate('sign_out')
          );
          context.push('/auth');
        }
      },
      child: Scaffold(
        body: SizedBox(
          height: ScreenUtil().screenHeight,
          width: ScreenUtil().screenWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              AvatarProfile(avatarUrl: '', id: 'dfasdfsdfadsfasd',),
              SizedBox(height: 50,),
              ProfileItem(
                icon: Icons.account_circle_outlined,
                title: 'account',
                onTap: (){}
              ),
              ProfileItem(
                  icon: Icons.settings,
                  title: 'setting',
                  onTap: (){
                    context.push('/setting');
                  }
              ),
              ProfileItem(
                  icon: Icons.support_agent_outlined,
                  title: 'support',
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
                    text: AppLocalizations.of(context).translate('forget.submit'),
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
