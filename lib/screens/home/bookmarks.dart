import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class Bookmarks extends StatefulWidget {
  final Person person;

  Bookmarks({Key key, @required this.person}) : super(key: key);

  @override
  _BookmarksState createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  List bookmarks = [];
  final AuthService authService = AuthService();

  getBookmarks() async {
    List docs = await FirestoreService.bookmarksCollection
        .where('usersWhoBookmarked',
            arrayContains: authService.getCurrentUserID)
        .get()
        .then((querySnapshot) => querySnapshot.docs);
    docs.forEach((element) => bookmarks.add(element.id));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    bookmarks.reversed;
    return Scaffold(
        appBar: appBar(
            title: 'Bookmarks',
            context: context,
            onPressed: () => Navigator.pop(context)),
        body: bookmarks.isNotEmpty
            ? ListView.builder(
                padding: const EdgeInsets.only(bottom: 20.0),
                physics: BouncingScrollPhysics(),
                itemCount: bookmarks.length,
                itemBuilder: (context, index) {
                  String postID = bookmarks[index];
                  return FutureBuilder(
                    future: FirestoreService.postsCollection.doc(postID).get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Post post = Post.fromDocument(snapshot.data);
                        return GestureDetector(
                          child: PostCard(post: post),
                          onLongPress: () async {
                            await showBottomSheet(post);
                          },
                        );
                      }
                      return Text('');
                    },
                  );
                },
              )
            : Center(
                child: Text(
                'Nothing here',
                style: TextStyle(fontSize: 20.0, color: Colors.grey),
              )));
  }

  // bottom sheet
  showBottomSheet(Post post) async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // remove from bookmarks
              ListTile(
                leading: Icon(Icons.bookmark_border_rounded, color: Colors.red),
                title: Text(
                  'Remove from bookmarks',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  setState(() {
                    bookmarks.remove(post.postID);
                  });
                  await FirestoreService.bookmarksCollection
                      .doc(post.postID)
                      .update({
                    'usersWhoBookmarked':
                        FieldValue.arrayRemove([authService.getCurrentUserID])
                  }).then((value) => showSnackBar(
                          message: 'Removed from bookmarks', context: context));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
