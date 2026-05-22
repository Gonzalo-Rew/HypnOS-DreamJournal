import 'package:flutter/foundation.dart';

/// Shared notifier to force Dashboard reload when the tab is opened.
class DashboardRefreshBus {
  DashboardRefreshBus._();

  static final ValueNotifier<int> _version = ValueNotifier<int>(0);

  static ValueListenable<int> get listenable => _version;

  static void notifyRefreshRequested() {
    _version.value = _version.value + 1;
  }
}
