import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Create extends StatelessWidget {
  const Create({super.key});
  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create User'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email Text Field
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
            ),
            // Password Text Field
            TextFormField(
              controller: passwordController,
              obscureText: true, // Hide the password text
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
              ),
            ),
            // Creating a new user
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text;
                final password = passwordController.text;

                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  // User registered successfully
                  createUser(context, email, password);
                  Navigator.of(context).pop(); // Pop the registration screen
                } catch (e) {
                  // Registration failed
                }
              },
              child: const Text('Register'),
            ),
            //Re-routs back to previus page
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('GO BACK'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> createUser(BuildContext context, email, String password) async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp();

    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    // Check if the user already exists
    final existingUser =
        await usersCollection.where('email', isEqualTo: email).get();
    if (existingUser.docs.isNotEmpty) {
      // User already exists, show an error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('User already exists'),
            content: const Text(
                'A user with this email already exists. Please log in or use a different email.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
    // Add the new user document to Firestore
    await usersCollection.add({
      'email': email,
      'password': password,
    });
  } catch (e) {
    // Handle the error
    print('Error creating user: $e');
  }
}
