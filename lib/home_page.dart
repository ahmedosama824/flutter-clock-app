import 'package:flutter/material.dart';
import 'screens/timer_screen.dart';
import 'screens/alarm_screen.dart';
import 'screens/stopwatch_screen.dart';
import 'screens/world_clock_screen.dart';
import 'screens/settings_screen.dart';

class MyHomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const MyHomePage({super.key, required this.onToggleTheme});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    TimerScreen(),
    AlarmScreen(),
    StopwatchScreen(),
    WorldClockScreen(),
    // SettingsScreen will be added dynamically due to theme toggle
  ];

  final List<String> _titles = [
    'Timer',
    'Alarm',
    'Stopwatch',
    'World Clock',
    'Settings'
  ];

  final List<IconData> _icons = [
    Icons.timer,
    Icons.alarm,
    Icons.timer_off,
    Icons.public,
    Icons.settings,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDrawerItem(int index) {
    return ListTile(
      leading: Icon(_icons[index], color: Colors.white),
      title: Text(_titles[index], style: const TextStyle(color: Colors.white)),
      selected: index == _selectedIndex,
      selectedTileColor: Colors.indigo[700],
      onTap: () {
        Navigator.pop(context);
        _onItemTapped(index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        elevation: 2,
      ),
      drawer: isLargeScreen
          ? null
          : Drawer(
              backgroundColor: Colors.indigo.shade900,
              child: ListView(
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(color: Colors.indigo),
                    child: Text('Clock App',
                        style: TextStyle(color: Colors.white, fontSize: 24)),
                  ),
                  for (int i = 0; i < _titles.length; i++) _buildDrawerItem(i),
                ],
              ),
            ),
      body: Row(
        children: [
          if (isLargeScreen)
            NavigationRail(
              backgroundColor: Colors.indigo.shade50,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.all,
              destinations: List.generate(_titles.length, (i) {
                return NavigationRailDestination(
                  icon: Icon(_icons[i]),
                  label: Text(_titles[i]),
                );
              }),
            ),
          Expanded(
            child: _selectedIndex == 4
                ? SettingsScreen(onToggleTheme: widget.onToggleTheme)
                : _screens[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: isLargeScreen
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.deepPurple,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              onTap: _onItemTapped,
              items: List.generate(_titles.length, (i) {
                return BottomNavigationBarItem(
                  icon: Icon(_icons[i]),
                  label: _titles[i],
                );
              }),
            ),
    );
  }
}
