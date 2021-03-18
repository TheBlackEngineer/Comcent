import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  int _initialIndex = 0;
  String bullet = "\u2022 ";
  AuthService authService;
  CommunityProvider _provider;
  GlobalKey<ScaffoldState> _scaffoldKey;
  Future<Person> _data;
  ScrollController _scrollController;
  TabController _tabController;
  List<QueryDocumentSnapshot> userInterestPosts = [];

  // Get all posts where the user has an interest in
  void fetchUserInterestPosts() async {
    _provider.person.interests.forEach((interest) {
      FirestoreService.postsCollection
          .where('topic', isEqualTo: interest)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) => this.userInterestPosts.add(doc));
      });
    });
    print(this.userInterestPosts.length);
  }

  // void begin() async {
  //   QuerySnapshot querySnapshot = await FirestoreService.timelineCollection
  //       .doc('dfTSVS2zNHU8ImxHVCfgjlogEVr1')
  //       .collection('feed')
  //       .get();
  //   List<QueryDocumentSnapshot> documents = querySnapshot.docs;

  //   documents.forEach((document) {
  //     FirestoreService.postsCollection
  //         .doc(document.id)
  //         .get()
  //         .then((docSnap) async {
  //       bool isLeaderPost = docSnap.get('isLeaderPost');
  //       await FirestoreService.timelineCollection
  //           .doc('dfTSVS2zNHU8ImxHVCfgjlogEVr1')
  //           .collection('feed')
  //           .doc(docSnap.id)
  //           .update({'isLeaderPost': isLeaderPost});
  //     });
  //   });
  // }

  // Check if the person here is a leader or a member
  void getPersonStatus() {
    FirestoreService.usersCollection
        .doc(authService.getCurrentUserID)
        .get()
        .then((docSnapshot) {
      bool isLeader = docSnapshot.data()['isLeader'];
      if (isLeader) {
        setState(() {
          _initialIndex = 0;
        });
      } else {
        setState(() {
          _initialIndex = 1;
        });
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    authService = AuthService();
    getPersonStatus();
    _provider = Provider.of<CommunityProvider>(context, listen: false);
    _data = FirestoreService(uid: authService.getCurrentUserID).personFuture();

    _scrollController = ScrollController();
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: this._initialIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                pinned: true,
                floating: true,
                snap: true,
                backgroundColor: Theme.of(context).canvasColor,
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
                  onPressed: _openDrawer,
                ),
                bottom: TabBar(
                  indicatorColor: Theme.of(context).primaryColor,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(icon: Icon(Ionicons.people_outline)),
                    Tab(icon: Icon(FontAwesome5Solid.award)),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            physics: BouncingScrollPhysics(),
            children: [
              // All community posts view
              ListView(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                children: [
                  // Header
                  header(),

                  // Posts
                  buildList(),
                ],
              ),

              // Leader posts view
              ListView(
                shrinkWrap: true,
                //controller: _scrollController,
                physics: BouncingScrollPhysics(),
                children: [
                  // Header
                  header(),

                  // Posts
                  buildList(viewMode: 'Leader View Mode')
                ],
              ),
            ],
          ),
        ),
        drawer: SideMenu(),
      ),
    );
  }

  Widget buildList({String viewMode}) {
    return ListView(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      children: [
        // Timeline posts
        StreamBuilder<QuerySnapshot>(
          stream: viewMode != null
              ? FirestoreService.timelineCollection
                  .doc(authService.getCurrentUserID)
                  .collection('feed')
                  .where('isLeaderPost', isEqualTo: true)
                  .orderBy('timeOfUpload', descending: true)
                  .snapshots()
              : FirestoreService.timelineCollection
                  .doc(authService.getCurrentUserID)
                  .collection('feed')
                  .orderBy('timeOfUpload', descending: true)
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CupertinoActivityIndicator(),
              );
            }
            List<QueryDocumentSnapshot> documentSnapshots =
                (snapshot.data.docs + this.userInterestPosts).toSet().toList();
            if (documentSnapshots.isNotEmpty)
              return ListView.builder(
                padding: EdgeInsets.only(bottom: 20.0),
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemCount: documentSnapshots.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirestoreService.postsCollection
                        .doc(documentSnapshots[index].id)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox.shrink();
                      }
                      Post post = Post.fromDocument(snapshot.data);
                      bool isOwner =
                          authService.getCurrentUserID == post.ownerID;
                      return !isOwner
                          ? GestureDetector(
                              child: PostCard(post: post),
                              onLongPress: () async {
                                await showBottomSheet(post);
                              },
                            )
                          : PostCard(post: post);
                    },
                  );
                },
              );
            else
              return noPostView(context);
          },
        ),

        // Custom scroll end indicator
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 5.0),
            child: Text(bullet,
                style: TextStyle(fontSize: 22.0, color: Colors.grey)),
          ),
        ),
      ],
    );
  }

  Widget header() {
    return FutureBuilder<Person>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Person person = snapshot.data;
            _provider.person = person;
            return Container(
              color: Theme.of(context).canvasColor,
              margin: EdgeInsets.only(bottom: 20.0),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
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
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Icon(Icons.person, color: Colors.white),
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
              ),
            );
          }
        });
  }

  // Widget returned when there are no posts
  Padding noPostView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 4),
      child: Center(
        child: Column(
          children: [
            Text(
              'Looks empty in here',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            RichText(
              text: TextSpan(
                  text: 'Follow some',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
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
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    )
                  ]),
            ),
          ],
        ),
      ),
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

  // bottom sheet
  showBottomSheet(Post post) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // add to bookmarks
              ListTile(
                leading: Icon(Icons.bookmark_border_rounded),
                title: Text('Bookmark this post'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await FirestoreService.bookmarksCollection
                      .doc(post.postID)
                      .update({
                    'usersWhoBookmarked':
                        FieldValue.arrayUnion([authService.getCurrentUserID])
                  }).then((value) => showSnackBar(
                          message: 'Added to bookmarks', context: context));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
