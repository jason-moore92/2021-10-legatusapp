import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String? text;
  final Widget? leftWidget;
  final Widget? rightWidget;
  final TextStyle? textStyle;
  final Color? backColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? bordercolor;
  final double? elevation;
  final FocusNode? focusNode;
  final bool autofocus;
  final Function? onPressed;
  final Function? onLongPress;

  const CustomTextButton({
    Key? key,
    @required this.text,
    this.backColor,
    this.leftWidget,
    this.rightWidget,
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

    return TextButton(
      style: TextButton.styleFrom(
        primary: backColor,
        fixedSize: fixedSize,
        side: bordercolor != null ? BorderSide(color: bordercolor!) : null,
        shape: borderRadius != null ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius!)) : null,
        elevation: elevation,
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          leftWidget ?? SizedBox(),
          Text(text!, style: textStyle),
          rightWidget ?? SizedBox(),
        ],
      ),
      focusNode: focusNode,
      autofocus: autofocus,
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
        }
      },
      onLongPress: () {
        if (onLongPress != null) {
          onLongPress!();
        }
      },
    );
  }
}
