import 'package:flutter/material.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool isDarkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enable Dark Mode:'),
            Switch(
              value: isDarkModeEnabled,
              onChanged: (value) {
                setState(() {
                  isDarkModeEnabled = value;
                  // Update the theme mode
                  ThemeMode selectedMode =
                      isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light;
                  // Apply the updated theme mode
                  MyApp.of(context)!.setTheme(selectedMode);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  final Widget child;
  final ThemeMode initialThemeMode;

  MyApp({
    required this.child,
    required this.initialThemeMode,
  });

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  void setTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: widget.child,
    );
  }
}

void main() {
  runApp(
    MyApp(
      initialThemeMode: ThemeMode.light, // Set your initial theme mode here
      child: const Setting(),
    ),
  );
}
