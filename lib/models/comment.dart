import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String body, ownerID, commentID, masterCommentID, postID;
  final List replies; // replies are comments
  final List likes;
  final bool isReply;
  final Timestamp timeOfUpload;

  Comment(
      {this.body,
      this.ownerID,
      this.commentID,
      this.masterCommentID,
      this.postID,
      this.replies,
      this.likes,
      this.isReply,
      this.timeOfUpload});

  static Comment fromDocument(DocumentSnapshot documentSnapshot) {
    return Comment(
      body: documentSnapshot.data()['body'],
      ownerID: documentSnapshot.data()['ownerID'],
      commentID: documentSnapshot.data()['commentID'],
      masterCommentID: documentSnapshot.data()['masterCommentID'],
      postID: documentSnapshot.data()['postID'] ?? null,
      replies: documentSnapshot.data()['replies'] ?? [],
      likes: documentSnapshot.data()['likes'] ?? [],
      isReply: documentSnapshot.data()['isReply'],
      timeOfUpload: documentSnapshot.data()['timeOfUpload'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'body': body,
      'ownerID': ownerID,
      'commentID': commentID,
      'masterCommentID': masterCommentID,
      'postID': postID,
      'replies': [],
      'likes': [],
      'isReply': isReply,
      'timeOfUpload': Timestamp.now(),
    };
    return map;
  }
}