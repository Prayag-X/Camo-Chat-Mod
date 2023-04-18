import 'dart:async';
import 'package:camo_chat_mod/post.dart';
import 'package:camo_chat_mod/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'message.dart';

class Database {
  final collectionUsers = FirebaseFirestore.instance.collection('Users');
  final collectionMessages = FirebaseFirestore.instance.collection('Messages');
  final collectionPosts = FirebaseFirestore.instance.collection('Posts');

  modUser(String uid, String? messageId, String? postId, bool mod) async {
    User user = await collectionUsers.doc(uid).get().then(
        (DocumentSnapshot doc) =>
            userFromJson(doc.data() as Map<String, dynamic>));
    if (messageId != null) {
      await collectionMessages.doc(messageId).update({
        'is_modded': true,
      });
    } else {
      await collectionPosts.doc(messageId).update({
        'is_modded': true,
      });
    }

    if (mod) {
      await collectionUsers.doc(uid).update({
        'modded_reports': user.moddedReports + 1,
      });
    }
  }

  List<Message> _messageFromSnap(QuerySnapshot snapshot) =>
      snapshot.docs.map((doc) {
        var message = messageFromJson(doc.data() as Map<String, dynamic>);
        message.id = doc.id;
        return message;
      }).toList();

  Stream<List<Message>> streamMessages() => collectionMessages
      .where("is_modded", isEqualTo: false)
      // .where("reports", isNotEqualTo: 0)
      // .orderBy("reports")
      .snapshots(includeMetadataChanges: true)
      .map(_messageFromSnap);

  List<Post> _postFromSnap(QuerySnapshot snapshot) => snapshot.docs.map((doc) {
        var post = postFromJson(doc.data() as Map<String, dynamic>);
        post.id = doc.id;
        return post;
      }).toList();

  Stream<List<Post>> streamPosts() => collectionPosts
      .where("is_modded", isEqualTo: false)
      .where("reports", isGreaterThan: 0)
      .orderBy("reports", descending: true)
      .snapshots(includeMetadataChanges: true)
      .map(_postFromSnap);
}
