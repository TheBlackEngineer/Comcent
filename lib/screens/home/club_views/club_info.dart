import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

// ignore: must_be_immutable
class ClubInfo extends StatefulWidget {
  final Club club;

  ClubInfo({Key key, @required this.club}) : super(key: key);

  @override
  _ClubInfoState createState() => _ClubInfoState();
}

class _ClubInfoState extends State<ClubInfo> {
  User user;
  String name, description;
  String saveOrChange = 'Change';
  File sampleImage;

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    return Scaffold(
      appBar: appBar(
          title: widget.club.administrators.contains(user.uid)
              ? 'Admin settings'
              : widget.club.name,
          context: context,
          onPressed: () => Navigator.pop(context)),
      body: StreamBuilder<Object>(
          stream:
              FirestoreService.clubsCollection.doc(widget.club.id).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            var document = snapshot.data;
            Club club = Club.fromDocument(document);
            return ListView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 8.0, bottom: 20.0),
              children: [
                // club profile photo
                Column(
                  children: [
                    if (club.clubPhoto != null)
                      Hero(
                        tag: widget.club.clubPhoto,
                        child: Container(
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
                            radius: MediaQuery.of(context).size.width / 7.5,
                            child: sampleImage == null
                                ? GestureDetector(
                                    child: CircularProfileAvatar(
                                      club.clubPhoto,
                                      radius:
                                          MediaQuery.of(context).size.width /
                                              7.5,
                                    ),
                                    onTap: () => Navigator.push(
                                        context,
                                        TransparentCupertinoPageRoute(
                                            builder: (context) => ImageView(
                                                  imageUrl: club.clubPhoto,
                                                ))),
                                  )
                                : CircularProfileAvatar(
                                    '',
                                    radius:
                                        MediaQuery.of(context).size.width / 7.5,
                                    child: Image.file(
                                      sampleImage,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),
                      )
                    else
                      sampleImage == null
                          ? CircleAvatar(
                              radius: MediaQuery.of(context).size.width / 7.5,
                              child: Icon(Icons.group, size: 60.0),
                            )
                          : CircularProfileAvatar(
                              '',
                              radius: MediaQuery.of(context).size.width / 7.5,
                              child: Image.file(
                                sampleImage,
                                fit: BoxFit.cover,
                              ),
                            ),

                    SizedBox(height: 13.0),

                    // tap to change
                    widget.club.administrators.contains(user.uid)
                        ? ArgonButton(
                            elevation: 0.0,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            height: 40.0,
                            width: 80.0,
                            child: Text(
                              saveOrChange,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 15.0),
                            ),
                            loader: Container(
                              padding: EdgeInsets.all(10),
                              child: SpinKitRing(
                                color: Theme.of(context).primaryColor,
                                lineWidth: 2.0,
                              ),
                            ),
                            onTap: (startLoading, stopLoading, btnState) async {
                              if (btnState == ButtonState.Idle &&
                                  sampleImage != null &&
                                  saveOrChange == 'Save') {
                                startLoading();
                                await _validateChangesAndSubmit(club)
                                    .whenComplete(() {
                                  setState(() {
                                    saveOrChange = 'Change';
                                  });
                                });

                                stopLoading();
                              } else
                                openBottomSheet();
                            })
                        : SizedBox.shrink(),
                  ],
                ),

                // club name
                ClubInfoItem(
                  body: club.name,
                  header: 'Club Name',
                  onEditButtonTapped: club.administrators.contains(user.uid)
                      ? () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Club name'),
                                  content: TextFormField(
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    initialValue: club.name,
                                    decoration: textInputDecoration,
                                    onChanged: (value) {
                                      setState(() {
                                        name = value;
                                      });
                                    },
                                  ),
                                  actions: <Widget>[
                                    // cancel
                                    FlatButton(
                                      textColor: Theme.of(context).primaryColor,
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),

                                    // save
                                    FlatButton(
                                      color: Theme.of(context).primaryColor,
                                      textColor: Colors.white,
                                      child: Text('Save'),
                                      onPressed: () async {
                                        await FirestoreService.clubsCollection
                                            .doc(club.id)
                                            .update({
                                          'name': name,
                                        }).whenComplete(
                                                () => Navigator.pop(context));
                                      },
                                    ),
                                  ],
                                );
                              });
                        }
                      : null,
                ),

                // club description
                ClubInfoItem(
                  body: club.description,
                  header: 'Club Description',
                  onEditButtonTapped: club.administrators.contains(user.uid)
                      ? () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Club description'),
                                  content: TextFormField(
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    initialValue: club.description,
                                    maxLines: null,
                                    decoration: textInputDecoration,
                                    onChanged: (value) {
                                      setState(() {
                                        description = value;
                                      });
                                    },
                                  ),
                                  actions: <Widget>[
                                    // cancel
                                    FlatButton(
                                      textColor: Theme.of(context).primaryColor,
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),

                                    // save
                                    FlatButton(
                                      color: Theme.of(context).primaryColor,
                                      textColor: Colors.white,
                                      child: Text('Save'),
                                      onPressed: () async {
                                        await FirestoreService.clubsCollection
                                            .doc(club.id)
                                            .update({
                                          'description': description,
                                        }).whenComplete(
                                                () => Navigator.pop(context));
                                      },
                                    ),
                                  ],
                                );
                              });
                        }
                      : null,
                ),

                // club rules
                club.clubRules.isNotEmpty
                    ? ClubInfoItem(
                        body: '1. ' + club.clubRules[0],
                        header: 'Club Rules',
                        onEditButtonTapped:
                            club.administrators.contains(user.uid)
                                ? () {
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) => RulesView(
                                                  club: club,
                                                )));
                                  }
                                : null,
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => RulesView(
                                        club: club,
                                      )));
                        },
                      )
                    : club.administrators.contains(user.uid)
                        ? ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Add rules'),
                            leading: Icon(Icons.add),
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => RulesView(
                                    club: club,
                                  ),
                                ),
                              );
                            },
                          )
                        : SizedBox.shrink(),

                // show membership requests if user is admin
                club.administrators.contains(user.uid)
                    ? Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: GestureDetector(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'View Membership Requests ' +
                                    '(' +
                                    club.membershipRequests.length.toString() +
                                    ')',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                              // see all button
                              Icon(
                                Icons.arrow_forward,
                                color: Theme.of(context).primaryColor,
                              )
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => MembershipRequests(
                                  club: club,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : SizedBox.shrink(),

                // members
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child:
                      Text('Members(' + club.members.length.toString() + ')'),
                ),

                SizedBox(height: 10.0),

                // list of members
                ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 25.0),
                  itemCount: club.members.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder(
                        future: FirestoreService(uid: club.members[index])
                            .personFuture(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            Person member = snapshot.data;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: member.profilePhoto != null
                                  ? CircularProfileAvatar(
                                      member.profilePhoto,
                                      placeHolder: (context, url) {
                                        return Container(
                                          color: Colors.grey,
                                        );
                                      },
                                      radius:
                                          MediaQuery.of(context).size.width /
                                              20,
                                    )
                                  : CircleAvatar(
                                      child: Icon(Icons.person),
                                    ),
                              title: Row(
                                children: [
                                  // name
                                  Text(
                                      member.firstName + ' ' + member.lastName),

                                  // leader tag if user is leader
                                  member.isLeader
                                      ? LeadershipBadge()
                                      : SizedBox.shrink(),
                                ],
                              ),
                              subtitle: club.creator == member.id
                                  ? Text(
                                      'Creator, Admin',
                                      style:
                                          TextStyle(color: Colors.lightGreen),
                                    )
                                  : club.administrators.contains(member.id)
                                      ? Text(
                                          'Admin',
                                          style: TextStyle(
                                              color: Colors.lightGreen),
                                        )
                                      : null,
                              trailing: club.administrators
                                          .contains(user.uid) &&
                                      club.creator != member.id
                                  ? FlatButton(
                                      onPressed: () =>
                                          FirestoreService.removeClubMember(
                                              member.id, club.id),
                                      child: Text('Remove',
                                          style: TextStyle(color: Colors.red)),
                                    )
                                  : null,
                            );
                          } else {
                            return ListTile();
                          }
                        });
                  },
                ),

                // delete club
                user.uid == club.creator
                    ? ListTile(
                        tileColor: Colors.grey[200],
                        contentPadding: EdgeInsets.zero,
                        title: Text('Delete club',
                            style: TextStyle(color: Colors.red)),
                        leading:
                            CircleAvatar(backgroundColor: Colors.transparent),
                        onTap: () => attemptClubDelete(context),
                      )
                    : SizedBox.shrink(),
              ],
            );
          }),
    );
  }

  Future _validateChangesAndSubmit(Club club) async {
    String newProfileUrl;
    String imageName = club.id;

    // delete old club photo
    if (club.clubPhoto != null) {
      await FirestoreService.deleteFile(
          fileName: imageName, fileType: 'Club', clubID: widget.club.id);
    }

    // upload new one and get it's url
    if (sampleImage != null) {
      String downloadUrl =
          await uploadImage(imageName: imageName, imageFile: sampleImage);
      setState(() {
        newProfileUrl = downloadUrl;
      });
    }

    // update the url stored in firestore
    await FirestoreService.clubsCollection.doc(club.id).update({
      'clubPhoto': newProfileUrl ?? club.clubPhoto,
    });
  }

  Future openBottomSheet() {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // camera image
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take photo'),
                onTap: () {
                  Navigator.pop(context);
                  takePhoto();
                },
              ),

              // gallery image
              ListTile(
                leading: Icon(Icons.image_sharp),
                title: Text('Open gallery'),
                onTap: () {
                  Navigator.pop(context);
                  openGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // pick image from gallery
  Future openGallery() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile =
        await imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      sampleImage = pickedFile != null ? File(pickedFile.path) : null;
      saveOrChange = sampleImage != null ? 'Save' : 'Change';
    });
  }

  // take photo with camera
  Future takePhoto() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile =
        await imagePicker.getImage(source: ImageSource.camera);
    setState(() {
      sampleImage = pickedFile != null ? File(pickedFile.path) : null;
      saveOrChange = sampleImage != null ? 'Save' : 'Change';
    });
  }

  // upload image to storage
  // upload the image to firebase storage and get the download link of the image
  Future<String> uploadImage(
      {@required String imageName, @required File imageFile}) async {
    final Reference storageReference =
        FirebaseStorage.instance.ref().child('ClubProfiles/$imageName');
    final UploadTask uploadTask = storageReference.putFile(imageFile);
    var downloadUrl = await (await uploadTask).ref.getDownloadURL();
    var url = downloadUrl.toString();
    return url;
  }

  // attempt to delete a club
  Future attemptClubDelete(BuildContext context) async {
    return showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text('Warning!'),
            content: Text('Deleting a club cannot be undone'),
            actions: [
              CupertinoDialogAction(
                child: Text('Proceed'),
                isDestructiveAction: true,
                onPressed: () async {
                  await EasyLoading.show(
                    status: 'Deleting club...',
                    maskType: EasyLoadingMaskType.black,
                    dismissOnTap: true,
                  );
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                  Navigator.pop(context);

                  QuerySnapshot querySnapshot = await FirestoreService
                      .clubsCollection
                      .doc(widget.club.id)
                      .collection('messages')
                      .get();

                  // check if there are any messages at all before attempting to delete files
                  if (querySnapshot.docs.isNotEmpty) {
                    // delete all media files from storage
                    await FirestoreService.clubsCollection
                        .doc(widget.club.id)
                        .collection('messages')
                        .where('type', isNotEqualTo: 'Normal')
                        .get()
                        .then((QuerySnapshot snapshot) {
                      snapshot.docs.forEach((documentSnapshot) {
                        FirestoreService.deleteFile(
                            fileName: documentSnapshot.id,
                            fileType: 'Message',
                            clubID: widget.club.id);
                      });
                    });

                    // delete all messages
                    await FirestoreService.clubsCollection
                        .doc(widget.club.id)
                        .collection('messages')
                        .get()
                        .then((QuerySnapshot snapshot) {
                      snapshot.docs.forEach((documentSnapshot) {
                        documentSnapshot.reference.delete();
                      });
                    });
                  }

                  // delete club profile photo if it's not null
                  if (widget.club.clubPhoto != null) {
                    FirestoreService.deleteFile(
                      fileName: widget.club.id,
                      fileType: 'Club',
                    );
                  }

                  await FirestoreService.clubsCollection
                      .doc(widget.club.id)
                      .delete();

                  EasyLoading.showSuccess('Club was deleted',
                      dismissOnTap: true);
                },
              ),
              CupertinoDialogAction(
                child: Text('Cancel'),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(ctx);
                },
              )
            ],
          );
        });
  }
}

class ClubInfoItem extends StatelessWidget {
  final String body;
  final String header;
  final Function onTap;
  final Function onEditButtonTapped;

  const ClubInfoItem(
      {Key key,
      @required this.body,
      @required this.header,
      this.onTap,
      this.onEditButtonTapped})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  header,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              onEditButtonTapped != null
                  ? GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Text(
                          'Edit',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      onTap: onEditButtonTapped,
                    )
                  : SizedBox.shrink()
            ],
          ),

          SizedBox(height: 5.0),

          // body
          GestureDetector(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                body,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}
