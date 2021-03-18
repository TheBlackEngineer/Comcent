import 'package:comcent/imports.dart';

class Post {
  final String topic, title, body, ownerID, postID, community;
  final List photoAttachments, videoAttachments;
  final Timestamp timeOfUpload;
  final int comments, approvals;
  final bool isLeaderPost;

  Post({
    this.topic,
    this.title,
    this.body,
    this.photoAttachments,
    this.videoAttachments,
    this.ownerID,
    this.postID,
    this.community,
    this.timeOfUpload,
    this.comments,
    this.approvals,
    this.isLeaderPost,
  });

  static Post fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      topic: documentSnapshot.data()['topic'],
      title: documentSnapshot.data()['title'],
      body: documentSnapshot.data()['body'],
      photoAttachments: documentSnapshot.data()['photoAttachments'] ?? [],
      videoAttachments: documentSnapshot.data()['videoAttachments'] ?? [],
      ownerID: documentSnapshot.data()['ownerID'],
      postID: documentSnapshot.data()['postID'],
      community: documentSnapshot.data()['community'],
      timeOfUpload: documentSnapshot.data()['timeOfUpload'],
      comments: documentSnapshot.data()['comments'],
      approvals: documentSnapshot.data()['approvals'],
      isLeaderPost: documentSnapshot.data()['isLeaderPost'],
    );
  }

  static Post fromMap(Map<String, dynamic> map) {
    return Post(
      topic: map['topic'],
      title: map['title'],
      body: map['body'],
      photoAttachments: map['photoAttachments'] ?? [],
      videoAttachments: map['videoAttachments'] ?? [],
      ownerID: map['ownerID'],
      postID: map['postID'],
      community: map['community'],
      timeOfUpload: map['timeOfUpload'],
      approvals: map['approvals'],
      comments: map['comments'],
      isLeaderPost: map['isLeaderPost'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'topic': topic,
      'title': title,
      'body': body,
      'photoAttachments': photoAttachments,
      'videoAttachments': videoAttachments,
      'ownerID': ownerID,
      'postID': postID,
      'community': community,
      'timeOfUpload': Timestamp.now(),
      'comments': comments,
      'approvals': approvals,
      'isLeaderPost': isLeaderPost,
    };
    return map;
  }

  static addUserToApprovedByColl({Post post, String userID}) async {
    await FirestoreService.postsCollection
        .doc(post.postID)
        .collection('approvedBy')
        .doc(userID)
        .set({'id': userID});
  }

  static removeUserFromApprovedByColl({Post post, String userID}) async {
    // delete the user's id from the collection of users who have approved this post
    await FirestoreService.postsCollection
        .doc(post.postID)
        .collection('approvedBy')
        .doc(userID)
        .delete();
  }
}
