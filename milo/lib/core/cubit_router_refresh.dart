import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bridges a Cubit's stream to GoRouter without putting routing logic in a UI widget.
class CubitRouterRefresh extends ChangeNotifier {
  CubitRouterRefresh(BlocBase<dynamic> cubit) {
    _subscription = cubit.stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
