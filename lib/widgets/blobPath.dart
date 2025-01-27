
import 'dart:ui';

import 'package:flutter/material.dart';

class BlobShapePainter extends CustomPainter {
  final String blobType;

  BlobShapePainter(this.blobType);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;

    switch (blobType) {
      case 'blob1':
        _drawPath0(canvas, paint);
        break;
      case 'blob2':
        _drawPath1(canvas, paint);
        break;
      case 'blob3':
        _drawPath2(canvas, paint);
        break;
      default:
        _drawPath0(canvas, paint); // По умолчанию рисуем path_0
    }
  }

  void _drawPath0(Canvas canvas, Paint paint) {
    Path path_0 = Path();
    path_0.moveTo(164.293, 0.515069);
    path_0.cubicTo(185.544, 5.11044, 188.771, 38.0356, 208.349, 47.4893);
    path_0.cubicTo(227.894, 56.9268, 257.078, 37.396, 272.433, 52.7323);
    path_0.cubicTo(287.02, 67.3013, 276.318, 93.2068, 274.699, 113.757);
    path_0.cubicTo(273.397, 130.289, 268.714, 145.815, 263.852, 161.669);
    path_0.cubicTo(259.269, 176.617, 259.629, 195.792, 246.801, 204.733);
    path_0.cubicTo(233.124, 214.267, 213.373, 202.775, 197.51, 207.91);
    path_0.cubicTo(184.435, 212.143, 176.628, 225.386, 164.293, 231.445);
    path_0.cubicTo(146.983, 239.949, 125.755, 262.439, 110.486, 250.658);
    path_0.cubicTo(93.1362, 237.272, 122.948, 198.995, 105.335, 185.958);
    path_0.cubicTo(78.7018, 166.242, 32.6429, 196.604, 7.81645, 174.657);
    path_0.cubicTo(-9.99095, 158.916, 7.40507, 127.521, 13.141, 104.459);
    path_0.cubicTo(18.8104, 81.6648, 22.8479, 55.5101, 41.1221, 40.7478);
    path_0.cubicTo(59.6032, 25.8183, 87.4074, 33.5976, 109.993, 26.2203);
    path_0.cubicTo(129.271, 19.9233, 144.471, -3.77146, 164.293, 0.515069);
    path_0.close();

    paint.color = Color(0xffFD521B).withOpacity(1.0);
    canvas.drawPath(path_0, paint);
  }

  void _drawPath1(Canvas canvas, Paint paint) {
    Path path_1 = Path();
    path_1.moveTo(13.2644, -150.282);
    path_1.cubicTo(47.6943, -144.601, 66.7304, -103.617, 93.4858, -76.3821);
    path_1.cubicTo(125.513, -43.7808, 178.718, -28.6501, 182.733, 22.225);
    path_1.cubicTo(186.787, 73.5973, 143.842, 110.292, 110.72, 142.016);
    path_1.cubicTo(82.453, 169.09, 48.9732, 188.242, 13.2644, 184.543);
    path_1.cubicTo(-19.9432, 181.102, -49.9253, 156.947, -69.0391, 123.391);
    path_1.cubicTo(-85.5208, 94.4564, -75.7241, 57.2887, -79.194, 22.225);
    path_1.cubicTo(-83.6231, -22.5334, -112.014, -69.3089, -91.8341, -106.961);
    path_1.cubicTo(-70.7018, -146.389, -24.8063, -156.564, 13.2644, -150.282);
    path_1.close();

    paint.color = Color(0xffFD521B).withOpacity(1.0);
    canvas.drawPath(path_1, paint);
  }

  void _drawPath2(Canvas canvas, Paint paint) {
    Path path_2 = Path();
    path_2.moveTo(294.284, 3.26812);
    path_2.cubicTo(338.114, 16.8035, 340.947, 77.7341, 361.734, 117.604);
    path_2.cubicTo(382.34, 157.127, 431.351, 197.563, 415.765, 236.269);
    path_2.cubicTo(398.834, 278.314, 326.817, 263.913, 291.28, 292.564);
    path_2.cubicTo(264.677, 314.012, 272.864, 365.541, 240.12, 377.88);
    path_2.cubicTo(207.742, 390.081, 171.431, 361.16, 136.356, 350.944);
    path_2.cubicTo(100.819, 340.593, 59.1206, 343.481, 32.6783, 317.458);
    path_2.cubicTo(6.09346, 291.295, -0.780869, 251.773, 0.179039, 216.926);
    path_2.cubicTo(1.03721, 185.772, 22.2049, 161.704, 37.6918, 135.455);
    path_2.cubicTo(51.2373, 112.497, 61.9513, 87.1676, 85.0957, 72.9991);
    path_2.cubicTo(108.22, 58.8428, 139.514, 65.8123, 165.728, 57.0742);
    path_2.cubicTo(211.01, 41.9796, 246.258, -11.5631, 294.284, 3.26812);
    path_2.close();

    paint.color = Color(0xffFD521B).withOpacity(1.0);
    canvas.drawPath(path_2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class BlobShape extends StatelessWidget {
  final double width;
  final double height;
  final String blobType;

  const BlobShape({
    required this.width,
    required this.height,
    required this.blobType,
  });

  @override

Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: BlobShapePainter(blobType),
    );
  }
}