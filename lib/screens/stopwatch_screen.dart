import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  late Stopwatch _stopwatch;
  Timer? _timer;
  int _savedElapsed = 0;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _loadStopwatchState();
  }

  Future<void> _loadStopwatchState() async {
    final prefs = await SharedPreferences.getInstance();
    final wasRunning = prefs.getBool('stopwatchRunning') ?? false;
    final savedElapsed = prefs.getInt('stopwatchElapsed') ?? 0;
    final startTimestamp = prefs.getInt('stopwatchStartTimestamp');

    _savedElapsed = savedElapsed;

    if (wasRunning && startTimestamp != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final extraElapsed = now - startTimestamp;
      _savedElapsed += extraElapsed;
      _stopwatch.start();
      _startTimer();
    }

    setState(() {});
  }

  Future<void> _saveStopwatchState() async {
    final prefs = await SharedPreferences.getInstance();
    final totalElapsed = _stopwatch.isRunning
        ? _stopwatch.elapsedMilliseconds + _savedElapsed
        : _savedElapsed;

    await prefs.setBool('stopwatchRunning', _stopwatch.isRunning);
    await prefs.setInt('stopwatchElapsed', totalElapsed);

    if (_stopwatch.isRunning) {
      await prefs.setInt('stopwatchStartTimestamp', DateTime.now().millisecondsSinceEpoch);
    } else {
      await prefs.remove('stopwatchStartTimestamp');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_stopwatch.isRunning) {
        setState(() {});
      }
    });
  }

  void _startStopwatch() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _startTimer();
      _saveStopwatchState();
      setState(() {});
    }
  }

  void _stopStopwatch() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _savedElapsed += _stopwatch.elapsedMilliseconds;
      _stopwatch.reset();
      _timer?.cancel();
      _saveStopwatchState();
      setState(() {});
    }
  }

  void _resetStopwatch() async {
    _stopwatch.stop();
    _stopwatch.reset();
    _savedElapsed = 0;
    _timer?.cancel();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('stopwatchRunning');
    await prefs.remove('stopwatchElapsed');
    await prefs.remove('stopwatchStartTimestamp');

    setState(() {});
  }

  String _formatTime(int totalMilliseconds) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitsMs(int n) => (n ~/ 10).toString().padLeft(2, '0');

    final duration = Duration(milliseconds: totalMilliseconds);
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final milliseconds = twoDigitsMs(duration.inMilliseconds.remainder(1000));

    return "$hours:$minutes:$seconds:$milliseconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _saveStopwatchState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentElapsed = _stopwatch.isRunning
        ? _savedElapsed + _stopwatch.elapsedMilliseconds
        : _savedElapsed;

    return Scaffold(
      appBar: AppBar(title: const Text('Stopwatch')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(currentElapsed),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _stopwatch.isRunning ? _stopStopwatch : _startStopwatch,
                  child: Text(_stopwatch.isRunning ? 'Stop' : 'Start'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _resetStopwatch,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
