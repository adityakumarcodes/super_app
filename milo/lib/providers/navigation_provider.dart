import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:milo/services/preferences_service.dart';

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
  NavigationProvider(this._preferences)
    :
      _view = NavigationView.values.firstWhere(
        (view) => view.name == _preferences.savedNavigationView,
        orElse: () => NavigationView.navbar,
      ),
      _tabOrder = _loadTabOrder(_preferences.savedNavigationTabOrder),
      _hiddenTabs = _loadHiddenTabs(
        _preferences.savedHiddenNavigationTabs,
      );

  final PreferencesService _preferences;
  NavigationView _view;
  final List<NavigationTab> _tabOrder;
  Set<NavigationTab> _hiddenTabs;

  NavigationView get view => _view;
  List<NavigationTab> get tabOrder => List.unmodifiable(_tabOrder);
  List<NavigationTab> get visibleTabs =>
      List.unmodifiable(_tabOrder.where((tab) => !_hiddenTabs.contains(tab)));

  bool isTabVisible(NavigationTab tab) => !_hiddenTabs.contains(tab);

  Future<void> setView(NavigationView view) async {
    if (_view == view) return;
    await _preferences.saveNavigationView(view.name);
    _view = view;
    notifyListeners();
  }

  Future<void> setTabVisible(NavigationTab tab, bool visible) async {
    if (tab.isRequired || isTabVisible(tab) == visible) return;
    final updatedHiddenTabs = Set<NavigationTab>.of(_hiddenTabs);
    if (visible) {
      updatedHiddenTabs.remove(tab);
    } else {
      updatedHiddenTabs.add(tab);
    }
    await _preferences.saveHiddenNavigationTabs(
      updatedHiddenTabs.map((tab) => tab.name).toList(),
    );
    _hiddenTabs = updatedHiddenTabs;
    notifyListeners();
  }

  Future<void> reorderTabs(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex ||
        oldIndex < 0 ||
        oldIndex >= _tabOrder.length ||
        newIndex < 0 ||
        newIndex >= _tabOrder.length) {
      return;
    }
    final updatedOrder = List<NavigationTab>.of(_tabOrder);
    final tab = updatedOrder.removeAt(oldIndex);
    updatedOrder.insert(newIndex, tab);
    await _preferences.saveNavigationTabOrder(
      updatedOrder.map((tab) => tab.name).toList(),
    );
    _tabOrder
      ..clear()
      ..addAll(updatedOrder);
    notifyListeners();
  }

  static List<NavigationTab> _loadTabOrder(List<String> storedOrder) {
    final order = <NavigationTab>[];
    for (final name in storedOrder) {
      for (final tab in NavigationTab.values) {
        if (tab.name == name && !order.contains(tab)) {
          order.add(tab);
          break;
        }
      }
    }
    for (final tab in NavigationTab.values) {
      if (!order.contains(tab)) order.add(tab);
    }
    return order;
  }

  static Set<NavigationTab> _loadHiddenTabs(List<String> storedHiddenTabs) {
    final hiddenNames = storedHiddenTabs.toSet();
    return NavigationTab.values
        .where((tab) => !tab.isRequired && hiddenNames.contains(tab.name))
        .toSet();
  }
}
