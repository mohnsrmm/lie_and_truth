import 'package:flutter/material.dart';
import 'package:lie_and_truth/core/app_colors.dart';

class CommonTextField extends StatelessWidget {
  const CommonTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.isPassword = false,
    required this.controller,
    this.onChanged = null,
    this.suffixIcon = null,
    this.validator,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.capitalizeEachWord = false,
    this.readonly = false,
  });

  final String labelText;
  final String hintText;
  final bool isPassword;

  final int maxLines;
  final TextInputType keyboardType;

  final TextEditingController controller;
  final Function(String)? onChanged;

  final Widget? suffixIcon;

  final String? Function(String?)? validator;

  final bool capitalizeEachWord;

  final bool readonly;

  @override
  Widget build(BuildContext context) {
    bool willPasswordShow = false;

    final borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: AppColors.kPrimary,
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StatefulBuilder(builder: (context, setState) {
        return TextFormField(
          style: TextStyle(color: AppColors.kPrimary),
          textCapitalization: capitalizeEachWord
              ? TextCapitalization.words
              : TextCapitalization.none,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText.toLowerCase(),
            labelStyle: TextStyle(color: AppColors.kPrimary),
            hintStyle: TextStyle(color: AppColors.kPrimary),
            filled: true,
            border: borderStyle,
            focusedBorder: borderStyle,
            enabledBorder: borderStyle,
            suffixIcon: isPassword
                ? IconButton(
              icon: !willPasswordShow
                  ? Icon(
                Icons.visibility,
                color: AppColors.kPrimary,
              )
                  : Icon(
                Icons.visibility_off,
                color: AppColors.kPrimary,
              ),
              onPressed: () {
                setState(() {
                  willPasswordShow = !willPasswordShow;
                });
              },
            )
                : suffixIcon,
          ),
          obscureText: isPassword ? !willPasswordShow : false,
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readonly,
          maxLines: maxLines,
          onChanged: onChanged,
          validator: validator,
        );
      }),
    );
  }
}
