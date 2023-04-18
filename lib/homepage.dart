import 'dart:async';
import 'package:camo_chat_mod/firebase.dart';
import 'package:camo_chat_mod/loaders.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'message.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Database database = Database();

  List<Message>? filterMessages(List<Message>? messages) {
    List<Message>? filteredMessages = [];
    if(messages!=null) {
      for(var message in messages) {
        if(message.reports>0) {
          filteredMessages.add(message);
        }
      }
    }
    print(filteredMessages);
    for (int i = 0; i < filteredMessages.length - 1; i++) {
      for (int j = 0; j < filteredMessages.length - i - 1; j++) {
        if (filteredMessages[j].reports <= filteredMessages[j + 1].reports) {
          // Swapping using temporary variable
          Message temp = filteredMessages[j];
          filteredMessages[j] = filteredMessages[j + 1];
          filteredMessages[j + 1] = temp;
        }
      }
    }
    return filteredMessages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Moderator")),
      ),
      body: StreamBuilder<List<Message>>(
        stream: database.streamMessages(),
        builder: (_, messagesSnapshot) {
          if(messagesSnapshot.connectionState == ConnectionState.waiting) {
            return const LoaderCircular();
          }
          var messages = filterMessages(messagesSnapshot.data);
          if(messages == null) {
            return Container();
          }
          return ListView.builder(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
            itemCount: messages!.length,
              itemBuilder: (_, index) => MessageCard(message: messages[index])
          );
        },
      ),
    );
  }
}

class MessageCard extends StatefulWidget {
  const MessageCard({Key? key, required this.message}) : super(key: key);
  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  Database database = Database();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 80,
                child: Text("Report: ${widget.message.reports}")
            ),
            SizedBox(
              width: 300,
                child: Text(widget.message.content)
            ),
            SizedBox(
              width: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      database.modUser(widget.message.senderId, widget.message.id, null, true);
                    },
                      child: const Icon(Icons.check,size: 35,color: Colors.white,)
                  ),
                  GestureDetector(
                      onTap: () {
                        database.modUser(widget.message.senderId, widget.message.id, null, false);
                      },
                      child: const Icon(Icons.close,size: 35,color: Colors.white,)
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

