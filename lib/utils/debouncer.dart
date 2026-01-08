import 'dart:async';

/// Debouncer utility to limit the rate of function calls
/// Useful for search inputs to avoid excessive API calls or rebuilds
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 300});

  /// Run the action after the debounce delay
  /// Cancels any pending action if called again before delay completes
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancel any pending action
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose the debouncer
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Throttler utility to limit function calls to once per interval
/// Unlike debouncer, this executes immediately then ignores subsequent calls
class Throttler {
  final int milliseconds;
  DateTime? _lastExecutionTime;

  Throttler({this.milliseconds = 300});

  /// Run the action if enough time has passed since last execution
  void run(void Function() action) {
    final now = DateTime.now();
    if (_lastExecutionTime == null ||
        now.difference(_lastExecutionTime!).inMilliseconds >= milliseconds) {
      _lastExecutionTime = now;
      action();
    }
  }

  /// Reset the throttler
  void reset() {
    _lastExecutionTime = null;
  }
}
