import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';

class BrightnessProvider with ChangeNotifier {
  double _brightness = 50.0;

  double get brightness => _brightness;

  Future<void> setBrightness(double value) async {
    _brightness = value;
    await ScreenBrightness().setScreenBrightness(value / 100);
    notifyListeners();
  }
}
