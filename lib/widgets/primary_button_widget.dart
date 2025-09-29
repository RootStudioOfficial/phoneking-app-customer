import 'package:flutter/material.dart';
import 'package:phone_king_customer/widgets/easy_text_widget.dart';

class PrimaryButtonWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final Function onPressed;
  final Color? backgroundColor;
  final String buttonText;
  final Color? buttonTextColor;
  final double? radius;
  final Color? borderColor;
  final FontWeight? buttonFontWeight;
  final bool isDisable;
  final bool isGhostButton;
  final String? buttonTextFontFamily;
  final TextDecoration? buttonTextDecoration;
  final double? buttonFontSize;

  const PrimaryButtonWidget({
    super.key,
    required this.onPressed,
    this.width,
    this.height,
    this.backgroundColor,
    required this.buttonText,
    this.buttonTextColor,
    this.radius,
    this.buttonFontWeight,
    this.buttonTextFontFamily,
    this.isDisable = false,
    this.buttonFontSize,
    this.buttonTextDecoration,
  }) : borderColor = Colors.transparent,
       isGhostButton = false;

  const PrimaryButtonWidget.ghostButton({
    super.key,
    required this.onPressed,
    this.width,
    this.height,
    required this.buttonText,
    this.buttonTextColor,
    this.radius,
    this.borderColor,
    this.buttonFontWeight,
    this.buttonTextFontFamily,
    this.isDisable = false,
    this.buttonFontSize,
    this.buttonTextDecoration,
  }) : backgroundColor = Colors.white,
       isGhostButton = true;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      disabledColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius ?? 5),
        side: BorderSide(color: borderColor ?? Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.2)),
      ),
      minWidth: width,
      height: height,
      onPressed: isDisable ? null : () => onPressed(),
      color: isGhostButton ? backgroundColor : Theme.of(context).primaryColor,
      child: EasyTextWidget(
        text: buttonText,
        textColor: isGhostButton ? Theme.of(context).textTheme.bodyMedium?.color : Colors.white,
        fontWeight: buttonFontWeight,
        fontFamily: buttonTextFontFamily,
        decoration: buttonTextDecoration,
        fontSize: buttonFontSize ?? 14,
      ),
    );
  }
}
