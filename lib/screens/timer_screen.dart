import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _timeInSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadTimer();
  }

  Future<void> _saveTimer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('timeInSeconds', _timeInSeconds);
    await prefs.setBool('isRunning', _isRunning);
    if (_isRunning) {
      await prefs.setInt('startTimestamp', DateTime.now().millisecondsSinceEpoch);
    } else {
      await prefs.remove('startTimestamp');
    }
  }

  Future<void> _loadTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getInt('timeInSeconds') ?? 0;
    final wasRunning = prefs.getBool('isRunning') ?? false;
    final startTimestamp = prefs.getInt('startTimestamp');

    if (wasRunning && startTimestamp != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = ((now - startTimestamp) / 1000).floor();
      final remaining = savedTime - elapsed;
      if (remaining > 0) {
        setState(() {
          _timeInSeconds = remaining;
          _isRunning = true;
        });
        _startTimer(startedFromLoad: true);
      } else {
        setState(() {
          _timeInSeconds = 0;
          _isRunning = false;
        });
        await _clearPrefs();
        _showTimeUpDialog();
      }
    } else {
      setState(() {
        _timeInSeconds = savedTime;
        _isRunning = false;
      });
    }
  }

  Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('timeInSeconds');
    await prefs.remove('isRunning');
    await prefs.remove('startTimestamp');
  }

  void _startTimer({bool startedFromLoad = false}) {
    if (_isRunning && !startedFromLoad) return;
    if (_timeInSeconds == 0) return;

    setState(() => _isRunning = true);
    _saveTimer();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeInSeconds > 0) {
        setState(() => _timeInSeconds--);
        _saveTimer();
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
        _clearPrefs();
        _showTimeUpDialog();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
    _saveTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _timeInSeconds = 0;
      _isRunning = false;
    });
    _clearPrefs();
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("⏰ Time's Up!"),
        content: const Text("The countdown has finished."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _setTimer() async {
    int? newTime = await showDialog<int>(
      context: context,
      builder: (context) {
        int tempTime = 0;
        return AlertDialog(
          title: const Text('Set Timer'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              tempTime = int.tryParse(value) ?? 0;
            },
            decoration: const InputDecoration(
              labelText: 'Enter seconds',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(tempTime),
              child: const Text('Set'),
            ),
          ],
        );
      },
    );

    if (newTime != null) {
      _stopTimer();
      setState(() => _timeInSeconds = newTime);
      _saveTimer();
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatTime(_timeInSeconds),
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 15,
            runSpacing: 15,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _setTimer,
                icon: const Icon(Icons.timer),
                label: const Text('Set'),
              ),
              ElevatedButton.icon(
                onPressed: _isRunning ? _stopTimer : _startTimer,
                icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                label: Text(_isRunning ? 'Pause' : 'Start'),
              ),
              ElevatedButton.icon(
                onPressed: _resetTimer,
                icon: const Icon(Icons.restore),
                label: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
