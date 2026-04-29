import 'package:flutter/material.dart';
import '../../model/splash/splash_model.dart';

class SplashViewModel extends ChangeNotifier {
  late SplashModel _splashModel;
  bool _isNavigating = false;

  SplashModel get splashModel => _splashModel;
  bool get isNavigating => _isNavigating;

  SplashViewModel() {
    _initializeSplash();
  }

  void _initializeSplash() {
    _splashModel = SplashModel(
      title: 'News App',
      svgPath: 'assets/svgimages/splash.svg',
      duration: 5,
      opacity: 1.0,
    );
  }

  void startNavigation() {
    _isNavigating = true;
    notifyListeners();
  }

  void resetSplash() {
    _isNavigating = false;
    notifyListeners();
  }
}
