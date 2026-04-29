import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to home screen after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // SVG Image positioned with the specified constraints
          Positioned(
            top: 334,
            left: 143,
            child: Transform.rotate(
              angle: 0, // 0 degrees
              child: Opacity(
                opacity: 1,
                child: SvgPicture.asset(
                  'assets/svgimages/splash.svg',
                  width: 107,
                  height: 184,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
