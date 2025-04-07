import 'package:doantotnghiep/config/colors/kcolor.dart';
import 'package:doantotnghiep/core/localization/app_localizations.dart';
import 'package:doantotnghiep/presentation/widgets/custom_button.dart';
import 'package:doantotnghiep/presentation/widgets/custom_button_auth.dart';
import 'package:doantotnghiep/presentation/widgets/custom_textfield.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/resource.dart';
import '../../../core/error/failures.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';

class LoginScreen extends StatefulWidget {
  final PageController pageController;
  const LoginScreen({
    super.key,
    required this.pageController,
  });
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool obscure = true;
  // change icon state
  void changeObscure(){
    setState(() {
      obscure = !obscure;
    });
  }

  void nextPageRegister(){
    widget.pageController.animateToPage(
      1,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthSignInWithEmailPasswordRequested(
          email: email.text,
          password: password.text,
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    // Kiểm tra định dạng email đơn giản
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  // void _resetPassword() {
  //   if (email.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Vui lòng nhập email để đặt lại mật khẩu')),
  //     );
  //     return;
  //   }
  //
  //   context.read<AuthBloc>().add(
  //     AuthSendPasswordResetEmailRequested(email: email.text),
  //   );
  // }

  @override
  void dispose() {
    super.dispose();
    email.dispose();
    password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late AppLocalizations appLocalization = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Kolors.kTransparent,
      body: Center(
        child: SingleChildScrollView(
          // physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 15.0,
              children: [
                Text(
                  appLocalization.translate('auth.title'),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                // email
                CustomTextFormField(
                  controller: email,
                  textInput: TextInputType.emailAddress,
                  labelText: appLocalization.translate('auth.email'),
                  validator: _validateEmail,
                ),
                // password
                CustomTextFormField(
                  controller: password,
                  obscureText: obscure,
                  textInput: TextInputType.visiblePassword,
                  suffixIcon: true,
                  onPressedSuffix: changeObscure,
                  labelText: appLocalization.translate('auth.password'),
                  validator: _validatePassword,
                ),

                // forget_pass
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: (){
                        widget.pageController.animateToPage(
                          2,
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeInOut
                        );
                      },
                      child: Text(
                          AppLocalizations.of(context).translate('auth.forget')
                      ),
                    ),
                  ],
                ),
                // submit
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return CustomButton(
                      onPressed: (){
                        state is AuthLoading ? null: _submit();
                      },
                      isLoading: state is AuthLoading ? true: false,
                      isSubmit: state is AuthLoading ? false: true,
                      text: AppLocalizations.of(context).translate('auth.submit'),
                    );
                  }
                ),

                // divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey,  // Màu của gạch ngang
                        thickness: 2,        // Độ dày của gạch
                        endIndent: 10,       // Khoảng cách từ chữ "or" đến gạch ngang
                      ),
                    ),
                    Text(
                      "or",
                      style: TextStyle(color: Colors.grey), // Màu chữ
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 2,
                        indent: 10,  // Khoảng cách từ chữ "or" đến gạch ngang
                      ),
                    ),
                  ],
                ),

                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        //google
                        CustomButtonAuth(
                          onPressed: () {
                            state is AuthLoading ?
                            null
                                :
                            context.read<AuthBloc>().add(AuthSignInWithGoogleRequested());

                          },
                          text: AppLocalizations.of(context).translate('auth.google'),
                          icon: Image.asset(
                            R.ASSETS_ICON_AUTH_GOOGLE,
                            width: 30,
                          ),
                          background: Kolors.kGrayLight,
                          // khi bam nut thi xuất hiện indicator
                          isLoading: state is AuthLoading ? true: false,
                          isSubmit: state is AuthLoading ? false: true,
                        ),

                        //apple
                        CustomButtonAuth(
                          onPressed: () {
                            state is AuthLoading ?
                            null
                                :
                            context.read<AuthBloc>().add(AuthSignInWithAppleRequested());
                          },
                          text: AppLocalizations.of(context).translate('auth.apple'),
                          icon: Image.asset(
                            R.ASSETS_ICON_AUTH_APPLE,
                            width: 30,
                          ),
                          background: Kolors.kDark,
                          isLoading: state is AuthLoading ? true: false,
                          isSubmit: state is AuthLoading ? false: true,
                        ),
                      ],
                    );
                  }
                ),

                // next page register
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: <TextSpan>[
                      TextSpan(
                        text: AppLocalizations.of(context).translate('auth.question')
                      ),
                      TextSpan(text: " "),
                      TextSpan(
                        text: AppLocalizations.of(context).translate('auth.register'),
                        recognizer: TapGestureRecognizer()
                          ..onTap = (){
                          nextPageRegister();
                          }
                      )
                    ]
                  )
                ),

              ],
            )
          ),
        ),
      ),
    );
  }
}

