import 'package:flutter/material.dart';

class Constants {
  static const fontRegular = 16.0;
  static const fontLarge = 18.0;
  static const fontXLarge = 24.0;

  static const labelHeight = 24.0;
  static const buttonHeight = 64.0;
  static const fieldConfigTrailingWidth = 72.0;
  static const imageCardHeight = 200.0;
  static const thumbnailHeight = 200.0;

  static const width16 = SizedBox(width: 16);
  static const width8 = SizedBox(width: 8);
  static const width2 = SizedBox(width: 2);
  static const height16 = SizedBox(height: 16);
  static const height8 = SizedBox(height: 8);

  static const padding0 = EdgeInsets.all(0);
  static const padding16 = EdgeInsets.all(16);
  static const padding24 = EdgeInsets.all(24);
  static const paddingTop16 = EdgeInsets.only(top: 16);

  static var borderRadius = BorderRadius.circular(16);
  static const boxShadow = [
    BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.5), blurRadius: 4)
  ];

  static const dangerColor = Colors.red;
}
