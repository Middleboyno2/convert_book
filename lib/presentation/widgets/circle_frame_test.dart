import 'dart:math';

import 'package:flutter/material.dart';

import '../../config/colors/kcolor.dart';
import '../../core/localization/app_localizations.dart';

class CircleFrameTest extends StatefulWidget {
  final Color circleColor;
  final Color borderColor;
  final Color circleFillColor;

  const CircleFrameTest({
    super.key,
    this.circleColor = Kolors.kGold,
    this.borderColor = Kolors.kGray,
    this.circleFillColor = const Color(0x34FAFAFA)
  });

  @override
  State<CircleFrameTest> createState() => _CircleFrameState();
}

class _CircleFrameState extends State<CircleFrameTest> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _topRightCircleAnimation;
  late final Animation<double> _bottomLeftCircleAnimation;
  late final AnimationController _textAnimationController;
  late final Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Khởi tạo animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..forward().then((_) {
      // Khi animation hình tròn kết thúc, bắt đầu animation cho text
      _textAnimationController.forward();
    });

    // Khởi tạo animation controller cho text
    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Animation cho đường tròn góc trên phải
    _topRightCircleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    // Animation cho đường tròn góc dưới trái
    _bottomLeftCircleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeInOut),
      ),
    );

    // Animation cho text opacity
    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.circleColor,
      body: Stack(
        children: [
          // Layer 1: Animated Circles
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: CirclePainter(
                  circleColor: widget.circleColor,
                  circleFillColor: widget.circleFillColor,
                  topRightCircleProgress: _topRightCircleAnimation.value,
                  bottomLeftCircleProgress: _bottomLeftCircleAnimation.value,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Layer 2: Text at bottom
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _textAnimationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _textOpacityAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _textOpacityAnimation.value)),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text(
                          AppLocalizations.of(context).translate('splash.title'),
                          style: TextStyle(
                            color: widget.circleColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final Color circleColor;
  final Color circleFillColor;
  final double topRightCircleProgress;
  final double bottomLeftCircleProgress;


  CirclePainter({
    required this.circleColor,
    required this.circleFillColor,
    required this.topRightCircleProgress,
    required this.bottomLeftCircleProgress,

  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = circleFillColor
      ..style = PaintingStyle.fill;

    // final strokePaint = Paint()
    //   ..color = circleFillColor.withOpacity(0.8)
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 2.0;

    // Áp dụng animation với scale và opacity

    final topRightRadius = 1000 * topRightCircleProgress;
    final topRightOpacity = topRightCircleProgress;

    fillPaint.color = circleFillColor.withOpacity(topRightOpacity * 0.5);
    canvas.drawCircle(
        Offset(size.width + 70, size.height * 0.23), // vị trí tâm circle
        topRightRadius,
        fillPaint
    );

    // Circle bottom với hiệu ứng xuất hiện dần
    final bottomLeftRadius = 1300 * bottomLeftCircleProgress;
    final bottomLeftOpacity = bottomLeftCircleProgress;

    fillPaint.color = circleFillColor.withOpacity(bottomLeftOpacity * 0.5);
    canvas.drawCircle(
        Offset(-10, size.height + 100), // vị trí tâm circle
        bottomLeftRadius,
        fillPaint
    );

  }

  @override
  bool shouldRepaint(covariant CirclePainter oldDelegate) {
    return oldDelegate.topRightCircleProgress != topRightCircleProgress ||
        oldDelegate.bottomLeftCircleProgress != bottomLeftCircleProgress;
  }
}