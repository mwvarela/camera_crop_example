import 'dart:math';

import 'package:flutter/foundation.dart';

class CameraLevel {
  final ValueNotifier<double> _notifier = ValueNotifier(0);

  ValueNotifier<double> get notifier => _notifier;

  int get level => (_notifier.value * 10).round();

  bool get podeAumentar => _notifier.value < 1.0;
  bool get podeDiminuir => _notifier.value > 0.0;

  void aumentar() {
    var valor = min(10, level + 1);
    _notifier.value = valor / 10;
  }

  void diminuir() {
    var valor = max(0, level - 1);
    _notifier.value = valor > 0 ? valor / 10 : 0;
  }

  void dispose() {
    _notifier.dispose();
  }
}
