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
  List posts = [];
  Future<Person> _data;
  CommunityProvider _communityProvider;
  final AuthService authService = AuthService();

  Future<Person> getPerson() async {
    return FirestoreService(uid: widget.userID).personFuture();
  }

  void setPosts() async {
    Person person = await FirestoreService(uid: widget.userID).personFuture();
    posts = person.posts.reversed.toList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setPosts();
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
              return Center(child: CircularProgressIndicator());
            Person profileOwner = snapshot.data;
            return ListView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: 40.0),
              children: [
                // profile photo
                profileOwner.profilePhoto != null
                    ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[350],
                              offset: Offset(0.0, 5.0), //(x,y)
                              blurRadius: 10.0,
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          child: CircleAvatar(
                            radius: MediaQuery.of(context).size.width / 7.5,
                            child: CircularProfileAvatar(
                              profileOwner.profilePhoto,
                              radius: MediaQuery.of(context).size.width / 7.5,
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
                      )
                    : CircleAvatar(
                        radius: MediaQuery.of(context).size.width / 7.5,
                        child: Icon(Icons.person, size: 60.0),
                      ),

                //SizedBox(height: 18.0),

                // username, occupation, location, bio
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

                // number of posts, community involvement, follow button
                Container(
                  height: 50.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // number of posts
                      Column(
                        children: [
                          Text(profileOwner.posts.length.toString(),
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
                              ((profileOwner.posts.length / 400) * 100)
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
                          ? GradientButton(
                              label: profileOwner.followers.contains(user.uid)
                                  ? 'Unfollow'
                                  : 'Follow',
                              borderRadius: 8.0,
                              elevated: false,
                              width: MediaQuery.of(context).size.width / 3.5,
                              onPressed: () =>
                                  controlFollowAction(profileOwner))
                          : SizedBox.shrink(),
                    ],
                  ),
                ),

                // user posts
                posts.isNotEmpty &&
                        (!profileOwner.privateProfile ||
                            profileOwner.id == user.uid)
                    ? ListView.builder(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        shrinkWrap: true,
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirestoreService.postsCollection
                                .doc(posts[index])
                                .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return SizedBox.shrink();
                              }
                              Post post = Post.fromDocument(snapshot.data);

                              bool isOwner = user.uid == widget.userID;
                              return isOwner
                                  ? FocusedMenuHolder(
                                      child: PostCard(post: post),
                                      onPressed: () {},
                                      menuWidth:
                                          MediaQuery.of(context).size.width *
                                              0.50,
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
                                              style: TextStyle(
                                                  color: Colors.redAccent),
                                            ),
                                            trailingIcon: Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                            ),
                                            onPressed: () async {
                                              setState(() {
                                                posts.remove(posts[index]);
                                              });

                                              // remove post id from user's posts
                                              await FirestoreService(
                                                      uid: user.uid)
                                                  .deleteFromUserPosts(
                                                      postID: post.postID);

                                              // remove any reference to the post from the notifications collection
                                              await FirestoreService
                                                  .activitiesCollection
                                                  .doc(user.uid)
                                                  .collection('activityItems')
                                                  .where('postID',
                                                      isEqualTo: post.postID)
                                                  .get()
                                                  .then((querySnapshot) {
                                                querySnapshot.docs.forEach(
                                                    (doc) =>
                                                        doc.reference.delete());
                                              });

                                              // remove post from bookmarks collection
                                              await FirestoreService
                                                  .bookmarksCollection
                                                  .doc(post.postID)
                                                  .delete();

                                              // remove document from posts collection
                                              await FirestoreService
                                                  .postsCollection
                                                  .doc(post.postID)
                                                  .delete();

                                              // delete post files from firebase storage
                                              deletePostFiles(post);
                                            }),
                                      ],
                                    )
                                  : PostCard(post: post);
                            },
                          );
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

  // control following and unfollowing of users
  controlFollowAction(Person profileOwner) async {
    // unfollow action
    if (profileOwner.followers.contains(user.uid)) {
      // current online user follows user, we unfollow
      setState(() {
        profileOwner.followers.remove(user.uid);
      });
      // update fields in firestore
      await FirestoreService.usersCollection.doc(profileOwner.id).update({
        'followers': FieldValue.arrayRemove([_communityProvider.person.id]),
      });

      await FirestoreService.usersCollection
          .doc(_communityProvider.person.id)
          .update({
        'following': FieldValue.arrayRemove([profileOwner.id]),
      });

      FirestoreService.activitiesCollection
          .doc(profileOwner.id)
          .collection('activityItems')
          .doc(_communityProvider.person.id)
          .get()
          .then((document) {
        if (document.exists) document.reference.delete();
      });

      // remove the signed in user's id to the 'visibleTo' list of every post belon
      // ging to the profile owner
      profileOwner.posts.forEach((postID) {
        FirestoreService.postsCollection.doc(postID).update({
          'visibleTo': FieldValue.arrayRemove([_communityProvider.person.id])
        });
      });

      // remove notification
      await FirestoreService.activitiesCollection
          .doc(profileOwner.id)
          .collection('activityItems')
          .doc(user.uid)
          .delete();
    }

    // follow action
    else {
      // current online user does not follow user, we follow
      setState(() {
        profileOwner.followers.add(user.uid);
      });
      // update fields in firestore
      await FirestoreService.usersCollection.doc(profileOwner.id).update({
        'followers': FieldValue.arrayUnion([_communityProvider.person.id]),
      });

      await FirestoreService.usersCollection
          .doc(_communityProvider.person.id)
          .update({
        'following': FieldValue.arrayUnion([profileOwner.id]),
      });

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

      // add the signed in user's id to the 'visibleTo' list of every post belon
      // ging to the profile owner
      profileOwner.posts.forEach((postID) {
        FirestoreService.postsCollection.doc(postID).update({
          'visibleTo': FieldValue.arrayUnion([_communityProvider.person.id])
        });
      });
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
