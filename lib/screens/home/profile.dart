import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:comcent/providers/app_theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comcent/imports.dart';

class Profile extends StatefulWidget {
  final String userID;

  Profile({Key key, @required this.userID}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User user;
  List<QueryDocumentSnapshot> postsSnapshots = [];
  List userFollowers = [];
  var userInterests = [];
  Future<Person> _data;
  CommunityProvider _communityProvider;
  final AuthService authService = AuthService();

  // Get profile owner's posts
  void getPosts() async {
    QuerySnapshot querySnapshot = await FirestoreService.postsCollection
        .where('ownerID', isEqualTo: widget.userID)
        .orderBy('timeOfUpload', descending: true)
        .get();
    List<QueryDocumentSnapshot> docSnapshots = querySnapshot.docs;
    setState(() {
      this.postsSnapshots = docSnapshots;
    });
  }

  void getUserInterests() {
    FirestoreService.usersCollection
        .doc(authService.getCurrentUserID)
        .get()
        .then((docSnapshot) {
      var interests = docSnapshot.data()['interests'];
      setState(() {
        this.userInterests = interests;
      });
    });
  }

  Future<Person> getPerson() async {
    return FirestoreService(uid: widget.userID).personFuture();
  }

  // Get the user's followers
  void getFollowers() async {
    List ids = [];
    QuerySnapshot querySnapshot = await FirestoreService.followersCollection
        .doc(widget.userID)
        .collection('followers')
        .get();
    List<QueryDocumentSnapshot> documentSnapshots = querySnapshot.docs;
    documentSnapshots.forEach((snapshot) {
      ids.add(snapshot.id);
    });
    setState(() {
      this.userFollowers = ids;
    });
  }

  @override
  void initState() {
    super.initState();
    getPosts();
    getFollowers();
    getUserInterests();
    _data = getPerson();
    _communityProvider = Provider.of<CommunityProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    return Scaffold(
      appBar: appBar(
          title: 'Profile',
          context: context,
          onPressed: () => Navigator.pop(context)),
      body: FutureBuilder<Person>(
          future: _data,
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CupertinoActivityIndicator());
            Person profileOwner = snapshot.data;
            return ListView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: 40.0),
              children: [
                // Profile photo
                profileOwner.profilePhoto != null
                    ? Consumer<AppThemeProvider>(
                        builder: (context, value, child) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow:
                                  value.savedTheme == AdaptiveThemeMode.light
                                      ? [
                                          BoxShadow(
                                            color: Colors.grey[350],
                                            offset: Offset(0.0, 5.0), //(x,y)
                                            blurRadius: 10.0,
                                          ),
                                        ]
                                      : [],
                            ),
                            child: GestureDetector(
                              child: CircleAvatar(
                                radius: MediaQuery.of(context).size.width / 7.5,
                                child: CircularProfileAvatar(
                                  profileOwner.profilePhoto,
                                  radius:
                                      MediaQuery.of(context).size.width / 7.5,
                                ),
                              ),
                              // expand image on tap
                              onTap: () => Navigator.push(
                                  context,
                                  TransparentCupertinoPageRoute(
                                      builder: (context) => ImageView(
                                            imageUrl: profileOwner.profilePhoto,
                                          ))),
                            ),
                          );
                        },
                      )
                    : CircleAvatar(
                        radius: MediaQuery.of(context).size.width / 7.5,
                        child: Icon(Icons.person, size: 60.0),
                      ),

                // Username, occupation, location, bio
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      SizedBox(height: 15.0),

                      // username
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            profileOwner.firstName +
                                ' ' +
                                profileOwner.lastName,
                            style: TextStyle(
                                fontSize: 24.0, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),

                          // leader tag if user is leader
                          profileOwner.isLeader
                              ? LeadershipBadge(size: 22.0)
                              : SizedBox.shrink(),
                        ],
                      ),

                      SizedBox(height: 5.0),

                      // occupation and location/sub community
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.grey),
                            text: profileOwner.occupation != null
                                ? profileOwner.occupation
                                : '',
                            children: [
                              TextSpan(
                                text: profileOwner.occupation != null
                                    ? ', '
                                    : ' ',
                              ),
                              TextSpan(
                                text: profileOwner.subCommunity,
                              ),
                            ]),
                      ),

                      SizedBox(height: 12.0),

                      // bio
                      profileOwner.bio != null
                          ? Text(
                              profileOwner.bio,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 17.0, color: Colors.grey),
                            )
                          : SizedBox.shrink()
                    ],
                  ),
                ),

                SizedBox(height: 18.0),

                // Number of posts, community involvement, follow button
                Container(
                  height: 50.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // number of posts
                      Column(
                        children: [
                          Text(profileOwner.posts.toString(),
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                          SizedBox(height: 5.0),
                          Text('Posts',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor))
                        ],
                      ),

                      // divider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: VerticalDivider(
                            thickness: 2.0,
                            endIndent: 5.0,
                            indent: 5.0,
                            color: Theme.of(context).primaryColor),
                      ),

                      // community involvement
                      Column(
                        children: [
                          Text(
                              ((profileOwner.posts / 400) * 100)
                                      .toStringAsFixed(1)
                                      .toString() +
                                  '%',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                          SizedBox(height: 5.0),
                          Text('Community involvement',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor))
                        ],
                      ),

                      // divider
                      profileOwner.id != user.uid
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: VerticalDivider(
                                  thickness: 2.0,
                                  endIndent: 5.0,
                                  indent: 5.0,
                                  color: Theme.of(context).primaryColor),
                            )
                          : SizedBox.shrink(),

                      // follow, unfollow
                      profileOwner.id != user.uid
                          ? StreamBuilder<DocumentSnapshot>(
                              stream: FirestoreService.followersCollection
                                  .doc(widget.userID)
                                  .collection('followers')
                                  .doc(user.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return SizedBox.shrink();
                                }
                                return GradientButton(
                                    label: snapshot.data.exists
                                        ? 'Unfollow'
                                        : 'Follow',
                                    borderRadius: 8.0,
                                    elevated: false,
                                    width:
                                        MediaQuery.of(context).size.width / 3.5,
                                    onPressed: () =>
                                        controlFollowAction(profileOwner));
                              })
                          : SizedBox.shrink(),
                    ],
                  ),
                ),

                // User posts
                this.postsSnapshots.isNotEmpty &&
                        (!profileOwner.privateProfile ||
                            profileOwner.id == user.uid)
                    ? ListView.builder(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.only(top: 20.0, bottom: 30.0),
                        shrinkWrap: true,
                        itemCount: this.postsSnapshots.length,
                        itemBuilder: (context, index) {
                          bool isOwner = user.uid == widget.userID;
                          Post post =
                              Post.fromMap(this.postsSnapshots[index].data());
                          return isOwner
                              ? FocusedMenuHolder(
                                  child: PostCard(post: post),
                                  onPressed: () {},
                                  menuWidth:
                                      MediaQuery.of(context).size.width * 0.50,
                                  blurSize: 5.0,
                                  menuItemExtent: 45,
                                  menuBoxDecoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15.0))),
                                  duration: Duration(milliseconds: 100),
                                  blurBackgroundColor: Colors.black54,
                                  menuOffset:
                                      10.0, // Offset value to show menuItem from the selected item
                                  bottomOffsetHeight: 80.0,

                                  menuItems: <FocusedMenuItem>[
                                    FocusedMenuItem(
                                      title: Text(
                                        "Delete post",
                                        style:
                                            TextStyle(color: Colors.redAccent),
                                      ),
                                      trailingIcon: Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () async {
                                        await EasyLoading.show(
                                            status: 'Deleting post...',
                                            maskType: EasyLoadingMaskType.black,
                                            dismissOnTap: true);

                                        String response =
                                            await attemptPostDelete(
                                                post, index);

                                        response != null
                                            ? EasyLoading.showSuccess(
                                                'Post deleted',
                                                dismissOnTap: true)
                                            : EasyLoading.showError(
                                                'Unable to delete post',
                                                dismissOnTap: true);

                                        EasyLoading.dismiss();
                                      },
                                    ),
                                  ],
                                )
                              : PostCard(post: post);
                        })
                    : Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 6),
                        child: Center(
                            child: Text(
                          profileOwner.privateProfile
                              ? 'This account is private 🔒'
                              : 'No posts yet',
                          style: TextStyle(fontSize: 20.0, color: Colors.grey),
                        )),
                      ),
              ],
            );
          }),
    );
  }

  // Attempt to delete post
  Future attemptPostDelete(Post post, int index) async {
    setState(() {
      this.postsSnapshots.remove(this.postsSnapshots[index]);
    });

    // Remove any reference to the post from the activities collection
    await FirestoreService.activitiesCollection
        .doc(user.uid)
        .collection('activityItems')
        .where('postID', isEqualTo: post.postID)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) => doc.reference.delete());
    });

    // Remove post from bookmarks collection
    await FirestoreService.bookmarksCollection.doc(post.postID).delete();

    // Remove post from posts collection
    await FirestoreService.postsCollection.doc(post.postID).delete();

    // delete post files from firebase storage
    deletePostFiles(post);

    // Remove the post from the owner's timeline
    await FirestoreService.timelineCollection
        .doc(user.uid)
        .collection('feed')
        .doc(post.postID)
        .delete();

    // Remove this post from all user's who have it in their timeline
    if (this.userFollowers.isNotEmpty) {
      for (var userID in this.userFollowers) {
        FirestoreService.timelineCollection
            .doc(userID)
            .collection('feed')
            .doc(post.postID)
            .delete()
            .then(
                (value) => print('A document was removed from user timeline'));
      }
    }

    // Update the user post count
    return await FirestoreService(uid: user.uid)
        .updateUserPostcount(post: post);
  }

  // control following and unfollowing of users
  void controlFollowAction(Person profileOwner) async {
    // unfollow action
    if (this.userFollowers.contains(user.uid)) {
      // For the person being unfollowed, remove the signed in user's uid from the
      // followers collection
      FirestoreService.followersCollection
          .doc(profileOwner.id)
          .collection('followers')
          .doc(user.uid)
          .delete();

      // For the signed in user, remove the profile owner's uid from the followings
      // collection
      FirestoreService.followingsCollection
          .doc(user.uid)
          .collection('followings')
          .doc(profileOwner.id)
          .delete();

      // Remove notification
      FirestoreService.activitiesCollection
          .doc(profileOwner.id)
          .collection('activityItems')
          .doc(user.uid)
          .get()
          .then((document) {
        if (document.exists) document.reference.delete();
      });

      // Timeline editing time
      if (this.postsSnapshots.isNotEmpty) {
        List<QueryDocumentSnapshot> filtered = this
            .postsSnapshots
            .where((queryDocSnap) =>
                !this.userInterests.contains(queryDocSnap.get('topic')))
            .toList();

        // Remove all posts of profile owner from signed in user's timeline
        // except for those that have a topic in the signed in user's interests
        filtered.forEach((queryDocSnap) {
          FirestoreService.timelineCollection
              .doc(user.uid)
              .collection('feed')
              .doc(queryDocSnap.id)
              .delete()
              .then((value) =>
                  print('A document was deleted from user timeline'));
        });
      }
    }

    // Follow action
    else {
      // For the person being followed, add the signed in user's uid to the
      // followers collection
      FirestoreService.followersCollection
          .doc(profileOwner.id)
          .collection('followers')
          .doc(_communityProvider.person.id)
          .set({'id': _communityProvider.person.id});

      // For the signed in user, add the profile owner's uid to the followings
      // collection
      FirestoreService.followingsCollection
          .doc(_communityProvider.person.id)
          .collection('followings')
          .doc(profileOwner.id)
          .set({'id': profileOwner.id});

      // Add notification
      FirestoreService.activitiesCollection
          .doc(profileOwner.id)
          .collection('activityItems')
          .doc(_communityProvider.person.id)
          .set({
        'type': 'follow',
        'ownerID': profileOwner.id,
        'username': _communityProvider.person.firstName +
            ' ' +
            _communityProvider.person.lastName,
        'timestamp': DateTime.now(),
        'userProfileImage': _communityProvider.person.profilePhoto,
        'userID': _communityProvider.person.id
      });

      // Add all of the profile owner's posts to the signed in user's timeline
      if (this.postsSnapshots.isNotEmpty) {
        this.postsSnapshots.forEach((snapshot) {
          FirestoreService.timelineCollection
              .doc(user.uid)
              .collection('feed')
              .doc(snapshot.id)
              .set({
            'topic': snapshot.data()['topic'],
            'timeOfUpload': snapshot.data()['timeOfUpload'],
            'isLeaderPost': snapshot.data()['isLeaderPost'],
          }).then((value) => print('A document was added to user timeline'));
        });
      }
    }
  }

  // get file extension
  String getFileExtension(String url) {
    Uri uri = Uri.parse(url);
    String typeString = uri.path.substring(uri.path.length - 3).toLowerCase();
    return typeString;
  }

  void deletePostFiles(Post post) async {
    // delete any photos if any
    if (post.photoAttachments.isNotEmpty) {
      List photos = post.photoAttachments;
      for (int i = 0; i < photos.length; i++) {
        String imageFileName =
            post.postID + '-I$i.' + getFileExtension(photos[i]);
        await FirestoreService.deleteFile(
            fileName: imageFileName, fileType: 'Post');
      }
    }

    // delete any videos if any
    if (post.videoAttachments.isNotEmpty) {
      List videos = post.videoAttachments;
      for (int i = 0; i < videos.length; i++) {
        String imageFileName =
            post.postID + '-V$i.' + getFileExtension(videos[i]);
        await FirestoreService.deleteFile(
            fileName: imageFileName, fileType: 'Post');
      }
    }
  }
}
