import 'package:flutter/material.dart';

class BottomBarService extends ChangeNotifier {
  int currentIndex = 0;

  void changeIndex(int index) {
    if (index < 0) return;
    if (currentIndex == index) return;
    currentIndex = index;
    notifyListeners();
  }
}
