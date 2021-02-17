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
  Stream<DocumentSnapshot> getPostOwner;
  User user;
  CommunityProvider _communityProvider;
  String bullet = "\u2022 ";
  final PageController controller = PageController();
  final ExpandableController expandableController = ExpandableController();
  int activeIndex = 0;

  Stream<DocumentSnapshot> getPerson() {
    return FirestoreService.usersCollection
        .doc(widget.post.ownerID)
        .snapshots();
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
    getPostOwner = getPerson();
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
      color: Colors.white,
      margin: const EdgeInsets.only(top: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // owner profile
          StreamBuilder<DocumentSnapshot>(
              stream: getPostOwner,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Person person = Person.fromDocument(snapshot.data);
                  return ListTile(
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
                            child: Icon(Icons.person),
                          ),
                    title: Row(
                      children: [
                        // first name
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
                      style: TextStyle(color: Colors.black54),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) =>
                                  Profile(userID: person.id)));
                    },
                  );
                } else {
                  return Shimmer.fromColors(
                    period: Duration(seconds: 2),
                    baseColor: Colors.grey[300],
                    highlightColor: Colors.grey[100],
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      leading: CircleAvatar(
                          radius: MediaQuery.of(context).size.width / 17),
                      title: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: 22.0,
                          decoration: BoxDecoration(
                            color: Colors.grey[500],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      subtitle: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: 9.0,
                          decoration: BoxDecoration(
                            color: Colors.grey[500],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }),

          // post body and title
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
            leading: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: MediaQuery.of(context).size.width / 17,
            ),
            subtitle: ExpandablePanel(
              controller: expandableController,
              header: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.title,
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),

                  // spacer
                  SizedBox(height: 5.0),
                ],
              ),
              collapsed: GestureDetector(
                child: Linkify(
                  text: widget.post.body,
                  maxLines: 3,
                  overflow: TextOverflow.fade,
                  options: LinkifyOptions(looseUrl: true),
                  onOpen: (link) async {
                    if (await canLaunch(link.url)) {
                      await launch(link.url);
                    } else {
                      throw 'Could not launch $link';
                    }
                  },
                ),
                onTap: () => expandableController.toggle(),
              ),
              expanded: GestureDetector(
                child: Linkify(
                  text: widget.post.body,
                  onOpen: (link) async {
                    if (await canLaunch(link.url)) {
                      await launch(link.url);
                    } else {
                      throw 'Could not launch $link';
                    }
                  },
                ),
                onTap: () => expandableController.toggle(),
              ),
              // ignore: deprecated_member_use
              hasIcon: false,
            ),
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

          // dots indicator
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

          // buttons
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // approve and comment icons
                Row(
                  children: [
                    // approve icon
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: StreamBuilder(
                        stream: FirestoreService.postsCollection
                            .doc(widget.post.postID)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            bool liked = snapshot.data['usersWhoLiked']
                                .contains(user.uid);
                            return GestureDetector(
                                child: Icon(
                                  liked
                                      ? Icons.check_circle_outline
                                      : Icons.check_circle_outline,
                                  color: liked ? Colors.green : Colors.black,
                                  size: 28.0,
                                ),
                                onTap: () => controlLikeAction(liked));
                          } else {
                            return Icon(
                              Icons.check_circle_outline,
                              color: Colors.grey,
                            );
                          }
                        },
                      ),
                    ),

                    // comment icon
                    GestureDetector(
                      child: Icon(Icons.chat_bubble_outline),
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

                // approvals and comments
                Row(
                  children: [
                    // number of likes
                    StreamBuilder(
                      stream: FirestoreService.postsCollection
                          .doc(widget.post.postID)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          int likes = snapshot.data['usersWhoLiked'].length;
                          return GestureDetector(
                            child: Text(likes.toString() +
                                (likes != 1 ? ' Approvals  ' : ' Approval  ')),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) =>
                                          ApprovalsList(post: widget.post)));
                            },
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),

                    Text(bullet),

                    // number of comments
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirestoreService.postsCollection
                          .doc(widget.post.postID)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          int comments = snapshot.data['comments'].length;
                          return GestureDetector(
                            child: Text(comments.toString() +
                                (comments != 1 ? ' Comments  ' : ' Comment  ')),
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
      ),
    );
  }

  controlLikeAction(bool liked) async {
    bool isNotPostOwner = widget.post.ownerID != user.uid;
    if (liked) {
      await Post.removeUserFromLikesList(
        post: widget.post,
        userID: user.uid,
      );
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
      await Post.addUserToLikesList(
        post: widget.post,
        userID: user.uid,
      );
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
