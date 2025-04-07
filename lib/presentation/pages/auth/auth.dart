import 'package:doantotnghiep/config/colors/kcolor.dart';
import 'package:doantotnghiep/core/localization/app_localizations.dart';
import 'package:doantotnghiep/presentation/bloc/auth/auth_bloc.dart';
import 'package:doantotnghiep/presentation/pages/auth/forget_password.dart';
import 'package:doantotnghiep/presentation/pages/auth/login.dart';
import 'package:doantotnghiep/presentation/pages/auth/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/resource.dart';
import '../../../core/error/failures.dart';
import '../../bloc/auth/auth_state.dart';

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
    late bool isDark = Theme.of(context).brightness == Brightness.dark;
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

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }

        if (state is AuthPasswordResetEmailSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã gửi email đặt lại mật khẩu đến ${state.email}'),
              backgroundColor: Colors.green,
            ),
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
                // physics: NeverScrollableScrollPhysics(),
                children: [
                  LoginScreen(pageController: _pageController),
                  RegisterScreen(pageController: _pageController,),
                  ForgetPasswordScreen()
                ],
              ),
      
              // close auth
              Align(
                alignment: Alignment.topLeft,
                child: BackButton(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
