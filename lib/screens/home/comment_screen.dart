import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentScreen extends StatefulWidget {
  final Post post;

  const CommentScreen({Key key, @required this.post}) : super(key: key);
  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  Future<Person> getOwner;
  String commentBody = '';
  String initialValue = '';
  String masterCommentID = '';
  User user;
  CommunityProvider _communityProvider;
  FocusNode focusNode;
  TextEditingController _controller = TextEditingController();

  Future<Person> getPerson(String id) async {
    return FirestoreService(uid: id).personFuture();
  }

  @override
  void initState() {
    super.initState();
    getOwner = getPerson(widget.post.ownerID);
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    _communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    return Scaffold(
      appBar: appBar(
          context: context,
          title: 'Comments',
          backgroundColor: Colors.white,
          onPressed: () => Navigator.pop(context)),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanDown: (context) => dismissKeyboard(),
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  Column(
                    children: [
                      // owner profile
                      Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<Person>(
                                future: getOwner,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    Person person = snapshot.data;
                                    return ListTile(
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
                                      leading: person.profilePhoto != null
                                          ? CircularProfileAvatar(
                                              person.profilePhoto,
                                              placeHolder: (context, url) {
                                                return Container(
                                                  color: Colors.grey,
                                                );
                                              },
                                              radius: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  17,
                                            )
                                          : CircleAvatar(
                                              child: Icon(Icons.person),
                                            ),
                                      title: Row(
                                        children: [
                                          // name
                                          Text(person.firstName +
                                              ' ' +
                                              person.lastName),

                                          // leadership badge
                                          person.isLeader
                                              ? LeadershipBadge()
                                              : SizedBox.shrink()
                                        ],
                                      ),
                                      subtitle: Text(person.subCommunity),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) => Profile(
                                                    userID: person.id)));
                                      },
                                    );
                                  } else {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.grey[100],
                                      ),
                                      title: Text(''),
                                      subtitle: Text(''),
                                    );
                                  }
                                }),

                            // post title and post body
                            ListTile(
                              title: Text(widget.post.title),
                              subtitle: ReadMoreText(
                                widget.post.body,
                                trimLines: 2,
                                colorClickableText:
                                    Theme.of(context).primaryColor,
                                trimMode: TrimMode.Line,
                                trimCollapsedText: 'Read more',
                                trimExpandedText: 'Read less',
                                moreStyle: TextStyle(
                                    fontSize: 15.0,
                                    color: Theme.of(context).primaryColor),
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.black54),
                              ),
                              leading: CircleAvatar(
                                  backgroundColor: Colors.transparent),
                            ),
                          ],
                        ),
                      ),

                      // spacer
                      SizedBox(height: 20.0),

                      // comment list
                      commentList()
                    ],
                  )
                ],
              ),
            ),
          ),

          Divider(),

          // text field
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Row(
              children: [
                // profile picture
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: _communityProvider.person.profilePhoto != null
                      ? CircularProfileAvatar(
                          _communityProvider.person.profilePhoto,
                          radius: MediaQuery.of(context).size.width / 20,
                        )
                      : CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                ),

                // text field
                Expanded(
                  child: TextField(
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: true,
                    focusNode: focusNode,
                    controller: _controller,
                    onChanged: (newValue) {
                      setState(() {
                        commentBody = newValue;
                      });
                    },
                    maxLines: null,
                    decoration: InputDecoration.collapsed(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(color: Colors.grey)),
                  ),
                ),

                // post comment button
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 12.0),
                    child: Text(
                      'Post',
                      style: TextStyle(
                          color: commentBody.isNotEmpty
                              ? Theme.of(context).primaryColor
                              : Colors.blue.withOpacity(0.4)),
                    ),
                  ),
                  onTap: () async {
                    if (commentBody.isEmpty) {
                      print('Comment body empty');
                    } else {
                      await EasyLoading.show(
                          status: 'Please wait',
                          maskType: EasyLoadingMaskType.black,
                          dismissOnTap: true);

                      String response = await postComment();

                      response != null
                          ? EasyLoading.showSuccess('Comment added',
                              dismissOnTap: true)
                          : EasyLoading.showError('Comment unsuccessful',
                              dismissOnTap: true);

                      EasyLoading.dismiss();

                      _controller.clear();

                      setState(() {
                        initialValue = '';
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future postComment() async {
    FirestoreService firestoreService =
        FirestoreService(uid: _communityProvider.person.id);
    // generate a comment
    Comment comment = Comment(
      body: initialValue.isEmpty
          ? commentBody
          : initialValue + '!-!' + commentBody,
      ownerID: user.uid,
      commentID: Uuid().v4(),
      masterCommentID: masterCommentID,
      postID: widget.post.postID,
      isReply: initialValue.isEmpty ? false : true,
    );

    // if the comment is a reply to another COMMENT, add it to the COMMENT's list of replies
    initialValue.isNotEmpty
        ? await firestoreService.addReplyToCommentReplies(
            masterCommentID, comment.commentID)
        : print('This is a comment, not a reply');

    // then add the comment to the comments collection
    await firestoreService.addComment(comment);

    bool isNotPostOwner = widget.post.ownerID != user.uid;
    if (isNotPostOwner) {
      await FirestoreService.activitiesCollection
          .doc(widget.post.ownerID)
          .collection('activityItems')
          .add({
        'type': 'comment',
        'postID': widget.post.postID,
        'username': _communityProvider.person.firstName +
            ' ' +
            _communityProvider.person.lastName,
        'timestamp': DateTime.now(),
        'userProfileImage': _communityProvider.person.profilePhoto,
        'userID': user.uid,
        'postImage': widget.post.photoAttachments.isNotEmpty
            ? widget.post.photoAttachments[0]
            : null,
        'commentData': commentBody,
      });
    }

    // now add the comment to the post's list of comments
    return firestoreService.addCommentToPostComments(
        comment, widget.post.postID);
  }

  void showKeyboard() {
    focusNode.requestFocus();
  }

  void dismissKeyboard() {
    focusNode.unfocus();
  }

  Future openBottomSheet(Comment comment) {
    FirestoreService firestoreService =
        FirestoreService(uid: _communityProvider.person.id);
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete comment'),
              onTap: () async {
                Navigator.pop(context);
                // first check if the comment is a reply or not
                if (comment.isReply) {
                  // first, remove comment, i.e reply, from the master comment's list of replies
                  await firestoreService.removeReplyFromCommentReplies(
                      comment.masterCommentID, comment.commentID);

                  // next, remove the comment from the comments collection
                  firestoreService.deleteComment(comment);

                  // finally, remove the comment from the post's list of comments
                  firestoreService.removeCommentFromPostComments(
                      comment, widget.post.postID);
                }

                // perform all checks and delete what has to be deleted
                else {
                  // if the comment does not have any replies, just delete it
                  if (comment.replies.isEmpty) {
                    await FirestoreService.postsCollection
                        .doc(widget.post.postID)
                        .update({
                      'comments': FieldValue.arrayRemove([comment.commentID])
                    });
                    await FirestoreService.commentsCollection
                        .doc(comment.commentID)
                        .delete();
                  }

                  // if the comment has replies, first delete them
                  comment.replies.forEach((element) async {
                    await FirestoreService.postsCollection
                        .doc(widget.post.postID)
                        .update({
                      'comments': FieldValue.arrayRemove([element])
                    });
                    await FirestoreService.commentsCollection
                        .doc(element)
                        .delete();
                  });

                  // then delete the comment from the post's lists of comments
                  await FirestoreService.postsCollection
                      .doc(widget.post.postID)
                      .update({
                    'comments': FieldValue.arrayRemove([comment.commentID])
                  });

                  // then finally, delete the comment from the comments collection
                  await FirestoreService.commentsCollection
                      .doc(comment.commentID)
                      .delete();
                }
              },
            ),
          ],
        );
      },
    );
  }

  StreamBuilder<DocumentSnapshot> commentList() {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirestoreService.postsCollection.doc(widget.post.postID).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List postComments = snapshot.data['comments'];
          return postComments.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: postComments.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder(
                      future: FirestoreService.commentsCollection
                          .doc(postComments[index])
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox.shrink();
                        }

                        // each individual comment
                        Comment comment = Comment.fromDocument(snapshot.data);

                        return FutureBuilder(
                            future: FirestoreService.usersCollection
                                .doc(comment.ownerID)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                Timestamp timestamp = comment.timeOfUpload;
                                DateTime dateTime = timestamp.toDate();

                                String tAgo = timeago.format(dateTime);
                                Person commentOwner =
                                    Person.fromDocument(snapshot.data);
                                // show a comment if it's not a reply
                                return !comment.isReply
                                    ? Column(
                                        children: [
                                          // user profile, username, comment body
                                          Row(
                                            children: [
                                              // user profile
                                              GestureDetector(
                                                child: commentOwner
                                                            .profilePhoto !=
                                                        null
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8.0),
                                                        child:
                                                            CircularProfileAvatar(
                                                          commentOwner
                                                              .profilePhoto,
                                                          placeHolder:
                                                              (context, url) {
                                                            return Container(
                                                              color: Colors
                                                                  .grey[200],
                                                            );
                                                          },
                                                          radius: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              20,
                                                        ),
                                                      )
                                                    : Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8.0),
                                                        child: CircleAvatar(
                                                          child: Icon(
                                                              Icons.person),
                                                        ),
                                                      ),
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      CupertinoPageRoute(
                                                          builder: (context) =>
                                                              Profile(
                                                                  userID:
                                                                      commentOwner
                                                                          .id)));
                                                },
                                              ),

                                              // username, comment body, likes
                                              Flexible(
                                                child: GestureDetector(
                                                  onLongPress: () {
                                                    if (comment.ownerID ==
                                                        user.uid) {
                                                      openBottomSheet(comment);
                                                    }
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 5.0,
                                                            right: 15.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      border: Border.all(
                                                          color: Colors.grey),
                                                    ),
                                                    child: ListTile(
                                                      title: Row(
                                                        children: [
                                                          // name
                                                          Text(commentOwner
                                                                  .firstName +
                                                              ' ' +
                                                              commentOwner
                                                                  .lastName),

                                                          // leadership badge
                                                          commentOwner.isLeader
                                                              ? LeadershipBadge()
                                                              : SizedBox
                                                                  .shrink(),
                                                        ],
                                                      ),
                                                      subtitle:
                                                          Text(comment.body),
                                                      trailing: SizedBox(
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            StreamBuilder(
                                                              stream: FirestoreService
                                                                  .commentsCollection
                                                                  .doc(comment
                                                                      .commentID)
                                                                  .snapshots(),
                                                              builder: (context,
                                                                  snapshot) {
                                                                if (snapshot
                                                                    .hasData) {
                                                                  List likes =
                                                                      snapshot.data[
                                                                          'likes'];
                                                                  return likes
                                                                          .isNotEmpty
                                                                      ? Text(likes
                                                                          .length
                                                                          .toString())
                                                                      : SizedBox
                                                                          .shrink();
                                                                } else {
                                                                  return SizedBox
                                                                      .shrink();
                                                                }
                                                              },
                                                            ),

                                                            // like button
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(5.0),
                                                              child:
                                                                  StreamBuilder(
                                                                stream: FirestoreService
                                                                    .commentsCollection
                                                                    .doc(comment
                                                                        .commentID)
                                                                    .snapshots(),
                                                                builder: (context,
                                                                    snapshot) {
                                                                  if (snapshot
                                                                      .hasData) {
                                                                    bool liked = snapshot
                                                                        .data[
                                                                            'likes']
                                                                        .contains(
                                                                            user.uid);
                                                                    return GestureDetector(
                                                                      child:
                                                                          Icon(
                                                                        liked
                                                                            ? Icons.check_circle_outline
                                                                            : Icons.check_circle_outline,
                                                                        color: liked
                                                                            ? Colors.green
                                                                            : Colors.grey,
                                                                      ),
                                                                      onTap:
                                                                          () async {
                                                                        liked
                                                                            ? await FirestoreService.commentsCollection.doc(comment.commentID).update({
                                                                                'likes': FieldValue.arrayRemove([
                                                                                  user.uid
                                                                                ]),
                                                                              })
                                                                            : await FirestoreService.commentsCollection.doc(comment.commentID).update({
                                                                                'likes': FieldValue.arrayUnion([
                                                                                  user.uid
                                                                                ]),
                                                                              });
                                                                      },
                                                                    );
                                                                  } else {
                                                                    return CupertinoActivityIndicator();
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          // time, reply button
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15.0),
                                            child: Row(
                                              children: [
                                                // placeholder spacer from edge of screen
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                  ),
                                                ),

                                                // time
                                                Text(tAgo),

                                                SizedBox(width: 15.0),

                                                // reply a comment
                                                GestureDetector(
                                                    child: Text('Reply'),
                                                    onTap: () {
                                                      setState(() {
                                                        showKeyboard();
                                                        masterCommentID =
                                                            comment.commentID;
                                                        initialValue = '@' +
                                                            commentOwner
                                                                .firstName +
                                                            ' ' +
                                                            commentOwner
                                                                .lastName;
                                                      });
                                                    }),
                                              ],
                                            ),
                                          ),

                                          // view replies button
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15.0),
                                            child: Row(
                                              children: [
                                                // placeholder spacer from edge of screen
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                  ),
                                                ),

                                                // replies
                                                comment.replies.isNotEmpty
                                                    ? Flexible(
                                                        child: ExpandablePanel(
                                                          header: Text(comment
                                                                  .replies
                                                                  .length
                                                                  .toString() +
                                                              ' replies'),
                                                          // ignore: deprecated_member_use
                                                          tapHeaderToExpand:
                                                              true,
                                                          // ignore: deprecated_member_use
                                                          hasIcon: false,
                                                          expanded:
                                                              ListView.builder(
                                                            shrinkWrap: true,
                                                            physics:
                                                                BouncingScrollPhysics(),
                                                            itemCount: comment
                                                                .replies.length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return FutureBuilder(
                                                                future: FirestoreService
                                                                    .commentsCollection
                                                                    .doc(comment
                                                                            .replies[
                                                                        index])
                                                                    .get(),
                                                                builder: (context,
                                                                    snapshot) {
                                                                  if (!snapshot
                                                                      .hasData) {
                                                                    return SizedBox
                                                                        .shrink();
                                                                  }
                                                                  Comment
                                                                      comment =
                                                                      Comment.fromDocument(
                                                                          snapshot
                                                                              .data);
                                                                  List
                                                                      commentDetails =
                                                                      comment
                                                                          .body
                                                                          .split(
                                                                              '!-!');
                                                                  return Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        bottom:
                                                                            5.0,
                                                                        right:
                                                                            15.0),
                                                                    child:
                                                                        ListTile(
                                                                      contentPadding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                      title:
                                                                          Text(
                                                                        commentDetails[
                                                                            0],
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: Theme.of(context).primaryColor),
                                                                      ),
                                                                      subtitle:
                                                                          Text(
                                                                        commentDetails[
                                                                            1],
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey[700]),
                                                                      ),
                                                                      leading:
                                                                          GestureDetector(
                                                                        child: FutureBuilder<
                                                                            Person>(
                                                                          future:
                                                                              getPerson(comment.ownerID),
                                                                          builder:
                                                                              (context, snapshot) {
                                                                            if (snapshot.hasData) {
                                                                              return snapshot.data.profilePhoto != null
                                                                                  ? CircularProfileAvatar(
                                                                                      snapshot.data.profilePhoto,
                                                                                      radius: MediaQuery.of(context).size.width / 22,
                                                                                    )
                                                                                  : CircleAvatar(
                                                                                      child: Icon(Icons.person),
                                                                                    );
                                                                            }
                                                                            return SizedBox.shrink();
                                                                          },
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          Navigator.push(
                                                                              context,
                                                                              CupertinoPageRoute(builder: (context) => Profile(userID: comment.ownerID)));
                                                                        },
                                                                      ),
                                                                      onLongPress:
                                                                          () {
                                                                        if (comment.ownerID ==
                                                                            user.uid) {
                                                                          openBottomSheet(
                                                                              comment);
                                                                        }
                                                                      },
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox.shrink()
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox.shrink();
                              }
                              return SizedBox.shrink();
                            });
                      },
                    );
                  },
                )
              : Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 6),
                  child: Text(
                    'No comments',
                    style: TextStyle(fontSize: 18.0, color: Colors.grey),
                  ),
                );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
