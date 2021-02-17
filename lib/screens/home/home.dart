import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String bullet = "\u2022 ";
  AuthService authService;
  CommunityProvider _provider;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Stream<Person> _data;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    authService = AuthService();
    _provider = Provider.of<CommunityProvider>(context, listen: false);
    _data = FirestoreService(uid: authService.getCurrentUserID).userData;
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          child: Text(
            'Comcent',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          onTap: scrollToTop,
        ),
        leading: IconButton(
            color: Theme.of(context).primaryColor,
            icon: Icon(Icons.menu),
            onPressed: _openDrawer),
      ),
      body: StreamBuilder<Person>(
          stream: _data,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            Person person = snapshot.data;
            _provider.person = person;
            return ListView(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              children: [
                // header
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 8.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: person.profilePhoto != null
                          ? GestureDetector(
                              child: CircularProfileAvatar(
                                person.profilePhoto,
                                placeHolder: (context, url) {
                                  return Container(
                                    color: Colors.grey,
                                  );
                                },
                                radius: MediaQuery.of(context).size.width / 17,
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) =>
                                            Profile(userID: person.id)));
                              },
                            )
                          : GestureDetector(
                              child: CircleAvatar(
                                child: Icon(Icons.person),
                                radius: MediaQuery.of(context).size.width / 17,
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) =>
                                            Profile(userID: person.id)));
                              },
                            ),
                      title: GestureDetector(
                        child: TextField(
                          enabled: false,
                          decoration: InputDecoration.collapsed(
                              hintText: _provider.person.firstName != null
                                  ? "What are your thoughts, ${person.firstName}?"
                                  : ''),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => PostScreen(),
                              ));
                        },
                      ),
                    ),
                  ),
                ),

                //feed or no feed view
                StreamBuilder<QuerySnapshot>(
                  stream: FirestoreService.postsCollection
                      .orderBy('timeOfUpload', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox.shrink();
                    }
                    List<Post> temp = [];
                    snapshot.data.docs.map((DocumentSnapshot document) {
                      temp.add(Post.fromDocument(document));
                    }).toList();
                    List<Post> userFeed = temp
                        .where((post) =>
                            post.visibleTo
                                .contains(authService.getCurrentUserID) ||
                            person.interests.contains(post.topic))
                        .toList();
                    return userFeed.isNotEmpty
                        ? ListView.builder(
                            padding: EdgeInsets.only(bottom: 20.0),
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: userFeed.length,
                            itemBuilder: (context, index) {
                              bool isOwner = authService.getCurrentUserID ==
                                  userFeed[index].ownerID;
                              return !isOwner
                                  ? GestureDetector(
                                      child: PostCard(post: userFeed[index]),
                                      onLongPress: () {
                                        return showModalBottomSheet(
                                          context: context,
                                          builder: (ctx) {
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // add to bookmarks
                                                ListTile(
                                                  leading: Icon(Icons
                                                      .bookmark_border_rounded),
                                                  title: Text(
                                                      'Bookmark this post'),
                                                  onTap: () async {
                                                    Navigator.pop(ctx);
                                                    await FirestoreService
                                                        .bookmarksCollection
                                                        .doc(userFeed[index]
                                                            .postID)
                                                        .update({
                                                      'usersWhoBookmarked':
                                                          FieldValue
                                                              .arrayUnion([
                                                        authService
                                                            .getCurrentUserID
                                                      ])
                                                    }).then((value) => showSnackBar(
                                                            message:
                                                                'Added to bookmarks',
                                                            context: context));
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    )
                                  : PostCard(post: userFeed[index]);
                            },
                          )
                        : Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 4),
                            child: Center(
                              child: Column(
                                children: [
                                  Text(
                                    'Looks empty in here',
                                    style: TextStyle(
                                        fontSize: 16.0, color: Colors.grey),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                        text: 'Follow some',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 18),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: ' accounts',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 18,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' to get started!',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 18),
                                          )
                                        ]),
                                  ),
                                ],
                              ),
                            ),
                          );
                  },
                ),

                // custom scroll end indicator
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(bullet,
                        style: TextStyle(fontSize: 22.0, color: Colors.grey)),
                  ),
                ),
              ],
            );
          }),
      drawer: SideMenu(),
    );
  }

  // scroll to top of screen
  void scrollToTop() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  // open drawer
  void _openDrawer() {
    _scaffoldKey.currentState.openDrawer();
  }
}
