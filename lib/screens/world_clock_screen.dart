import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class WorldClockScreen extends StatefulWidget {
  const WorldClockScreen({super.key});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  late Timer _timer;

  final List<_CityTimeZone> _cities = [
    _CityTimeZone(name: 'New York', offset: -4),
    _CityTimeZone(name: 'London', offset: 0),
    _CityTimeZone(name: 'Cairo', offset: 2),
    _CityTimeZone(name: 'Dubai', offset: 4),
    _CityTimeZone(name: 'Tokyo', offset: 9),
    _CityTimeZone(name: 'Sydney', offset: 10),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _getFormattedTime(int offset) {
    final now = DateTime.now().toUtc().add(Duration(hours: offset));
    return DateFormat('HH:mm:ss').format(now);
  }

  String _getFormattedDate(int offset) {
    final now = DateTime.now().toUtc().add(Duration(hours: offset));
    return DateFormat('EEE, MMM d').format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cities.length,
        itemBuilder: (context, index) {
          final city = _cities[index];
          return Card(
            color: Colors.grey.shade900,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              leading: const Icon(Icons.access_time, color: Colors.white),
              title: Text(city.name,
                  style: const TextStyle(fontSize: 20, color: Colors.white)),
              subtitle: Text(
                _getFormattedDate(city.offset),
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Text(
                _getFormattedTime(city.offset),
                style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CityTimeZone {
  final String name;
  final int offset; // Offset from UTC

  const _CityTimeZone({required this.name, required this.offset});
}
