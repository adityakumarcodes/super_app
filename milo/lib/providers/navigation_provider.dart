import 'package:flutter/material.dart';

enum NavigationView { navbar, gridView }

class NavigationProvider extends ChangeNotifier {
  NavigationView _view = NavigationView.navbar;

  NavigationView get view => _view;

  set view(NavigationView view) {
    if (_view == view) return;
    _view = view;
    notifyListeners();
  }
}
