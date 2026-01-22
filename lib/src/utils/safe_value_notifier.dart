import 'package:flutter/material.dart';

class SafeValueNotifier<T> extends ValueNotifier<T> {
  SafeValueNotifier(super.value);

  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  set value(T newValue) {
    if (_isDisposed) return;
    super.value = newValue;
  }
}
