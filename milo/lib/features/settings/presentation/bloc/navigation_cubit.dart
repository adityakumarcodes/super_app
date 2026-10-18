import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class NavigationState {
  const NavigationState({
    required this.view,
    required this.tabOrder,
    required this.hiddenTabs,
  });
  final NavigationView view;
  final List<NavigationTab> tabOrder;
  final Set<NavigationTab> hiddenTabs;
  List<NavigationTab> get visibleTabs => tabOrder
      .where((tab) => !hiddenTabs.contains(tab))
      .toList(growable: false);
  bool isTabVisible(NavigationTab tab) => !hiddenTabs.contains(tab);
}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit(this._preferences) : super(_initial(_preferences));
  final PreferencesService _preferences;
  static NavigationState _initial(PreferencesService preferences) {
    final names = preferences.savedNavigationTabOrder;
    final order = <NavigationTab>[
      for (final name in names)
        ...NavigationTab.values.where((tab) => tab.name == name),
      ...NavigationTab.values.where((tab) => !names.contains(tab.name)),
    ];
    final hidden = preferences.savedHiddenNavigationTabs.toSet();
    return NavigationState(
      view: NavigationView.values.firstWhere(
        (view) => view.name == preferences.savedNavigationView,
        orElse: () => NavigationView.navbar,
      ),
      tabOrder: order,
      hiddenTabs: NavigationTab.values
          .where((tab) => !tab.isRequired && hidden.contains(tab.name))
          .toSet(),
    );
  }

  Future<void> setView(NavigationView view) async {
    if (view == state.view) return;
    await _preferences.saveNavigationView(view.name);
    emit(
      NavigationState(
        view: view,
        tabOrder: state.tabOrder,
        hiddenTabs: state.hiddenTabs,
      ),
    );
  }

  Future<void> setTabVisible(NavigationTab tab, bool visible) async {
    if (tab.isRequired || state.isTabVisible(tab) == visible) return;
    final hidden = {...state.hiddenTabs};
    visible ? hidden.remove(tab) : hidden.add(tab);
    await _preferences.saveHiddenNavigationTabs(
      hidden.map((tab) => tab.name).toList(),
    );
    emit(
      NavigationState(
        view: state.view,
        tabOrder: state.tabOrder,
        hiddenTabs: hidden,
      ),
    );
  }

  Future<void> reorderTabs(int oldIndex, int newIndex) async {
    if (oldIndex < 0 ||
        oldIndex >= state.tabOrder.length ||
        newIndex < 0 ||
        newIndex >= state.tabOrder.length ||
        oldIndex == newIndex) {
      return;
    }
    final tabs = [...state.tabOrder];
    final tab = tabs.removeAt(oldIndex);
    tabs.insert(newIndex, tab);
    await _preferences.saveNavigationTabOrder(
      tabs.map((tab) => tab.name).toList(),
    );
    emit(
      NavigationState(
        view: state.view,
        tabOrder: tabs,
        hiddenTabs: state.hiddenTabs,
      ),
    );
  }
}
