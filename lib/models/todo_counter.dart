import 'package:flutter/material.dart';

class TodoCounter extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void setCount(int newCount) {
    _count = newCount;
    notifyListeners();
  }
}
