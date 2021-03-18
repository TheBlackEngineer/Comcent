import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';
import 'package:timeago/timeago.dart' as timeago;

enum UrlType { IMAGE, VIDEO, UNKNOWN }

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({Key key, @required this.post}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  Future<DocumentSnapshot> getPostOwner;
  User user;
  CommunityProvider _communityProvider;
  String bullet = "\u2022 ";
  PageController controller;
  ExpandableController expandableController;
  int activeIndex = 0;

  Future<DocumentSnapshot> getPerson() {
    return FirestoreService.usersCollection.doc(widget.post.ownerID).get();
  }

  // check if a url is a video or image
  UrlType getUrlType(String url) {
    Uri uri = Uri.parse(url);
    String typeString = uri.path.substring(uri.path.length - 3).toLowerCase();
    if (typeString == 'img') {
      return UrlType.IMAGE;
    }
    if (typeString == 'vid') {
      return UrlType.VIDEO;
    } else {
      return UrlType.UNKNOWN;
    }
  }

  @override
  void initState() {
    super.initState();
    controller = PageController();
    expandableController = ExpandableController();
    getPostOwner = getPerson();
  }

  @override
  void dispose() {
    controller.dispose();
    expandableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List attachments = List.from(widget.post.photoAttachments)
      ..addAll(widget.post.videoAttachments);
    user = Provider.of<User>(context);
    _communityProvider = Provider.of<CommunityProvider>(context, listen: false);

    Timestamp timestamp = widget.post.timeOfUpload;
    DateTime dateTime = timestamp.toDate();

    String tAgo = timeago.format(dateTime);

    return Container(
      color: Theme.of(context).canvasColor,
      margin: const EdgeInsets.only(top: 8.0),
      child: FutureBuilder<DocumentSnapshot>(
          future: getPostOwner,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Person person = Person.fromDocument(snapshot.data);
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Owner profile
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    leading: person.profilePhoto != null
                        ? CircularProfileAvatar(
                            person.profilePhoto,
                            placeHolder: (context, url) {
                              return Container(
                                color: Colors.grey,
                              );
                            },
                            radius: MediaQuery.of(context).size.width / 17,
                          )
                        : CircleAvatar(
                            radius: MediaQuery.of(context).size.width / 17,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                    title: Row(
                      children: [
                        // User name
                        Flexible(
                            child:
                                Text(person.firstName + ' ' + person.lastName)),

                        // leader tag if user is leader
                        person.isLeader ? LeadershipBadge() : SizedBox.shrink(),
                      ],
                    ),
                    subtitle: Text('@' + person.subCommunity + ' - ' + tAgo),
                    trailing: Text(
                      '#' + widget.post.topic,
                      style: TextStyle(
                          color: Theme.of(context).textSelectionColor),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) =>
                                  Profile(userID: person.id)));
                    },
                  ),

                  // post body and title
                  PostTitleAndSubtitle(
                    expandableController: expandableController,
                    postTitle: widget.post.title,
                    postBody: widget.post.body,
                  ),

                  // attachments
                  attachments.isNotEmpty
                      ? Flexible(
                          fit: FlexFit.loose,
                          child: Container(
                            height: MediaQuery.of(context).size.width / 1.1,
                            width: double.infinity,
                            child: PageView.builder(
                              pageSnapping: true,
                              controller: controller,
                              physics: BouncingScrollPhysics(),
                              itemCount: attachments.length,
                              onPageChanged: (value) {
                                setState(() {
                                  activeIndex = value;
                                });
                              },
                              itemBuilder: (context, index) {
                                String file = attachments[index];
                                UrlType urlType = getUrlType(file);
                                if (urlType == UrlType.IMAGE) {
                                  return GestureDetector(
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) => Image.asset(
                                          'assets/illustrations/placeholder.png'),
                                      imageUrl: file,
                                      fit: BoxFit.cover,
                                    ),
                                    onTap: () => Navigator.push(
                                        context,
                                        TransparentCupertinoPageRoute(
                                            builder: (context) => ImageView(
                                                  imageUrl: file,
                                                ))),
                                  );
                                } else if (urlType == UrlType.VIDEO) {
                                  return ChewieListItem(
                                    videoPlayerController:
                                        VideoPlayerController.network(file),
                                  );
                                } else {
                                  return Container(
                                    color: Colors.yellow,
                                  );
                                }
                              },
                            ),
                          ))
                      : SizedBox(height: 12.0),

                  // Dots indicator
                  attachments.length > 1
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Center(
                            child: AnimatedSmoothIndicator(
                              activeIndex: activeIndex,
                              count: attachments.length,
                              effect: JumpingDotEffect(
                                  dotHeight: 8.0,
                                  dotWidth: 8.0,
                                  activeDotColor: Theme.of(context)
                                      .primaryColor), // your preferred effect
                            ),
                          ),
                        )
                      : SizedBox.shrink(),

                  // Footer
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Approve and comment icons
                        Row(
                          children: [
                            // Approve icon
                            Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: StreamBuilder<DocumentSnapshot>(
                                stream: FirestoreService.postsCollection
                                    .doc(widget.post.postID)
                                    .collection('approvedBy')
                                    .doc(user.uid)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    DocumentSnapshot document = snapshot.data;
                                    bool liked = document.exists;
                                    return GestureDetector(
                                        child: Icon(
                                          liked
                                              ? Icons.check_circle_outline
                                              : Icons.check_circle_outline,
                                          color: liked
                                              ? Colors.green
                                              : Theme.of(context)
                                                  .textSelectionColor,
                                          size: 32.0,
                                        ),
                                        onTap: () => controlLikeAction(liked));
                                  } else {
                                    return Icon(
                                      Icons.check_circle_outline,
                                      color:
                                          Theme.of(context).textSelectionColor,
                                    );
                                  }
                                },
                              ),
                            ),

                            // Comment icon
                            GestureDetector(
                              child:
                                  Icon(Icons.chat_bubble_outline, size: 30.0),
                              onTap: () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) =>
                                      CommentScreen(post: widget.post),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Approvals and comments
                        Row(
                          children: [
                            // Number of approvals
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirestoreService.postsCollection
                                  .doc(widget.post.postID)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  int likes = snapshot.data['approvals'];
                                  return GestureDetector(
                                    child: Text(likes.toString() +
                                        (likes != 1
                                            ? ' Approvals  '
                                            : ' Approval  ')),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) =>
                                              ApprovalsList(post: widget.post),
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  return SizedBox.shrink();
                                }
                              },
                            ),

                            Text(bullet),

                            // Number of comments
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirestoreService.postsCollection
                                  .doc(widget.post.postID)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  int comments = snapshot.data['comments'];
                                  return GestureDetector(
                                    child: Text(comments.toString() +
                                        (comments != 1
                                            ? ' Comments  '
                                            : ' Comment  ')),
                                    onTap: () => Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) =>
                                            CommentScreen(post: widget.post),
                                      ),
                                    ),
                                  );
                                } else {
                                  return SizedBox.shrink();
                                }
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return SizedBox.shrink();
            }
          }),
    );
  }

  controlLikeAction(bool liked) async {
    // Check if the post owner is the same person as the signed in user
    bool isNotPostOwner = widget.post.ownerID != user.uid;

    // Get the number of approvals for this post
    int approvalCount = await FirestoreService.postsCollection
        .doc(widget.post.postID)
        .get()
        .then((DocumentSnapshot documentSnapshot) =>
            documentSnapshot.data()['approvals']);

    if (liked) {
      // Reduce the number of approvals by 1
      int updatedApprovalCount = approvalCount -= 1;

      await Post.removeUserFromApprovedByColl(
        post: widget.post,
        userID: user.uid,
      );

      // Reduce approvals by one
      await FirestoreService.postsCollection
          .doc(widget.post.postID)
          .update({'approvals': updatedApprovalCount});

      // Remove this post from the users userApprovedPosts
      await FirestoreService.userApprovedPostsCollection
          .doc(user.uid)
          .collection('userApprovedPosts')
          .doc(widget.post.postID)
          .delete();

      // Remove this activity from the activities collection
      if (isNotPostOwner) {
        await FirestoreService.activitiesCollection
            .doc(widget.post.ownerID)
            .collection('activityItems')
            .doc(widget.post.postID)
            .get()
            .then((document) {
          if (document.exists) document.reference.delete();
        });
      }
    } else {
      // Increase the number of approvals by 1
      int updatedApprovalCount = approvalCount += 1;

      await Post.addUserToApprovedByColl(
        post: widget.post,
        userID: user.uid,
      );

      // Increase approvals by one
      await FirestoreService.postsCollection
          .doc(widget.post.postID)
          .update({'approvals': updatedApprovalCount});

      // Add this post to the users userApprovedPosts
      await FirestoreService.userApprovedPostsCollection
          .doc(user.uid)
          .collection('userApprovedPosts')
          .doc(widget.post.postID)
          .set({});

      // Add this action to the activities collection
      if (isNotPostOwner) {
        await FirestoreService.activitiesCollection
            .doc(widget.post.ownerID)
            .collection('activityItems')
            .add({
          'type': 'approval',
          'ownerID': widget.post.ownerID,
          'username': _communityProvider.person.firstName +
              ' ' +
              _communityProvider.person.lastName,
          'timestamp': DateTime.now(),
          'userProfileImage': _communityProvider.person.profilePhoto,
          'userID': user.uid,
          'postID': widget.post.postID,
          'postImage': widget.post.photoAttachments.isNotEmpty
              ? widget.post.photoAttachments[0]
              : null,
        });
      }
    }
  }
}
