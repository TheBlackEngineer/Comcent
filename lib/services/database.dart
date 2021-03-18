import 'package:flutter/cupertino.dart';
import 'package:comcent/imports.dart';

class FirestoreService {
  // user uid
  final String uid;

  FirestoreService({this.uid});

  // collection references
  static final CollectionReference userApprovedPostsCollection =
      FirebaseFirestore.instance.collection('userApprovedPosts');

  static final CollectionReference activitiesCollection =
      FirebaseFirestore.instance.collection('activities');

  static final CollectionReference bookmarksCollection =
      FirebaseFirestore.instance.collection('bookmarks');

  static final CollectionReference clubsCollection =
      FirebaseFirestore.instance.collection('clubs');

  static final CollectionReference commentsCollection =
      FirebaseFirestore.instance.collection('comments');

  static final CollectionReference communitiesCollection =
      FirebaseFirestore.instance.collection('communities');

  static final CollectionReference documentsCollection =
      FirebaseFirestore.instance.collection('documents');

  static final CollectionReference followingsCollection =
      FirebaseFirestore.instance.collection('followings');

  static final CollectionReference followersCollection =
      FirebaseFirestore.instance.collection('followers');

  static final CollectionReference leaderPostsCollection =
      FirebaseFirestore.instance.collection('leaderPosts');

  static final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('posts');

  static final CollectionReference subCommunitiesCollection =
      FirebaseFirestore.instance.collection('sub-communities');

  static final CollectionReference timelineCollection =
      FirebaseFirestore.instance.collection('timeline');

  static final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

// -------------------- Setting stuff -------------------------
// data for a new user
  Future setInitialUserData({
    String id,
    String firstName,
    String lastName,
    String phone,
    String email,
    String bio,
    String community,
    String subCommunity,
    String gender,
    String occupation,
    int posts,
    int numberOfWeOurPosts,
    List<String> interests,
    String profilePhoto,
    String referrer,
    bool isLeader,
    bool canPost,
    bool privateProfile,
    Timestamp dateJoined,
    Timestamp dob,
  }) async {
    return await usersCollection.doc(uid).set({
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'bio': bio,
      'community': community,
      'subCommunity': subCommunity,
      'gender': gender,
      'occupation': occupation,
      'posts': posts,
      'numberOfWeOurPosts': numberOfWeOurPosts,
      'interests': interests,
      'profilePhoto': profilePhoto,
      'referrer': referrer,
      'isLeader': isLeader,
      'canPost': canPost,
      'privateProfile': privateProfile,
      'dob': dob,
      'dateJoined': dateJoined
    });
  }

// -------------------- Delete methods -------------------------
  // delete a post from a user's posts
  Future updateUserPostcount({@required Post post, String action}) async {
    DocumentSnapshot userDoc = await usersCollection.doc(uid).get();
    int postCount = userDoc.get('posts');
    int numberOfWeOurPosts = userDoc.get('numberOfWeOurPosts');
    if (action != null) {
      await userDoc.reference.update({'posts': postCount + 1});

      // If the post title starts with we or our, update the numberOfWeOurPosts
      // variable
      if (post.topic.toLowerCase().startsWith('we') ||
          post.topic.toLowerCase().startsWith('our')) {
        await userDoc.reference
            .update({'numberOfWeOurPosts': numberOfWeOurPosts + 1});
      }
      return 'Post added';
    } else {
      await userDoc.reference.update({'posts': postCount - 1});
      if (post.topic.toLowerCase().startsWith('we') ||
          post.topic.toLowerCase().startsWith('our')) {
        await userDoc.reference
            .update({'numberOfWeOurPosts': numberOfWeOurPosts - 1});
      }
      return 'Post deleted';
    }
  }

// -------------------- Fetch methods -------------------------
  // get and make a Person object for a user
  Future<Person> personFuture() async {
    Future<DocumentSnapshot> document =
        FirebaseFirestore.instance.collection("users").doc(uid).get();
    return await document.then((doc) {
      return Person.fromDocument(doc);
    });
  }

  // get user doc stream
  Stream<Person> get userData {
    return usersCollection.doc(uid).snapshots().map((snapshot) {
      return Person.fromDocument(snapshot);
    });
  }

// -------------------- Add methods -------------------------

  // add document to documents collection
  static addDocument(Document document) async {
    await documentsCollection.doc(document.email).set(document.toMap());
  }

  // add post to posts collection
  Future addPost({@required Post post}) async {
    await postsCollection.doc(post.postID).set(post.toMap());
  }

  // add comment to comments collection
  Future addComment(Comment comment) async {
    return commentsCollection.doc(comment.commentID).set(comment.toMap());
  }

  // add comment to comments collection
  Future deleteComment(Comment comment) async {
    return commentsCollection.doc(comment.commentID).delete();
  }

  // add comment to a post's list of comments
  Future<String> updatePostCommentCount(
      {@required String postID,
      String action,
      int numberOfRepliesPlusComment}) async {
    // Get the post
    DocumentSnapshot docSnapshot = await postsCollection.doc(postID).get();

    /// Get the number of comments on the post
    int commentCount = docSnapshot.data()['comments'];

    if (action != null) {
      await postsCollection.doc(postID).update({
        'comments': commentCount + 1,
      });
      return 'Comment added';
    } else {
      numberOfRepliesPlusComment == null
          ? await postsCollection.doc(postID).update({
              'comments': commentCount - 1,
            })
          : await postsCollection.doc(postID).update({
              'comments': commentCount - numberOfRepliesPlusComment,
            });
      return 'Comment removed';
    }
  }

  // Update comment replies
  Future<String> updateCommentReplies(
      {String action,
      @required String masterCommentID,
      @required String replyID}) async {
    if (action != null) {
      // Add reply to a comment's list of replies
      await commentsCollection.doc(masterCommentID).update({
        'replies': FieldValue.arrayUnion([replyID]),
      });
      return 'Comment added';
    } else {
      // Remove reply from a comment's list of replies
      await commentsCollection.doc(masterCommentID).update({
        'replies': FieldValue.arrayRemove([replyID]),
      });
      return 'Comment deleted';
    }
  }

  // ---------------------------------------------------------------------------
  // club methods

  // create club
  static Future createClub(Club club) async {
    // add club to clubs collection
    await clubsCollection.doc(club.id).set(club.toMap());

    var clubDocRef = clubsCollection.doc(club.id);

    // add the creator to the club's members and administrators list
    await clubDocRef.update({
      'members': FieldValue.arrayUnion([club.creator]),
      'administrators': FieldValue.arrayUnion([club.creator]),
      'clubRules': FieldValue.arrayUnion(club.clubRules),
    });
    return clubDocRef.id;
  }

  // get the user's clubs
  static Stream fetchUserClubs() {
    String uid = AuthService().getCurrentUserID;
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  // remove membership request
  static void removeMembershipRequest(String userID, String clubID) async {
    await clubsCollection.doc(clubID).update({
      'membershipRequests': FieldValue.arrayRemove([userID]),
    });
  }

  // remove member from a club
  static Future removeClubMember(String userID, String clubID) async {
    await clubsCollection.doc(clubID).update({
      'members': FieldValue.arrayRemove([userID]),
    });
  }

  // add membership request
  static void addMembershipRequest(String userID, String clubID) async {
    await clubsCollection.doc(clubID).update({
      'membershipRequests': FieldValue.arrayUnion([userID]),
    });
  }

  // accept membership request
  static void acceptMembershipRequest(String userID, String clubID) async {
    // add user to club members
    await clubsCollection.doc(clubID).update({
      'members': FieldValue.arrayUnion([userID]),
    });
  }

  // send message
  static void sendMessage(String clubID, Message message) async {
    clubsCollection
        .doc(clubID)
        .collection('messages')
        .doc(message.messageID)
        .set(message.toMap());
  }

  // ---------------------------------------------------------------------------

  // delete image from firebase storage
  static Future deleteFile({
    @required String fileName,
    @required String fileType,
    String clubID,
  }) async {
    Reference firebaseStorageRef;

    if (fileType == 'Profile') {
      firebaseStorageRef =
          FirebaseStorage.instance.ref().child('Profiles/$fileName');
    } else if (fileType == 'Club') {
      firebaseStorageRef =
          FirebaseStorage.instance.ref().child('ClubProfiles/$fileName');
    } else if (fileType == 'Message') {
      firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('MessageFiles/$clubID/$fileName');
    } else {
      firebaseStorageRef =
          FirebaseStorage.instance.ref().child('Posts/$fileName');
    }

    try {
      await firebaseStorageRef.delete();
    } catch (e) {
      print(e.toString());
    }
  }
}
