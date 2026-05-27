import 'package:flutter_riverpod/flutter_riverpod.dart';

class SidebarNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;

  void open() => state = true;

  void close() => state = false;
}

final sidebarProvider = NotifierProvider<SidebarNotifier, bool>(SidebarNotifier.new);
