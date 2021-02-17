import 'package:comcent/imports.dart';

class Post {
  final String topic, title, body, ownerID, postID, community;
  final List photoAttachments, videoAttachments, bookmarkedBy;
  // comments - List<String> for storing comment IDs
  // usersWhoLiked - List<String> for storing the IDs of users who liked a post
  final List comments, usersWhoLiked, visibleTo;
  final Timestamp timeOfUpload;

  Post({
    this.topic,
    this.title,
    this.body,
    this.photoAttachments,
    this.videoAttachments,
    this.bookmarkedBy,
    this.ownerID,
    this.postID,
    this.community,
    this.comments,
    this.usersWhoLiked,
    this.visibleTo,
    this.timeOfUpload,
  });

  static Post fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      topic: documentSnapshot.data()['topic'],
      title: documentSnapshot.data()['title'],
      body: documentSnapshot.data()['body'],
      photoAttachments: documentSnapshot.data()['photoAttachments'] ?? [],
      videoAttachments: documentSnapshot.data()['videoAttachments'] ?? [],
      bookmarkedBy: documentSnapshot.data()['bookmarkedBy'] ?? [],
      ownerID: documentSnapshot.data()['ownerID'],
      postID: documentSnapshot.data()['postID'],
      community: documentSnapshot.data()['community'],
      comments: documentSnapshot.data()['comments'] ?? [],
      usersWhoLiked: documentSnapshot.data()['usersWhoLiked'] ?? [],
      visibleTo: documentSnapshot.data()['visibleTo'] ?? [],
      timeOfUpload: documentSnapshot.data()['timeOfUpload'],
    );
  }

  static Post fromMap(Map<String, dynamic> map) {
    return Post(
      topic: map['topic'],
      title: map['title'],
      body: map['body'],
      photoAttachments: map['photoAttachments'] ?? [],
      videoAttachments: map['videoAttachments'] ?? [],
      bookmarkedBy: map['bookmarkedBy'] ?? [],
      ownerID: map['ownerID'],
      postID: map['postID'],
      community: map['community'],
      comments: map['comments'] ?? [],
      usersWhoLiked: map['usersWhoLiked'] ?? [],
      visibleTo: map['visibleTo'] ?? [],
      timeOfUpload: map['timeOfUpload'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'topic': topic,
      'title': title,
      'body': body,
      'photoAttachments': photoAttachments,
      'videoAttachments': videoAttachments,
      'bookmarkedBy': bookmarkedBy,
      'ownerID': ownerID,
      'postID': postID,
      'community': community,
      'comments': comments,
      'usersWhoLiked': usersWhoLiked,
      'visibleTo': visibleTo,
      'timeOfUpload': Timestamp.now(),
    };
    return map;
  }

  // increase likes
  static Future<String> addUserToLikesList({Post post, String userID}) async {
    await FirestoreService.postsCollection.doc(post.postID).update({
      'usersWhoLiked': FieldValue.arrayUnion([userID]),
    });
    return 'User added';
  }

  // increase dislikes
  static Future<String> removeUserFromLikesList(
      {Post post, String userID}) async {
    await FirestoreService.postsCollection.doc(post.postID).update({
      'usersWhoLiked': FieldValue.arrayRemove([userID]),
    });
    return 'User removed';
  }
}
