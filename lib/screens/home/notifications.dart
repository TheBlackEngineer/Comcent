import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:comcent/imports.dart';
import 'package:timeago/timeago.dart' as timeago;

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  User user;

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    return Scaffold(
      appBar: appBar(title: 'Notifications', context: context),
      body: StreamBuilder(
        stream: FirestoreService.activitiesCollection
            .doc(user.uid)
            .collection('activityItems')
            .orderBy('timestamp', descending: true)
            .limit(40)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List<NotificationItem> notificationItems = [];

          snapshot.data.documents.map((DocumentSnapshot document) {
            notificationItems.add(NotificationItem.fromDocument(document));
          }).toList();
          return notificationItems.isNotEmpty
              ? ListView(
                  physics: BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20.0),
                  children: notificationItems,
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // icon
                      Icon(Feather.bell, color: Colors.grey[700], size: 65.0),

                      SizedBox(height: 20.0),

                      // no notifications
                      Text(
                        'No notifications',
                        style: TextStyle(fontSize: 20.0, color: Colors.grey),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}

Widget mediaPreview;
String notificationItemText;

class NotificationItem extends StatelessWidget {
  final String username;
  final String type;
  final Timestamp timestamp;
  final String postID;
  final String userID;
  final userProfileImage;
  final postImage;
  final commentData;

  const NotificationItem({
    Key key,
    this.username,
    this.type,
    this.timestamp,
    this.postID,
    this.userID,
    this.userProfileImage,
    this.postImage,
    this.commentData,
  }) : super(key: key);

  factory NotificationItem.fromDocument(DocumentSnapshot documentSnapshot) {
    return NotificationItem(
      username: documentSnapshot.data()['username'],
      type: documentSnapshot.data()['type'],
      timestamp: documentSnapshot.data()['timestamp'],
      postID: documentSnapshot.data()['postID'],
      userID: documentSnapshot.data()['userID'],
      userProfileImage: documentSnapshot.data()['userProfileImage'],
      postImage: documentSnapshot.data()['postImage'],
      commentData: documentSnapshot.data()['commentData'],
    );
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: ListTile(
          title: GestureDetector(
            onTap: () {
              if (type == 'approval' || type == 'comment') {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => FullPostView(postID: postID),
                    ));
              } else {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => Profile(userID: userID),
                    ));
              }
            },
            child: RichText(
              maxLines: null,
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 17.0),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' $notificationItemText  -  '),
                  TextSpan(
                    text: timeago.format(timestamp.toDate()),
                    style: TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
          leading: FutureBuilder<Person>(
              future: FirestoreService(uid: userID).personFuture(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return CircleAvatar(
                    backgroundColor: Colors.transparent,
                  );
                Person person = snapshot.data;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      child: person.profilePhoto != null
                          ? CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  person.profilePhoto))
                          : CircleAvatar(
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                      onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => Profile(userID: userID),
                          )),
                    ),

                    // leadership tag if person is a leader
                    Positioned(
                      right: -11.0,
                      bottom: 0.0,
                      child: person.isLeader
                          ? LeadershipBadge(size: 20)
                          : SizedBox.shrink(),
                    ),
                  ],
                );
              }),
          trailing: postImage != null ? mediaPreview : SizedBox.shrink(),
        ),
      ),
    );
  }

  configureMediaPreview(context) {
    if (type == 'comment' || type == 'approval') {
      mediaPreview = postImage != null
          ? GestureDetector(
              child: Container(
                height: 50.0,
                width: 50.0,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(postImage),
                    )),
                  ),
                ),
              ),
              onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => FullPostView(postID: postID),
                  )),
            )
          : Text('');
    } else {
      mediaPreview = Text('');
    }
    if (type == 'approval') {
      notificationItemText = 'approved your post';
    } else if (type == 'comment') {
      notificationItemText = 'replied: $commentData';
    } else if (type == 'follow') {
      notificationItemText = 'started following you';
    } else {
      notificationItemText = 'Unknown type: $type';
    }
  }
}
