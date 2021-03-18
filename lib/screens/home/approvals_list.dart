import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class ApprovalsList extends StatelessWidget {
  final Post post;

  ApprovalsList({Key key, this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
          title: 'Approved by',
          context: context,
          onPressed: () => Navigator.pop(context)),
      body: FutureBuilder<QuerySnapshot>(
          future: FirestoreService.postsCollection
              .doc(post.postID)
              .collection('approvedBy')
              .get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<QueryDocumentSnapshot> approvalDocs = snapshot.data.docs;
              return ListView.separated(
                physics: BouncingScrollPhysics(),
                separatorBuilder: (context, index) => Divider(),
                itemCount: approvalDocs.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirestoreService.usersCollection
                        .doc(approvalDocs[index].id)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Person person = Person.fromDocument(snapshot.data);
                        return ListTile(
                          title: Row(
                            children: [
                              // name
                              Text(person.firstName + ' ' + person.lastName),

                              // leader tag if user is leader
                              person.isLeader
                                  ? LeadershipBadge()
                                  : SizedBox.shrink(),
                            ],
                          ),
                          leading: person.profilePhoto != null
                              ? CircularProfileAvatar(
                                  person.profilePhoto,
                                  placeHolder: (context, url) {
                                    return Container(
                                      color: Colors.grey,
                                    );
                                  },
                                  radius:
                                      MediaQuery.of(context).size.width / 17,
                                )
                              : CircleAvatar(
                                  child: Icon(Icons.person),
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
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10.0),
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
                    },
                  );
                },
              );
            } else {
              return Center(
                child: CupertinoActivityIndicator(),
              );
            }
          }),
    );
  }
}
