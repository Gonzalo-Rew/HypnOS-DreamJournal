import 'package:flutter/foundation.dart';

/// Small shared notifier used to refresh Dreams list after create/update flows.
class DreamsRefreshBus {
  DreamsRefreshBus._();

  static final ValueNotifier<int> _version = ValueNotifier<int>(0);

  static ValueListenable<int> get listenable => _version;

  static void notifyUpdated() {
    _version.value = _version.value + 1;
  }
}
