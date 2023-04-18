import 'dart:convert';
import 'user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Post postFromJson(Map<String, dynamic> str) =>
    Post.fromJson(json.decode(json.encode(str,
        toEncodable: (time) => (time as Timestamp).toDate().toString())));

class Post {
  Post({
    required this.reports,
    required this.senderId,
    required this.content,
    required this.isModded,
    required this.timestamp,
    required this.likes,
  });

  String? id;
  User? sender;
  int reports;
  String senderId;
  String content;
  bool isModded;
  DateTime timestamp;
  int likes;

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        reports: json["reports"],
        senderId: json["sender_id"].trim(),
        content: json["content"],
        isModded: json["is_modded"],
        timestamp: DateTime.parse(json["timestamp"]),
        likes: json["likes"],
      );
}
