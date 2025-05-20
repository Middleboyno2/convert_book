import 'package:doantotnghiep/config/colors/kcolor.dart';
import 'package:flutter/material.dart';


class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType textInput;
  final String labelText;
  final Icon? icon;
  final String hintText;
  final Widget? prefixIcon;
  final bool suffixIcon;
  final Color border;
  final Color focusColor;
  final Color focusBorderColor;
  final Color errorBorderColor;
  final FormFieldValidator<String>? validator;
  const CustomTextFormField({
    super.key,
    required this.controller,
    this.icon,
    this.hintText = "",
    this.prefixIcon,
    this.suffixIcon = false,
    this.border = Kolors.kGray,
    this.focusColor = Kolors.kDark,
    this.focusBorderColor = Kolors.kGold,
    this.errorBorderColor = Kolors.kRed,
    this.textInput = TextInputType.text,
    required this.labelText,
    this.validator,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool obscure = false;

  // change icon state
  void changeObscure(){
    setState(() {
      obscure = !obscure;
    });
  }
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.textInput,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        filled: true,
        fillColor: Kolors.kTransparent,
        focusColor: widget.focusColor,
        errorStyle: TextStyle(
            color: widget.errorBorderColor
        ),
        hintText: widget.hintText,
        icon: widget.icon,
        // anh been trai
        prefixIcon: widget.prefixIcon,
        // anh ben phai
        suffixIcon: widget.suffixIcon?
        IconButton(
          icon:Icon(obscure?
          Icons.visibility_outlined
              :
          Icons.visibility_off_outlined),

          onPressed: () {changeObscure();},
        )
            :
        null,
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Kolors.kGray),
            borderRadius: BorderRadius.circular(18)
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.focusBorderColor, width: 2.0),
          // borderRadius: BorderRadius.circular(18)
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.errorBorderColor, width: 2.0),
          // borderRadius: BorderRadius.circular(18)
        ),
      ),
      validator: widget.validator,
    );
  }
}
