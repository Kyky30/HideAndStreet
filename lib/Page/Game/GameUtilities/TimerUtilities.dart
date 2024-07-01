import 'dart:async';
import 'package:flutter/material.dart';

class TimerUtilities with ChangeNotifier {
  late Timer _timer;
  late int _endTime;
  late Function _onEnd;
  int _remainingTime = 0;

  // Start a timer with an optional start time
  void startTimer({
    required int durationInMinutes,
    required Function onEnd,
    DateTime? startTime,
  }) {
    DateTime start = startTime ?? DateTime.now();
    _endTime = start.millisecondsSinceEpoch + (durationInMinutes * 60 * 1000);
    _onEnd = onEnd;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingTime = _endTime - DateTime.now().millisecondsSinceEpoch;
      if (_remainingTime <= 0) {
        _timer.cancel();
        _onEnd();
      }
      notifyListeners(); // Notify listeners to update the UI
    });
  }

  // Get remaining time in milliseconds
  int get remainingTime => _remainingTime;

  // Dispose the timer
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Format the remaining time as mm:ss
  String get formattedRemainingTime {
    if (_remainingTime <= 0) return "00:00";
    int seconds = (_remainingTime / 1000).round();
    int minutes = (seconds / 60).floor();
    seconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class TimerDisplay extends StatelessWidget {
  final TimerUtilities timerUtilities;

  const TimerDisplay({
    Key? key,
    required this.timerUtilities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: timerUtilities,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            timerUtilities.formattedRemainingTime,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
