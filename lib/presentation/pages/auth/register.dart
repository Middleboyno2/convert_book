import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/colors/kcolor.dart';
import '../../../core/constants/resource.dart';
import '../../../core/localization/app_localizations.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_button_auth.dart';
import '../../widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  final PageController pageController;
  const RegisterScreen({super.key, required this.pageController});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirm = TextEditingController();
  bool obscure = true;
  // change icon state
  void changeObscure(){
    setState(() {
      obscure = !obscure;
    });
  }
  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthSignUpWithEmailPasswordRequested(
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
                    appLocalization.translate('register.title'),
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  // name
                  CustomTextFormField(
                    controller: name,
                    textInput: TextInputType.name,
                    labelText: appLocalization.translate('register.name'),
                  ),
                  // email
                  CustomTextFormField(
                    controller: email,
                    textInput: TextInputType.emailAddress,
                    labelText: appLocalization.translate('register.email'),
                  ),
                  // phone
                  CustomTextFormField(
                    controller: phone,
                    textInput: TextInputType.phone,
                    labelText: appLocalization.translate('register.phone'),
                  ),
                  // password
                  CustomTextFormField(
                    controller: password,
                    obscureText: obscure,
                    textInput: TextInputType.visiblePassword,
                    suffixIcon: true,
                    onPressedSuffix: changeObscure,
                    labelText: appLocalization.translate('register.password'),
                  ),
                  // confirm password
                  CustomTextFormField(
                    controller: confirm,
                    obscureText: obscure,
                    textInput: TextInputType.visiblePassword,
                    suffixIcon: true,
                    onPressedSuffix: changeObscure,
                    labelText: appLocalization.translate('register.confirm'),
                  ),

                  // submit
                  CustomButton(
                    onPressed: (){},
                    text: AppLocalizations.of(context).translate('register.submit'),
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

                  //google
                  CustomButtonAuth(
                    onPressed: () {  },
                    text: AppLocalizations.of(context).translate('register.google'),
                    icon: Image.asset(
                      R.ASSETS_ICON_AUTH_GOOGLE,
                      width: 30,
                    ),
                    background: Kolors.kGrayLight,
                  ),

                  //apple
                  CustomButtonAuth(
                    onPressed: () {  },
                    text: AppLocalizations.of(context).translate('register.apple'),
                    icon: Image.asset(
                      R.ASSETS_ICON_AUTH_APPLE,
                      width: 30,
                    ),
                    background: Kolors.kDark,
                  ),

                  // forget_pass
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: (){
                          widget.pageController.animateToPage(
                            1,
                            duration: Duration(milliseconds: 400),
                            curve: Curves.easeInOut
                          );
                        },
                        child: Text(
                            AppLocalizations.of(context).translate('register.forget')
                        ),
                      ),
                    ],
                  ),

                ],
              )
          ),
        ),
      ),
    );
  }
}
