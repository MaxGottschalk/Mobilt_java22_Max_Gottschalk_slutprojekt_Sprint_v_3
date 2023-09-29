import 'package:flutter/material.dart';
import 'package:flutter_slutprojekt/message.dart';
import 'package:flutter_slutprojekt/settings.dart';

class LoggedIn extends StatelessWidget {
  final String userEmail;
  const LoggedIn({Key? key, required this.userEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logged In'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('This is the Login page!'),
            //Re-routs you to settings page
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const Setting(),
                  ),
                );
              },
              child: const Text('Settings'),
            ),
            //Re-routs you to Message page
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Message(userEmail: userEmail),
                  ),
                );
              },
              child: const Text('Message'),
            ),
          ],
        ),
      ),
    );
  }
}
