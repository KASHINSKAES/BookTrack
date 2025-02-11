// Place fonts/MyFlutter.ttf in your fonts/ directory and
// add the following to your pubspec.yaml
// flutter:
//   fonts:
//    - family: MyFlutter
//      fonts:
//       - asset: fonts/MyFlutter.ttf
import 'package:flutter/widgets.dart';

class MyFlutter {
  MyFlutter._();

  static const String _fontFamily = 'MyFlutter';

  static const IconData sun = IconData(0xe900, fontFamily: _fontFamily);
  static const IconData bonus = IconData(0xe901, fontFamily: _fontFamily);
  static const IconData bookmarkCircle =
      IconData(0xe902, fontFamily: _fontFamily);
  static const IconData calendar = IconData(0xe903, fontFamily: _fontFamily);
  static const IconData chatObsh = IconData(0xe904, fontFamily: _fontFamily);
  static const IconData level = IconData(0xe906, fontFamily: _fontFamily);
  static const IconData setting = IconData(0xe907, fontFamily: _fontFamily);
  static const IconData setting2 = IconData(0xe909, fontFamily: _fontFamily);
  static const IconData statistik = IconData(0xe90c, fontFamily: _fontFamily);
}
