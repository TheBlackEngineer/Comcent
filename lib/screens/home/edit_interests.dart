import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class EditInterests extends StatefulWidget {
  @override
  _EditInterestsState createState() => _EditInterestsState();
}

class _EditInterestsState extends State<EditInterests> {
  User user;
  Future<Person> _data;
  List topicsToBeSaved = [];
  List yourInterests = [];
  List<QueryDocumentSnapshot> postSnapshots = [];
  List<QueryDocumentSnapshot> timelineSnapshots = [];

  // Get user timeline posts
  void getUserTimelinePosts() async {
    QuerySnapshot querySnapshot = await FirestoreService.timelineCollection
        .doc(user.uid)
        .collection('feed')
        .get();
    List<QueryDocumentSnapshot> queryDocSnaps = querySnapshot.docs;
    setState(() {
      this.timelineSnapshots = queryDocSnaps;
    });
  }

  // Get posts
  void getPosts() async {
    QuerySnapshot querySnapshot = await FirestoreService.postsCollection.get();
    List<QueryDocumentSnapshot> queryDocSnaps = querySnapshot.docs;
    setState(() {
      this.postSnapshots = queryDocSnaps;
    });
  }

  Future<Person> getPerson() async {
    Person person = await FirestoreService(
            uid: Provider.of<CommunityProvider>(context, listen: false)
                .person
                .id)
        .personFuture();
    yourInterests.addAll(person.interests);
    return person;
  }

  @override
  void initState() {
    super.initState();
    _data = getPerson();
    getPosts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = Provider.of<User>(context);
    getUserTimelinePosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Edit interests',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Theme.of(context).textSelectionColor,
            onPressed: () => (Navigator.pop(context)),
          ),
          actions: [
            FlatButton(
              onPressed: updateUserInterests,
              child: Text(
                'Save',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            )
          ],
        ),
        body: FutureBuilder<Person>(
            future: _data,
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CupertinoActivityIndicator());

              return ListView(
                physics: BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                    top: 10.0, bottom: 20.0, left: 10.0, right: 10.0),
                children: [
                  // all topics
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 8.0),
                    child: Text(
                      'All topics',
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),

                  // all interest tags
                  GridView.count(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    childAspectRatio: 2.7,
                    crossAxisCount: 3,
                    children: List.generate(
                      topics.length,
                      (index) => GestureDetector(
                        child: Chip(
                          elevation: 2.0,
                          backgroundColor:
                              topicsToBeSaved.contains(topics[index])
                                  ? Theme.of(context).primaryColor
                                  : Colors.white,
                          label: Text(topics[index]),
                          labelStyle: TextStyle(
                            color: topicsToBeSaved.contains(topics[index])
                                ? Colors.white
                                : Theme.of(context).primaryColor,
                          ),
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                        ),
                        onTap: () {
                          if (!topicsToBeSaved.contains(topics[index])) {
                            topicsToBeSaved.add(topics[index]);
                          } else {
                            topicsToBeSaved.remove(topics[index]);
                          }
                          setState(() {});
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 15.0),

                  // your interests
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 8.0),
                    child: Text(
                      'Your interests',
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),

                  // your interests tags
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    childAspectRatio: 2.7,
                    children: List.generate(
                      yourInterests.length,
                      (index) => Chip(
                        label: Text(yourInterests[index]),
                        deleteIcon: Icon(Icons.clear),
                        onDeleted: yourInterests.length > 1
                            ? () {
                                setState(() {
                                  yourInterests.remove(yourInterests[index]);
                                });
                              }
                            : null,
                      ),
                    ),
                  ),

                  SizedBox(height: 15.0),

                  // selected interests
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 8.0),
                    child: Text(
                      'Selected interests',
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),

                  // selected interests tags
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    childAspectRatio: 2.7,
                    children: List.generate(topicsToBeSaved.length,
                        (index) => Chip(label: Text(topicsToBeSaved[index]))),
                  ),
                ],
              );
            }));
  }

  void updateUserInterests() {
    EasyLoading.show(
        status: 'Updating interests',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: true);

    List finalList = (topicsToBeSaved + yourInterests).toSet().toList();

    List<QueryDocumentSnapshot> postsToAddToTimeline = this
        .postSnapshots
        .where((snapshot) => finalList.contains(snapshot.data()['topic']))
        .toList();

    // Delete all posts where their topic was removed from the user's interests
    timelineSnapshots.forEach((snapshot) {
      if (!finalList.contains(snapshot.data()['topic'])) {
        FirestoreService.timelineCollection
            .doc(user.uid)
            .collection('feed')
            .doc(snapshot.id)
            .delete()
            .then((value) => print('A documents was deleted'));
      }
    });

    // Add all posts whose topic was added to the user's interests
    if (postsToAddToTimeline.isNotEmpty) {
      postsToAddToTimeline.forEach((snapshot) {
        FirestoreService.timelineCollection
            .doc(user.uid)
            .collection('feed')
            .doc(snapshot.id)
            .set({
          'topic': snapshot.data()['topic'],
          'timeOfUpload': snapshot.data()['timeOfUpload'],
          'isLeaderPost': snapshot.data()['isLeaderPost'],
        }).then((value) => print('A document was added'));
      });
    }

    // Update the user's interests
    FirestoreService.usersCollection
        .doc(user.uid)
        .update({'interests': finalList}).then((value) {
      Navigator.pop(context);
      EasyLoading.showSuccess('Interests updated successfully',
          dismissOnTap: true, duration: Duration(seconds: 5));
    });
  }
}
