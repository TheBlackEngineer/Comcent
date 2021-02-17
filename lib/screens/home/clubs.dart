import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class Clubs extends StatefulWidget {
  @override
  _ClubsState createState() => _ClubsState();
}

class _ClubsState extends State<Clubs> {
  User user;
  List<Club> clubs = [];
  List<ClubAction> _actions;

  // get clubs
  void fetchClubs() async {
    List<QueryDocumentSnapshot> querySnapshots = await FirestoreService
        .clubsCollection
        .get()
        .then((QuerySnapshot snapshot) {
      return snapshot.docs;
    });
    List<Club> clubs = [];
    for (DocumentSnapshot documentSnapshot in querySnapshots) {
      clubs.add(Club.fromDocument(documentSnapshot));
    }
    setState(() {
      this.clubs = clubs;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchClubs();

    _actions = [
      // your club
      ClubAction(
        iconData: Icons.group_rounded,
        label: 'Your Clubs',
        onTap: () {},
      ),
      // search club
      ClubAction(
        iconData: Icons.search,
        label: 'Search Club',
        onTap: () => searchClub(context),
      ),
      // create club
      ClubAction(
        iconData: Icons.add_circle,
        label: 'Create Club',
        onTap: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => CreateAClub(),
              ));
        },
      ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = Provider.of<User>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context: context, title: 'Clubs'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: .0),
        child: Column(
          children: [
            actions(),
            Expanded(child: clubList()),
          ],
        ),
      ),
    );
  }

  Widget actions() {
    return Container(
      height: 50.0,
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemCount: _actions.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: _actions[index],
        ),
      ),
    );
  }

  Widget clubList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.clubsCollection
          .where('members', arrayContains: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data.docs.isEmpty)
          return NoGroupWidget();
        else {
          List clubs = [];
          snapshot.data.docs.forEach((element) => clubs.add(element.id));
          return ListView.builder(
              padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              physics: BouncingScrollPhysics(),
              itemCount: clubs.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return FutureBuilder(
                    future: FirestoreService.clubsCollection
                        .doc(clubs[index])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Club club = Club.fromDocument(snapshot.data);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Material(
                            borderRadius: BorderRadius.circular(8.0),
                            elevation: 4.0,
                            shadowColor: Colors.grey[200],
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 8.0),
                              leading: club.clubPhoto != null
                                  ? CircularProfileAvatar(
                                      club.clubPhoto,
                                      placeHolder: (context, url) {
                                        return Container(
                                          color: Colors.grey,
                                        );
                                      },
                                      radius:
                                          MediaQuery.of(context).size.width /
                                              17,
                                    )
                                  : CircleAvatar(
                                      child: Icon(Icons.group),
                                    ),
                              title: Text(club.name),
                              subtitle: Text(
                                club.description,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: club.administrators
                                      .contains((user.uid))
                                  ? club.membershipRequests.isNotEmpty
                                      ? GestureDetector(
                                          child: Container(
                                            padding: EdgeInsets.all(6.0),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                            ),
                                            child: Text(
                                              club.membershipRequests.length
                                                      .toString() +
                                                  ' requests',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (context) =>
                                                    MembershipRequests(
                                                  club: club,
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : SizedBox.shrink()
                                  : SizedBox.shrink(),
                              onTap: () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => ChatScreen(
                                    club: club,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    });
              });
        }
      },
    );
  }

  // show the search screen
  Future<Club> searchClub(BuildContext context) {
    return showSearch(
      context: context,
      delegate: SearchPage<Club>(
        barTheme: Theme.of(context).copyWith(
          primaryColor: Colors.white,
          primaryIconTheme: IconThemeData(color: Colors.black),
          cursorColor: Colors.black,
          textTheme: TextTheme(
            headline6: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 20,
            ),
          ),
          appBarTheme: Theme.of(context).appBarTheme,
        ),
        items: clubs,
        searchLabel: 'Search',
        suggestion: Center(
          child: Text(
            'Suggestions appear here',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
        failure: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No matching clubs',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(
              'Check your spelling or try another word',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ],
        )),
        filter: (club) => [club.name],
        builder: (club) => GestureDetector(
          onTap: () {
            club.members.contains(user.uid)
                ? Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => ChatScreen(
                              club: club,
                            )))
                : Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => ClubProfile(
                              club: club,
                            )));
          },
          child: Column(
            children: [
              ListTile(
                leading: club.clubPhoto != null
                    ? CircularProfileAvatar(
                        club.clubPhoto,
                        placeHolder: (context, url) {
                          return Container(
                            color: Colors.grey,
                          );
                        },
                        radius: MediaQuery.of(context).size.width / 18,
                      )
                    : CircleAvatar(
                        child: Icon(Icons.group),
                      ),
                title: Text(
                  club.name,
                ),
                subtitle: Text(
                  club.description,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
