import 'package:flutter/material.dart';

class EasyTextWidget extends StatelessWidget {
  const EasyTextWidget({
    super.key,
    required this.text,
    this.textColor,
    this.fontSize = 14,
    this.fontFamily,
    this.textAlign,
    this.fontWeight,
    this.maxLines,
    this.decoration,
    this.height,
    this.letterSpacing,
    this.wordSpacing,
  });

  const EasyTextWidget.errorText({
    super.key,
    required this.text,
    this.textColor,
    this.fontSize = 14,
    this.fontFamily,
    this.fontWeight,
    this.decoration,
    this.height,
    this.letterSpacing,
    this.wordSpacing,
  }) : maxLines = 5,
       textAlign = TextAlign.center;

  final String text;
  final Color? textColor;
  final double fontSize;
  final String? fontFamily;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextDecoration? decoration;
  final double? letterSpacing;
  final double? wordSpacing;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      style: TextStyle(
        fontWeight: fontWeight,
        fontFamily: fontFamily,
        color: textColor ?? Theme.of(context).textTheme.bodyMedium?.color,
        fontSize: fontSize,
        overflow: TextOverflow.ellipsis,
        decoration: decoration,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        height: height,
      ),
    );
  }
}
