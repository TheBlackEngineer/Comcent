import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchFieldController = TextEditingController();

  String _searchText = "";

  List userNames = List(); // names we get from API

  List filteredUsers = List();

  void fetchUsers() async {
    // user snapshots
    List<QueryDocumentSnapshot> userSnapshots = await FirestoreService
        .usersCollection
        .get()
        .then((QuerySnapshot snapshot) {
      return snapshot.docs;
    });

    List tempList = List();

    for (DocumentSnapshot documentSnapshot in userSnapshots) {
      tempList.add(Person.fromDocument(documentSnapshot));
    }

    setState(() {
      userNames = tempList;
      filteredUsers = userNames;
    });
  }

  _SearchScreenState() {
    _searchFieldController.addListener(() {
      if (_searchFieldController.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredUsers = userNames;
        });
      } else {
        setState(() {
          _searchText = _searchFieldController.text;
        });
      }
    });
  }

  Widget _buildUserList() {
    List tempList = List();

    for (int i = 0; i < filteredUsers.length; i++) {
      if ((filteredUsers[i].firstName + filteredUsers[i].lastName)
          .toLowerCase()
          .contains(_searchText.toLowerCase())) {
        tempList.add(filteredUsers[i]);
      }
    }

    filteredUsers = tempList;

    return ListView.separated(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 20.0),
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      itemCount: userNames == null ? 0 : filteredUsers.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (BuildContext context, int index) {
        Person person = filteredUsers[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: person.profilePhoto != null
              ? CircleAvatar(
                  backgroundImage:
                      CachedNetworkImageProvider(person.profilePhoto),
                )
              : CircleAvatar(
                  child: Icon(Icons.person),
                ),
          title: Row(
            children: [
              // name
              Text(person.firstName + ' ' + person.lastName),

              // leader tag if user is leader
              person.isLeader ? LeadershipBadge() : SizedBox.shrink(),
            ],
          ),
          onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => Profile(userID: person.id),
              )),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      gestures: [GestureType.onPanDown],
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Search',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          centerTitle: true,
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(90.0),
              child: SearchBox(searchFieldController: _searchFieldController)),
        ),
        body: _searchText.isNotEmpty && filteredUsers.isNotEmpty
            ? _buildUserList()
            : Center(
                child:
                    Icon(Feather.search, color: Colors.grey[700], size: 65.0),
              ),
      ),
    );
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox({
    Key key,
    @required TextEditingController searchFieldController,
  })  : _searchFieldController = searchFieldController,
        super(key: key);

  final TextEditingController _searchFieldController;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      elevation: 2.0,
      child: ListTile(
        leading: Icon(Icons.search, color: Theme.of(context).primaryColor),
        title: TextField(
          controller: _searchFieldController,
          cursorColor: Theme.of(context).primaryColor,
          decoration: InputDecoration.collapsed(
            hintText: 'Search for users',
            hintStyle: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
        trailing: _searchFieldController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () => _searchFieldController.clear(),
              )
            : SizedBox.shrink(),
      ),
    );
  }
}
