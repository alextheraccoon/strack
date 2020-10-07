import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';


class TimerService extends ChangeNotifier {
  Stopwatch _watch;
  Timer _timer;
  int _pauses = 0;


  Duration get currentDuration => _currentDuration;
  Duration _currentDuration = Duration.zero;

  bool get isRunning => _timer != null;

  bool get activityStarted => _activityStarted;
  bool _activityStarted = false;

  int get pauses => _pauses;


  TimerService() {
    _watch = Stopwatch();
  }

  void _onTick(Timer timer) {
    _currentDuration = _watch.elapsed;

    // notify all listening widgets
    notifyListeners();
  }

  void start() {
    if (_timer != null) return;

    _timer = Timer.periodic(Duration(days: 0, hours: 0, minutes: 0, seconds: 1), _onTick);
    _watch.start();
    _activityStarted = true;

    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _watch.stop();
    _currentDuration = _watch.elapsed;
    _pauses++;

    notifyListeners();
  }

  void reset() {
    stop();
    _watch.reset();
    _currentDuration = Duration.zero;
    _activityStarted = false;
    _pauses = 0;
    notifyListeners();
  }

  static TimerService of(BuildContext context) {
    var provider = context.dependOnInheritedWidgetOfExactType<TimerServiceProvider>();
    return provider.service;
  }
}

class TimerServiceProvider extends InheritedWidget {
  const TimerServiceProvider({Key key, this.service, Widget child}) : super(key: key, child: child);

  final TimerService service;

  @override
  bool updateShouldNotify(TimerServiceProvider old) => service != old.service;
}