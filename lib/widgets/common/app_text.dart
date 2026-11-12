import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  factory AppText.heading(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
  }) {
    return AppText(
      text,
      key: key,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      textAlign: textAlign,
    );
  }

  factory AppText.title(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
  }) {
    return AppText(
      text,
      key: key,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      textAlign: textAlign,
    );
  }

  factory AppText.body(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
  }) {
    return AppText(
      text,
      key: key,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color,
      ),
      textAlign: textAlign,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
