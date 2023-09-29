import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class MessageCompositionScreen extends StatelessWidget {
  final String userEmail;
  const MessageCompositionScreen({Key? key, required this.userEmail})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose Message'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recipient\'s Email:'),
            //Text field for user to enter recipients email
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Enter Recipient\'s Email',
              ),
            ),
            const SizedBox(height: 20),
            //Text field for your message
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                hintText: 'Enter Message',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final recipientEmail = emailController.text;
                final message = messageController.text;

                // Check if the recipient user exists
                final userExists = await doesUserExist(recipientEmail);

                if (userExists) {
                  // User exists, proceed with sending the message
                  sendMessage(context, userEmail, recipientEmail, message);
                } else {
                  // User does not exist
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('User not found'),
                        content: const Text(
                            'The recipient user does not exist. Please check the email address.'),
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
                }
              },
              child: const Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> doesUserExist(String email) async {
  try {
    // Initialize Firebase (if not already initialized)
    await Firebase.initializeApp();

    // Create a reference to the "users" collection in Firestore
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    // Query the Firestore database to check if a user with the given email exists
    final QuerySnapshot userQuery =
        await usersCollection.where('email', isEqualTo: email).get();

    // If there are documents returned, the user exists; otherwise, they don't
    return userQuery.docs.isNotEmpty;
  } catch (e) {
    // ignore: avoid_print
    print('Error checking user existence: $e');
    // Handle the error (e.g., show an error message)
    return false;
  }
}

Future<void> sendMessage(BuildContext context, String senderEmail,
    String recipientEmail, String message) async {
  try {
    // Initialize Firebase (if not already initialized)
    await Firebase.initializeApp();

    // Create a reference to the "message" collection in Firestore
    final CollectionReference messageCollection =
        FirebaseFirestore.instance.collection('message');

    // Create a new message document
    await messageCollection.add({
      'sender': senderEmail,
      'recipient': recipientEmail,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message sent successfully!'),
        duration: Duration(seconds: 2), // Adjust the duration as needed
      ),
    );

    // Navigate back to the message page
    Navigator.pop(context);

    // Message sent successfully, you can also perform additional actions if needed
  } catch (e) {
    print('Error sending message: $e');
    // Handle the error (e.g., show an error message)
  }
}
