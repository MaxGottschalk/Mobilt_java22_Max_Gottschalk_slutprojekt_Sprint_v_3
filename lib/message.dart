import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slutprojekt/message_composition.dart';
import 'package:flutter_slutprojekt/settings.dart';

class Message extends StatelessWidget {
  final String userEmail;
  const Message({Key? key, required this.userEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages for $userEmail'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            //Re-routs you to settings page
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const Setting(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: getMessages(this.userEmail),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No messages available.'));
          } else {
            final messages = snapshot.data!;
            return ListView.builder(
              itemCount: messages.length,
              //Retrive messages from index
              itemBuilder: (context, index) {
                final messageData =
                    messages[index].data() as Map<String, dynamic>;
                final sender = messageData['sender'];
                final recipient = messageData['recipient'];
                final messageText = messageData['message'];

                //Creates a message card
                return MessageCard(
                  sender: sender,
                  recipient: recipient,
                  messageText: messageText,
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        //Re-routs you to create new message page
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  MessageCompositionScreen(userEmail: userEmail),
            ),
          );
        },
        tooltip: 'Create New Message',
        child: Icon(Icons.add),
      ),
    );
  }
}

class MessageCard extends StatelessWidget {
  final String sender;
  final String recipient;
  final String messageText;

  const MessageCard({
    Key? key,
    required this.sender,
    required this.recipient,
    required this.messageText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: ListTile(
        title: Text('Sender: $sender'),
        subtitle: Text('Recipient: $recipient\n$messageText'),
      ),
    );
  }
}

Future<List<QueryDocumentSnapshot>> getMessages(String userEmail) async {
  try {
    await Firebase.initializeApp();
    final CollectionReference messageCollection =
        FirebaseFirestore.instance.collection('message');

    final QuerySnapshot senderMessagesQuery = await messageCollection
        .where('sender', isEqualTo: userEmail)
        .orderBy('timestamp', descending: true)
        .get();

    final QuerySnapshot recipientMessagesQuery = await messageCollection
        .where('recipient', isEqualTo: userEmail)
        .orderBy('timestamp', descending: true)
        .get();

    final List<QueryDocumentSnapshot> senderMessages = senderMessagesQuery.docs;
    final List<QueryDocumentSnapshot> recipientMessages =
        recipientMessagesQuery.docs;
    final List<QueryDocumentSnapshot> allMessages = [
      ...senderMessages,
      ...recipientMessages
    ];

    allMessages.sort(
        (a, b) => b['timestamp'].toDate().compareTo(a['timestamp'].toDate()));

    return allMessages;
  } catch (e) {
    print('Error fetching messages: $e');
    return [];
  }
}
