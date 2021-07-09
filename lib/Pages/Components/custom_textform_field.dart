import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final double? width;
  final InputBorder border;
  final InputBorder? focusedBorder;
  final InputBorder? disabledBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final EdgeInsetsGeometry contentPadding;
  final bool autofocus;
  final bool readOnly;
  final bool obscureText;
  final TextStyle? style;
  final String hintText;
  final TextStyle? hintStyle;
  final String? labelText;
  final TextStyle? labelStyle;
  final TextStyle? errorStyle;
  final int errorMaxLines;
  final TextAlign textAlign;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? prefixIcon;
  final BoxConstraints? prefixIconConstraints;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final Function()? onEditingComplete;
  final Function(String)? onFieldSubmitted;
  final Function(String)? validator;
  final Function(String)? onSaved;
  final Function()? onTap;

  const CustomTextFormField({
    Key? key,
    this.controller,
    this.focusNode,
    this.width,
    this.border = const OutlineInputBorder(),
    this.focusedBorder,
    this.disabledBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    this.autofocus = false,
    this.readOnly = false,
    this.obscureText = false,
    this.style,
    this.hintText = "",
    this.hintStyle,
    this.labelText,
    this.labelStyle,
    this.errorStyle,
    this.errorMaxLines = 1,
    this.textAlign = TextAlign.start,
    this.textInputAction = TextInputAction.done,
    this.keyboardType,
    this.maxLines = 1,
    this.prefixIcon,
    this.prefixIconConstraints,
    this.inputFormatters,
    this.onChanged,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.validator,
    this.onSaved,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    InputBorder? focusedBorder;
    InputBorder? errorBorder;
    InputBorder? focusedErrorBorder;
    focusedBorder = this.focusedBorder ?? this.border;
    focusedBorder = focusedBorder.copyWith(
      borderSide: focusedBorder.borderSide.copyWith(width: 1.5),
    );
    errorBorder = this.errorBorder ?? this.border;
    errorBorder = errorBorder.copyWith(borderSide: errorBorder.borderSide.copyWith(color: Colors.red));
    focusedErrorBorder = this.focusedErrorBorder ?? errorBorder;
    focusedErrorBorder = focusedErrorBorder.copyWith(borderSide: focusedErrorBorder.borderSide.copyWith(width: 1.5));

    return Container(
      width: width,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        style: style,
        decoration: InputDecoration(
          border: border,
          focusedBorder: focusedBorder,
          enabledBorder: border,
          disabledBorder: disabledBorder ?? border,
          errorBorder: errorBorder,
          focusedErrorBorder: focusedErrorBorder,
          isCollapsed: true,
          isDense: true,
          contentPadding: contentPadding,
          hintText: hintText,
          hintStyle: hintStyle,
          labelText: labelText,
          labelStyle: labelStyle,
          errorStyle: errorStyle,
          errorMaxLines: errorMaxLines,
          prefixIcon: prefixIcon,
          prefixIconConstraints: prefixIconConstraints,
        ),
        readOnly: readOnly,
        obscureText: obscureText,
        textAlign: textAlign,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        onChanged: (input) {
          if (onChanged != null) {
            onChanged!(input.trim());
          }
        },
        onEditingComplete: () {
          if (onEditingComplete != null) {
            onEditingComplete!();
          }
        },
        onFieldSubmitted: (input) {
          if (onFieldSubmitted != null) {
            onFieldSubmitted!(input.trim());
          }
        },
        validator: (input) {
          if (validator != null) {
            return validator!(input!.trim());
          } else {
            return null;
          }
        },
        onSaved: (input) {
          if (onSaved != null && input != null) {
            onSaved!(input.trim());
          }
        },
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
        },
      ),
    );
  }
}
