import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class MembershipRequests extends StatefulWidget {
  final Club club;

  const MembershipRequests({Key key, @required this.club}) : super(key: key);

  @override
  _MembershipRequestsState createState() => _MembershipRequestsState();
}

class _MembershipRequestsState extends State<MembershipRequests> {
  // decline membership request
  void declineRequest(Person person) {
    setState(() {
      widget.club.membershipRequests.remove(person.id);
    });
    FirestoreService.removeMembershipRequest(person.id, widget.club.id);
  }

  // accept membership request
  void acceptRequest(Person person) {
    setState(() {
      widget.club.membershipRequests.add(person.id);
    });
    FirestoreService.addMembershipRequest(person.id, widget.club.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
          title: 'Membership requests',
          context: context,
          onPressed: () => Navigator.pop(context)),
      body: widget.club.membershipRequests.isNotEmpty
          ? ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: widget.club.membershipRequests.length,
              itemBuilder: (context, index) {
                String uid = widget.club.membershipRequests[index];
                return FutureBuilder(
                  future: FirestoreService(uid: uid).personFuture(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Person person = snapshot.data;
                      return ListTile(
                        leading: GestureDetector(
                          child: person.profilePhoto != null
                              ? CircularProfileAvatar(
                                  person.profilePhoto,
                                  placeHolder: (context, url) {
                                    return Container(
                                      color: Colors.grey,
                                    );
                                  },
                                  radius:
                                      MediaQuery.of(context).size.width / 18,
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
                        ),
                        title: GestureDetector(
                          child: Row(
                            children: [
                              // name
                              Text(person.firstName + ' ' + person.lastName),

                              // leader tag if user is leader
                              person.isLeader
                                  ? LeadershipBadge()
                                  : SizedBox.shrink(),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) =>
                                        Profile(userID: person.id)));
                          },
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // accept request
                            CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: IconButton(
                                color: Colors.white,
                                icon: Icon(Icons.check),
                                onPressed: () {
                                  declineRequest(person);
                                  FirestoreService.acceptMembershipRequest(
                                      person.id, widget.club.id);
                                  showSnackBar(
                                      message: 'Request accepted',
                                      context: context);
                                },
                              ),
                            ),

                            SizedBox(width: 8.0),

                            // decline request
                            CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: IconButton(
                                color: Colors.white,
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  declineRequest(person);
                                  showSnackBar(
                                      message: 'Request declined',
                                      context: context);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return ListTile();
                    }
                  },
                );
              },
            )
          : Center(
              child: Text(
              'No membership requests',
              style: TextStyle(fontSize: 20.0, color: Colors.grey),
            )),
    );
  }
}
