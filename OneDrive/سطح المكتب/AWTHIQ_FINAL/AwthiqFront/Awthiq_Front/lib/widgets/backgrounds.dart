import 'package:flutter/material.dart';

class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.white),
        Positioned.fill(
          child: CustomPaint(
            painter: SplashWavePainter(),
          ),
        ),
      ],
    );
  }
}


///////////////////////////////////
//////////////////////////////////
/////////////////////////////////


class HomeBackground extends StatelessWidget {
  const HomeBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        // 🤍 خلفية بيضاء
        Container(color: Colors.white),

        // 🎨 التموجات
        Positioned.fill(
          child: CustomPaint(
            painter: BackgroundPainter(),
          ),
        ),

      ],
    );
  }
}

/////////////////////////////////
////////////////////////////////
///////////////////////////////

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

    Paint lightPaint = Paint()
      ..color = Color(0xE0E0EDF2);

    Path lightPath = Path();

    lightPath.moveTo(0, 0);
    lightPath.lineTo(0, size.height * 0.6);

    lightPath.quadraticBezierTo(
      size.width * 0.3, size.height * 0.75,
      size.width * 0.6, size.height * 0.6,
    );

    lightPath.quadraticBezierTo(
      size.width * 0.9, size.height * 0.45,
      size.width, size.height * 0.55,
    );

    lightPath.lineTo(size.width, 0);
    lightPath.close();

    canvas.drawPath(lightPath, lightPaint);

    Paint darkPaint = Paint()
      ..color = Color(0x59B2D2DF);

    Path darkPath = Path();

    darkPath.moveTo(0, 0);
    darkPath.lineTo(0, size.height * 0.4);

    darkPath.quadraticBezierTo(
      size.width * 0.4, size.height * 0.55,
      size.width * 0.8, size.height * 0.4,
    );

    darkPath.lineTo(size.width, size.height * 0.3);
    darkPath.lineTo(size.width, 0);
    darkPath.close();

    canvas.drawPath(darkPath, darkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

////////////////////////////////////////////////
////////////////test splashbackround///////////

class SplashWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

    // 🌊 تموجة فوق يسار
    Paint topPaint = Paint()
      ..color = Color(0xE0E0EDF2);

    Path topPath = Path();

    topPath.moveTo(0, 0);
    topPath.lineTo(size.width * 0.6, 0);

    topPath.quadraticBezierTo(
      size.width * 0.2, size.height * 0.2,
      0, size.height * 0.4,
    );

    topPath.close();

    canvas.drawPath(topPath, topPaint);

    // 🌊 تموجة تحت يمين
    Paint bottomPaint = Paint()
      ..color = Color(0x59B2D2DF);

    Path bottomPath = Path();

    bottomPath.moveTo(size.width, size.height);
    bottomPath.lineTo(size.width * 0.4, size.height);

    bottomPath.quadraticBezierTo(
      size.width * 0.8, size.height * 0.8,
      size.width, size.height * 0.6,
    );

    bottomPath.close();

    canvas.drawPath(bottomPath, bottomPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
