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
      body: FutureBuilder(
        future: FirestoreService.usersCollection.get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List docs = snapshot.data.documents;
          List filteredDocs = docs
              .where((element) => post.usersWhoLiked.contains(element['id']))
              .toList();

          List users = [];

          filteredDocs.forEach((user) {
            users.add(Person.fromDocument(user));
          });
          return ListView.separated(
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              Person person = users[index];
              return ListTile(
                title: Row(
                  children: [
                    // name
                    Text(person.firstName + ' ' + person.lastName),

                    // leader tag if user is leader
                    person.isLeader ? LeadershipBadge() : SizedBox.shrink(),
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
                        radius: MediaQuery.of(context).size.width / 17,
                      )
                    : CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => Profile(userID: person.id)));
                },
              );
            },
            separatorBuilder: (context, index) => Divider(),
            itemCount: users.length,
          );
        },
      ),
    );
  }
}
