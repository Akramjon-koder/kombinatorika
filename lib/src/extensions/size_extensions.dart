
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

double _h = 1;
double _w = 1;
double _ar = 1;
double _ge = 1;

/// True while the learner (mobile) UI is laid out — on a phone, or inside the
/// phone-width frame of the web `/user` area. `.a` then scales like on mobile.
bool _phone = !kIsWeb;

/// Sets the scale base. [phone] marks the learner UI rendered on the web
/// (phone-width frame), so `.a` uses the mobile formula there too.
void setSizeExt(Size size, {bool phone = !kIsWeb}){
  _h = size.height / 600;
  _w = size.width / 600;
  _ar = (_h + _w) / 2;
  _ar = sqrt(_h * _w);
  _phone = phone;
}

extension ExtSize on num {
  double get h => this * _h;

  double get w => this * _w;

  //sugges at the mobile
  double get a => this * (_phone ? _ar : (_h > _w ? _w : _h));

  double get g => this * _ge;

  double get min => this * (_h > _w ? _w : _h);

  double get max => this * (_h > _w ? _h : _w);
}

extension ExtUI on num {

  ///Sizedbox
  SizedBox get size => SizedBox(
    width: toDouble(),
    height: toDouble(),
  );

  SizedBox get width => SizedBox(width: toDouble());

  SizedBox get height => SizedBox(height: toDouble());

  ///Edge
  EdgeInsets get left => EdgeInsets.only(left: toDouble());

  EdgeInsets get right => EdgeInsets.only(right: toDouble());

  EdgeInsets get top => EdgeInsets.only(top: toDouble());

  EdgeInsets get bottom => EdgeInsets.only(bottom: toDouble());

  EdgeInsets get topLeft => EdgeInsets.only(
    top: toDouble(),
    left: toDouble(),
  );

  EdgeInsets get topRight => EdgeInsets.only(
    top: toDouble(),
    right: toDouble(),
  );

  EdgeInsets get bottomLeft => EdgeInsets.only(
    bottom: toDouble(),
    left: toDouble(),
  );

  EdgeInsets get bottomRight => EdgeInsets.only(
    bottom: toDouble(),
    right: toDouble(),
  );

  EdgeInsets get horizontal => EdgeInsets.symmetric(horizontal: toDouble());

  EdgeInsets get vertical => EdgeInsets.symmetric(vertical: toDouble());

  EdgeInsets get topLeftBottom => EdgeInsets.only(
    top: toDouble(),
    left: toDouble(),
    bottom: toDouble(),
  );

  EdgeInsets get leftTopRight => EdgeInsets.only(
    left: toDouble(),
    top: toDouble(),
    right: toDouble(),
  );

  EdgeInsets get bottomLeftTop => EdgeInsets.only(
    bottom: toDouble(),
    left: toDouble(),
    top: toDouble(),
  );

  EdgeInsets get rightBottomLeft => EdgeInsets.only(
    right: toDouble(),
    bottom: toDouble(),
    left: toDouble(),
  );

  EdgeInsets get all => EdgeInsets.all(toDouble());

  ///radius
  BorderRadius get rTopLeft => BorderRadius.only(
    topLeft: Radius.circular(toDouble()),
  );

  BorderRadius get rTopRight => BorderRadius.only(
    topRight: Radius.circular(toDouble()),
  );

  BorderRadius get rBottomLeft => BorderRadius.only(
    bottomLeft: Radius.circular(toDouble()),
  );

  BorderRadius get rBottomRight => BorderRadius.only(
    bottomRight: Radius.circular(toDouble()),
  );

  BorderRadius get circular => BorderRadius.circular(toDouble());

  Radius get circularRadius => Radius.circular(toDouble());

}
