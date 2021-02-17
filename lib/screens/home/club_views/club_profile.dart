import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class ClubProfile extends StatefulWidget {
  final Club club;

  ClubProfile({Key key, @required this.club}) : super(key: key);

  @override
  _ClubProfileState createState() => _ClubProfileState();
}

class _ClubProfileState extends State<ClubProfile> {
  User user;

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    return Scaffold(
        appBar: appBar(
            context: context,
            title: 'Club profile',
            onPressed: () {
              Navigator.pop(context);
            }),
        body: FutureBuilder<Person>(
            future: FirestoreService(uid: widget.club.creator).personFuture(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              Person creator = snapshot.data;
              return ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  // club profile photo
                  widget.club.clubPhoto != null
                      ? Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[350],
                                offset: Offset(0.0, 5.0), //(x,y)
                                blurRadius: 10.0,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: MediaQuery.of(context).size.width / 7.0,
                            child: CircularProfileAvatar(
                              widget.club.clubPhoto,
                              radius: MediaQuery.of(context).size.width / 7.0,
                            ),
                          ),
                        )
                      : CircleAvatar(
                          radius: MediaQuery.of(context).size.width / 7.0,
                          child: Icon(Icons.group, size: 70.0),
                        ),

                  // club name, number of members, description,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      children: [
                        SizedBox(height: 20.0),

                        // club name
                        Text(
                          widget.club.name,
                          style: TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),

                        SizedBox(height: 10.0),

                        // number of members
                        Text(
                          widget.club.members.length == 1
                              ? widget.club.members.length.toString() +
                                  ' member'
                              : widget.club.members.length.toString() +
                                  ' members',
                          style: TextStyle(fontSize: 16.0, color: Colors.grey),
                        ),

                        SizedBox(height: 20.0),

                        // club description
                        Text(
                          widget.club.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 19.0, color: Colors.grey),
                        ),

                        SizedBox(height: 18.0),

                        // created by a leader
                        creator.isLeader
                            ? Column(
                                children: [
                                  // club description
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // leadership badge
                                      LeadershipBadge(size: 22.0),
                                      Text(
                                        ' Created by a leader',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 19.0, color: Colors.grey),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 18.0),
                                ],
                              )
                            : SizedBox.shrink(),

                        // join club button
                        GradientButton(
                          label:
                              widget.club.membershipRequests.contains(user.uid)
                                  ? 'Pending...'
                                  : 'Join Club',
                          onPressed: widget.club.membershipRequests
                                  .contains(user.uid)
                              ? () {
                                  widget.club.membershipRequests
                                      .remove(user.uid);
                                  setState(() {});
                                  FirestoreService.removeMembershipRequest(
                                      user.uid, widget.club.id);
                                }
                              : () {
                                  widget.club.membershipRequests.add(user.uid);
                                  setState(() {});
                                  FirestoreService.addMembershipRequest(
                                      user.uid, widget.club.id);
                                },
                        ),
                      ],
                    ),
                  ),

                  widget.club.clubRules.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Divider(),
                        )
                      : SizedBox.shrink(),

                  SizedBox(height: 10.0),

                  // club rules and regulations title
                  widget.club.clubRules.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text('Club Rules and Regulations',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Colors.grey[800])),
                        )
                      : SizedBox.shrink(),

                  SizedBox(height: 20.0),

                  // actual club rules and regulations
                  widget.club.clubRules.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          itemCount: widget.club.clubRules.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Row(
                                children: [
                                  Text((index + 1).toString() + '. ',
                                      style: TextStyle(
                                          fontSize: 17.0,
                                          color: Colors.black54)),
                                  Text(
                                    widget.club.clubRules[index],
                                    style: TextStyle(
                                        fontSize: 17.0, color: Colors.black54),
                                  )
                                ],
                              ),
                            );
                          },
                        )
                      : SizedBox.shrink(),
                ],
              );
            }));
  }
}
