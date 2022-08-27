library keicy_checkbox;

import 'package:flutter/material.dart';

class CustomRadioButton<T> extends FormField<T> {
  CustomRadioButton({
    Key? key,
    double? width,
    double? height,
    required T value,
    required T groupValue,
    Color? activeColor = Colors.blue,
    Color? focusColor,
    Color? hoverColor,
    FocusNode? focusNode,
    String? label = "",
    TextStyle? labelStyle,
    bool? enabled = true,
    void Function(T?)? onChanged,
    FormFieldValidator<T>? onValidateHandler,
    Function(T?)? onSaveHandler,
  }) : super(
          key: key,
          initialValue: value,
          validator: (T? value) {
            if (onValidateHandler != null) return onValidateHandler(value);
            return null;
          },
          onSaved: (T? value) {
            if (onSaveHandler != null) onSaveHandler(value);
          },
          builder: (FormFieldState<T> state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: (enabled!)
                      ? () {
                          state.didChange(value);
                          if (onChanged != null) {
                            onChanged(value);
                          }
                        }
                      : null,
                  child: Container(
                    width: width,
                    height: height,
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: Row(
                      children: <Widget>[
                        Radio<T>(
                          value: value,
                          groupValue: groupValue,
                          activeColor: activeColor,
                          focusColor: focusColor,
                          hoverColor: hoverColor,
                          focusNode: focusNode,
                          onChanged: (enabled) ? onChanged : null,
                        ),
                        if (label != "")
                          (width == null)
                              ? Text(label!, style: labelStyle)
                              : Expanded(
                                  child: Text(label!, style: labelStyle),
                                )
                      ],
                    ),
                  ),
                ),
                (state.hasError)
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Text(
                          (state.errorText ?? ""),
                          style: TextStyle(fontSize: (labelStyle != null) ? labelStyle.fontSize! * 0.8 : 12, color: Colors.red),
                        ),
                      )
                    : const SizedBox(),
              ],
            );
          },
        );
}
