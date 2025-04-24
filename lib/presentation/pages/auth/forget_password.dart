import 'package:doantotnghiep/config/colors/kcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_localizations.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthSendPasswordResetEmailRequested(
          email: email.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    late AppLocalizations appLocalization = AppLocalizations.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Kolors.kTransparent,
      body: Padding(
        padding: EdgeInsets.only(top: 20, left: 16, right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // send email
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomTextFormField(
                    controller: email,
                    textInput: TextInputType.emailAddress,
                    labelText: appLocalization.translate('forget.email'),
                  ),
                  // submit
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        onPressed: (){
                          state is AuthSendEmailLoading ? null: _submit();
                        },
                        isLoading: state is AuthSendEmailLoading ? true: false,
                        isSubmit: state is AuthSendEmailLoading ? false: true,
                        text: AppLocalizations.of(context).translate('forget.submit'),
                      );
                    }
                  ),
                ],
              ),

            ),

          ],
        ),
      ),
    );
  }
}
