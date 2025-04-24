import 'package:doantotnghiep/config/colors/kcolor.dart';
import 'package:doantotnghiep/core/localization/app_localizations.dart';
import 'package:doantotnghiep/presentation/bloc/auth/auth_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/setting/setting_bloc.dart';
import 'package:doantotnghiep/presentation/pages/auth/forget_password.dart';
import 'package:doantotnghiep/presentation/pages/auth/login.dart';
import 'package:doantotnghiep/presentation/pages/auth/register.dart';
import 'package:doantotnghiep/presentation/widgets/custom_toast/CustomToast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/resource.dart';
import '../../../core/error/failures.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/setting/setting_state.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalization = AppLocalizations.of(context);
    final settingState = context.read<SettingBloc>().state;
    final isDark = settingState is SettingLoadedState?
    settingState.isDarkMode
        :
    false;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if(state is AuthFailureState){
          String message = 'Đã xảy ra lỗi';
          // truong hop email da ton tai
          if (state.failure is EmailAlreadyInUseFailure) {
            message = appLocalization.translate('exception.email_already_in_use');
          } else if (state.failure is InvalidEmailFailure) {
            //email khono hop le
            message = appLocalization.translate('exception.invalid_email');
          } else if (state.failure is WeakPasswordFailure) {
            // mat khau yeu
            message = appLocalization.translate('exception.weak_pass');
          } else if (state.failure is UserNotFoundFailure) {
            // khong tim thay user
            message = appLocalization.translate('exception.user_not_found');
          } else if (state.failure is WrongPasswordFailure) {
            // mat khau khong dung
            message = appLocalization.translate('exception.wrong_pass');
          } else if (state.failure is UserDisabledFailure) {
            // user bi vo hieu hoa
            message = appLocalization.translate('exception.user_disabled');
          } else if (state.failure is NetworkFailure) {
            // tinh trang internet
            message = appLocalization.translate('exception.network');
          } else {
            message = state.failure.message;
          }
          Toast.showCustomToast(context, message);
        }
        if( state is AuthAuthenticated){
          Toast.showCustomToast(
            context,
            appLocalization.translateWithArgs(
              'welcome_message',
              args: {'name': state.user.id}
            )
          );
        } else if (state is AuthPasswordResetEmailSent) {
          Toast.showCustomToast(
            context,
            appLocalization.translateWithArgs(
              'send_password_reset',
              args: {'name': state.email})
          );
        }
      },
      child: SafeArea(
        child: Container(
          width: ScreenUtil().screenWidth,
          height: ScreenUtil().screenHeight,
          decoration: BoxDecoration(
            color: isDark?
            Kolors.kDark
            :
            Kolors.kWhite,
            image: const DecorationImage(
              image: AssetImage(R.ASSETS_IMAGE_AUTH_LOGIN)
            ),
          ),
          child: Stack(
            children: <Widget>[
              PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  LoginScreen(pageController: _pageController),
                  RegisterScreen(pageController: _pageController,),
                  ForgetPasswordScreen()
                ],
              ),
      
              // close auth
              Positioned(
                top: 10,
                left: 10,
                child: CircleAvatar(
                  backgroundColor: Kolors.kGrayLight,
                  child: IconButton(
                    onPressed: (){
                      context.pop();
                    },
                    icon: Icon(Icons.close)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
