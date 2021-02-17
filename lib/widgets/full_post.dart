import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class FullPostView extends StatelessWidget {
  final String postID;

  const FullPostView({Key key, @required this.postID}) : super(key: key);

  Future fetchPost() async {
    DocumentSnapshot document =
        await FirestoreService.postsCollection.doc(postID).get();
    return document;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
      ),
      body: FutureBuilder(
        future: fetchPost(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Post post = Post.fromDocument(snapshot.data);
            return PostCard(post: post);
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
