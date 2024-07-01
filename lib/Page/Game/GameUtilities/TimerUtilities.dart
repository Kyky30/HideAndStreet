import 'dart:async';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class TimerUtilities with ChangeNotifier {
  late Timer _timer;
  late int _endTime;
  late Function _onEnd;
  int _remainingTime = 0;
  late IconData _icon = Symbols.timer_rounded;
  late String _timerName = 'Timer :';

  // Start a timer with an optional start time
  void startTimer({
    required int durationInMinutes,
    required Function onEnd,
    DateTime? startTime,
    required IconData icon,
    required String timerName,
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
    _icon = icon;
    _timerName = timerName;
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
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Color(0xFF373967),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timerUtilities._timerName,
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              Text(
                timerUtilities.formattedRemainingTime,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              Icon(
                timerUtilities._icon,
                fill: 1,
                weight: 700,
                grade: 200,
                opticalSize: 24, // Icone du timer (horloge
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        );
      },
    );
  }
}
