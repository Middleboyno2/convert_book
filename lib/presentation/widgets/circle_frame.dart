import 'package:flutter/material.dart';

import '../../config/colors/kcolor.dart';


class CircleFrame extends StatelessWidget {
  final Color circleColor;
  final Color borderColor;
  final Color circleFillColor;
  const CircleFrame({
    super.key,
    this.circleColor = Kolors.kGold,
    this.borderColor = Kolors.kGray,
    this.circleFillColor = const Color(0x34FAFAFA)
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: circleColor,
      body: CustomPaint(
        painter: CirclePainter(circleColor: circleColor, circleFillColor: circleFillColor),
        size: Size.infinite,

      ),
    );

  }
}

class CirclePainter extends CustomPainter{
  final Color circleColor;
  final Color circleFillColor;
  CirclePainter({required this.circleColor, required this.circleFillColor});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = circleFillColor
      ..style = PaintingStyle.fill;
    final paint1 = Paint()
      ..color = circleFillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 3 circle long nhau topright
    canvas.drawCircle(
      Offset(size.width + 70, size.height*0.23), // vi tri tam circle
      400,
      paint
    );

    // canvas.drawCircle(
    //     Offset(size.width +45, size.height*0.2), // vi tri tam circle
    //     350,
    //     paint
    // );

    // canvas.drawCircle(
    //     Offset(size.width +55, size.height*0.16), // vi tri tam circle
    //     330,
    //     paint
    // );

    // canvas.drawCircle(
    //     Offset(size.width * 0.8, size.height*0.4), // vi tri tam circle
    //     200,
    //     paint
    // );

    // circle bottom
    canvas.drawCircle(
        Offset(-10, size.height + 100), // vi tri tam circle
        400,
        paint
    );
    canvas.drawCircle(
        Offset(-10, size.height + 100), // vi tri tam circle
        380,
        paint1
    );


  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }

}
