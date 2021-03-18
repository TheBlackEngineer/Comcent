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
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    return Scaffold(
      appBar: appBar(context: context, title: 'Clubs'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: .0),
        child: Column(
          children: [
            // Search bar
            searchBar(),

            // Clubs joined
            Expanded(child: clubList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New club',
        child: Icon(AntDesign.addusergroup),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => CreateAClub(),
            )),
      ),
    );
  }

  // Search bar widget
  Widget searchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: GestureDetector(
        child: Container(
          height: 45.0,
          decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8.0)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                // Search icon
                Icon(EvilIcons.search, color: Colors.grey[600]),

                // Search club text
                Text(
                  'Search club',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        onTap: () => searchClub(context),
      ),
    );
  }

  // Clubs the current user joins
  Widget clubList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.clubsCollection
          .where('members', arrayContains: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return NoGroupWidget();
        else {
          List clubs = [];
          snapshot.data.docs.forEach((element) => clubs.add(element.data()));
          return ListView.builder(
              padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              physics: BouncingScrollPhysics(),
              itemCount: clubs.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                Club club = Club.fromMap(clubs[index]);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(8.0),
                    elevation: 3.5,
                    shadowColor:
                        Theme.of(context).shadowColor.withOpacity(0.45),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                      leading: club.clubPhoto != null
                          ? CircularProfileAvatar(
                              club.clubPhoto,
                              placeHolder: (context, url) {
                                return Container(
                                  color: Colors.grey,
                                );
                              },
                              radius: MediaQuery.of(context).size.width / 17,
                            )
                          : CircleAvatar(
                              radius: MediaQuery.of(context).size.width / 17,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Icon(Icons.group, color: Colors.white),
                            ),
                      title: Text(club.name),
                      subtitle: Text(
                        club.description,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: club.administrators.contains((user.uid))
                          ? club.membershipRequests.isNotEmpty
                              ? GestureDetector(
                                  child: Container(
                                    padding: EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(50.0),
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
              });
        }
      },
    );
  }

  // Show the search screen
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
          appBarTheme: Theme.of(context)
              .appBarTheme
              .copyWith(brightness: Brightness.dark),
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
