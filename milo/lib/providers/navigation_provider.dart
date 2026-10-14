import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum NavigationView { navbar, gridView }

enum NavigationTab {
  home,
  notes,
  chat,
  shop,
  social;

  String get label => switch (this) {
    NavigationTab.notes => 'Notes',
    NavigationTab.chat => 'Chat',
    NavigationTab.home => 'Home',
    NavigationTab.shop => 'Shop',
    NavigationTab.social => 'Social',
  };

  String get route => switch (this) {
    NavigationTab.notes => '/notebook',
    NavigationTab.chat => '/chat',
    NavigationTab.home => '/',
    NavigationTab.shop => '/shop',
    NavigationTab.social => '/social',
  };

  IconData get icon => switch (this) {
    NavigationTab.notes => LucideIcons.bookOpen,
    NavigationTab.chat => LucideIcons.messageCircleMore,
    NavigationTab.home => LucideIcons.home,
    NavigationTab.shop => LucideIcons.store,
    NavigationTab.social => LucideIcons.pyramid,
  };

  bool get isRequired =>
      this == NavigationTab.notes || this == NavigationTab.home;
}

class NavigationProvider extends ChangeNotifier {
  NavigationView _view = NavigationView.navbar;
  final List<NavigationTab> _tabOrder = NavigationTab.values.toList();
  final Set<NavigationTab> _hiddenTabs = {};

  NavigationView get view => _view;
  List<NavigationTab> get tabOrder => List.unmodifiable(_tabOrder);
  List<NavigationTab> get visibleTabs =>
      List.unmodifiable(_tabOrder.where((tab) => !_hiddenTabs.contains(tab)));

  bool isTabVisible(NavigationTab tab) => !_hiddenTabs.contains(tab);

  set view(NavigationView view) {
    if (_view == view) return;
    _view = view;
    notifyListeners();
  }

  void setTabVisible(NavigationTab tab, bool visible) {
    if (tab.isRequired || isTabVisible(tab) == visible) return;
    if (visible) {
      _hiddenTabs.remove(tab);
    } else {
      _hiddenTabs.add(tab);
    }
    notifyListeners();
  }

  void reorderTabs(int oldIndex, int newIndex) {
    if (oldIndex == newIndex ||
        oldIndex < 0 ||
        oldIndex >= _tabOrder.length ||
        newIndex < 0 ||
        newIndex >= _tabOrder.length) {
      return;
    }
    final tab = _tabOrder.removeAt(oldIndex);
    _tabOrder.insert(newIndex, tab);
    notifyListeners();
  }
}
