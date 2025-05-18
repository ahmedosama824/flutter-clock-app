import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final List<TimeOfDay> _alarms = [];

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _addAlarm() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _alarms.add(picked));
      _saveAlarms();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Alarm set for ${picked.format(context)}")),
      );
    }
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmStrings = _alarms
        .map((alarm) => jsonEncode({'hour': alarm.hour, 'minute': alarm.minute}))
        .toList();
    await prefs.setStringList('alarms', alarmStrings);
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmStrings = prefs.getStringList('alarms') ?? [];

    setState(() {
      _alarms.clear();
      _alarms.addAll(alarmStrings.map((str) {
        final data = jsonDecode(str);
        return TimeOfDay(hour: data['hour'], minute: data['minute']);
      }));
    });
  }

  Future<void> _confirmDelete(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Alarm"),
        content: const Text("Are you sure you want to delete this alarm?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _alarms.removeAt(index));
      _saveAlarms();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alarm deleted")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Alarms"),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[100],
      body: _alarms.isEmpty
          ? const Center(
              child: Text(
                'No Alarms Set',
                style: TextStyle(fontSize: 22, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _alarms.length,
              itemBuilder: (context, index) {
                final alarm = _alarms[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.alarm, color: Colors.deepPurple),
                    title: Text(
                      alarm.format(context),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _confirmDelete(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: _addAlarm,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
