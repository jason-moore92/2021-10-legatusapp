import 'package:flutter/material.dart';

class GradientBorderButton extends StatelessWidget {
  final String? text;
  final Gradient? gradient;
  final double? thickness;
  final Widget? leftWidget;
  final Widget? rightWidget;
  final TextStyle? textStyle;
  final Color? backColor;
  final Color? onSurface;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? bordercolor;
  final double? elevation;
  final FocusNode? focusNode;
  final bool autofocus;
  final void Function()? onPressed;
  final void Function()? onLongPress;

  const GradientBorderButton({
    Key? key,
    @required this.text,
    this.gradient,
    this.thickness = 0,
    this.leftWidget,
    this.rightWidget,
    this.backColor,
    this.onSurface,
    this.textStyle,
    this.width,
    this.height,
    this.bordercolor,
    this.borderRadius,
    this.elevation,
    this.focusNode,
    this.autofocus = false,
    this.onPressed,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size? fixedSize;

    if (width != null && height == null) {
      fixedSize = Size.fromWidth(width!);
    } else if (width == null && height != null) {
      fixedSize = Size.fromHeight(height!);
    } else if (width != null && height != null) {
      fixedSize = Size(width!, height!);
    }

    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: Container(
        margin: EdgeInsets.all(thickness!),
        color: backColor,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: backColor,
            onSurface: onSurface,
            fixedSize: fixedSize,
            side: bordercolor != null ? BorderSide(color: bordercolor!) : null,
            shape: borderRadius != null ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius!)) : null,
            elevation: elevation,
          ),
          focusNode: focusNode,
          autofocus: autofocus,
          onPressed: onPressed == null
              ? null
              : () {
                  onPressed!();
                },
          onLongPress: onLongPress == null
              ? null
              : () {
                  onLongPress!();
                },
          child: Wrap(
            children: [
              leftWidget ?? const SizedBox(),
              Text(text!, style: textStyle),
              rightWidget ?? const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
