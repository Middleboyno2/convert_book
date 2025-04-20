
import 'package:doantotnghiep/presentation/widgets/circle_frame_test.dart';
import 'package:doantotnghiep/presentation/widgets/logo_splash.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        // alignment: Alignment.center,
        children: [
          CircleFrameTest(),
          // logo
          Align(
            alignment: Alignment.center,
            child: LogoSplash(),
          ),
        ],
      ),
    );
  }
}
